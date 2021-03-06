class Hash
  
  def delete_by_key_path(key_path)
    #
    # Similar to the Hash.dig method, but deletes the
    # target element instead of returning it
    #
    # hash:     {"A" => { "B" => { "C" => { "D1" => "E1", "D2" => "E2" } } } }
    # key_path: ["A", "B", "C", "D1"]
    #
    # hash.delete_by_keys(key_path)
    #
    #   => {"A" => { "B" => { "C" => { "D2" => "E2" } } } }
    #
    # Method modifies hash in place
    #
    
    case
      when key_path.empty? || self.empty?
        return self
      when key_path.length == 1
        return self.tap { |_| self.delete(key_path.last) }
    end

    keys = format_keys_for_eval(key_path)
    
    cmd = 'self[' + keys[0...-1].join('][') + '].delete(key_path.last)'
    eval(cmd)
    
    self
  end
  
  
  def insert_by_key_path(key_path, value)
    #
    # Similar to the Hash.dig method, but modifies the value instead of returning it
    # Supports updating values of existing keys, and inserting additonal keys
    # Will create any keys along the path if they are not present
    #
    # hash:     {"A" => { "B" => { "C" => { "D1" => "E1", "D2" => "E2" } } } }
    # key_path: ["A", "B", "C", "D3"]
    # value:    "E3"
    #
    # hash.insert_by_key_path(key_path, value)
    #
    #   => {"A" => { "B" => { "C" => { "D1" => "E1", "D2" => "E2", "D3" => "E3" } } } }
    #
    # Method modifies hash in place
    #

    return self if key_path.empty?
    
    value = format_value_for_eval(value) 
    keys  = format_keys_for_eval(key_path)

    key_path = get_key_path_to_value(keys)
    eval(key_path + ' = ' + value)
  
  # No Implicit conversion of type into string
  rescue TypeError
    begin
      eval(key_path + ' = ' + "#{value}")

    # This usually occurs when assigning to an Object:
    #   self["X"] = #<Class:0x007faee4086ae8>
    #
    # Need to use the convoluted method below to reference the object
    rescue SyntaxError 
      eval(key_path + ' = ' + 'ObjectSpace._id2ref(' + value.object_id.to_s + ')')
    end
  ensure
    return self
  end


  def flatten_keys
    #
    # Similar to the `flatten` method on Array
    # Will return all hash keys, irrespsective of their nesting
    #
    # hash:   {"A" => {"B" => { "C" => "D" , "E" => "F" } } , "G" => "H" }
    #
    # hash.flatten_keys
    #
    #   => ["A", "B", "C", "E", "G"]

    self.map {|k, v| v.is_a?(Hash) && !v.empty? ? [ (k == [] ? [[]] : k) , v.flatten_keys].flatten(1) : [k] }.flatten(1)
  end
  
  
  def flatten_values
    #
    # Similar to the `flatten` method on Array
    # Will return all hash values, irrespsective of their nesting
    #
    # hash:   {"A" => {"B" => { "C" => "D" , "E" => "F" } } , "G" => "H" }
    #
    # hash.flatten_values
    #
    #   => ["D", "F", "H"]

    self.map {|k, v| v.is_a?(Hash) && !v.empty? ? v.flatten_values : [v] }.flatten(1)
  end

  
  def flatten_key_values
    #
    # Similar to the `flatten` method on Array
    # Will return all hash keys and values, irrespsective of their nesting
    #
    # hash:   {"A" => {"B" => { "C" => "D" , "E" => "F" } } , "G" => "H" }
    #
    # hash.flatten_values
    #
    #   => ["A", "B", "C", "D", "E", "F", "G", "H"]

    self.map do |k, v| 
      case 
        when v.is_a?(Hash) && !v.empty? 
          [ 
            (k == [] ? [[]] : k), # flatten(1) will remove any '[]' keys, so we pad to [[]] so it is preserved
            v.flatten_key_values
          ].flatten(1) 
        else
          [k, v]
      end
    end.flatten(1)
  end
  
  
  def key_hierarchy
    #
    # Returns a nested array of hash keys
    #
    # {"A" => "B" , "C" => "D"}.key_hierarchy
    #
    #     => [["A"], ["C"]]
    #
    #
    # {"A" => {"B" => "b"} , "C" => {"D" => 'd'}}.key_hierarchy
    #
    #     => [["A", [["B"]]], ["C", [["D"]]]]
    #
    #
    # {"A"=>{"B"=>{"C"=>"D", "E"=>"F"}, "x"=>{"y"=>{"z"=>{"q"=>"l"}}}}, "a"=>"b"}.key_hierarchy
    #
    #     => [["A", [["B", [["C"], ["E"]]], ["x", [["y", [["z", [["q"]]]]]]]]], ["a"]]
    #

    self.map { |k, v| v.is_a?(Hash) && !v.empty? ? [k, [v.key_hierarchy].to_a.flatten(1)] : [k] }
  end


  def key_value_hierarchy
    #
    # Returns a nested array of hash keys. Essentially converts each hash and subhash to tuples
    #
    # {"A" => "B" , "C" => "D"}.key_value_hierarchy
    #
    #     => [["A", "B"], ["C", "D"]]
    #
    #
    # {"A" => {"B" => "b"} , "C" => {"D" => 'd'}}.key_value_hierarchy
    #
    #     => [["A", [["B", "b"]]], ["C", [["D", "d"]]]]
    #
    #
    # {"A"=>{"B"=>{"C"=>"D", "E"=>"F"}, "x"=>{"y"=>{"z"=>{"q"=>"l"}}}}, "a"=>"b"}.key_value_hierarchy
    #
    #     => [["A", [["B", [["C", "D"], ["E", "F"]]], ["x", [["y", [["z", [["q", "l"]]]]]]]]], ["a", "b"]]
    #

    self.map { |k, v| v.is_a?(Hash) && !v.empty? ? [k, [v.key_value_hierarchy].flatten(1)] : [k, v] }
  end
  
  
  def format_keys_for_eval(key_path)
    key_path.map do |k| 
      case
        when k.is_a?(String) 
          "\"#{k}\""
        when k.is_a?(Symbol)
          ":#{k}"
        when k.is_a?(Array)
          k.to_s
        else
          k
      end
    end
  end

  private :format_keys_for_eval


  def format_value_for_eval(value)
    if value.is_a?(String)
      "\"#{value}\""
    elsif value.is_a?(Symbol)
      ":#{value}"
    else
      value
    end
  end

  private :format_value_for_eval


  def get_key_path_to_value(keys)
    #
    # keys : ["A", "B", "C"]
    #
    # returns self["A"]["B"]["C"] for any type of key
    #
    # Will create the keys along the path if they do not exist

    key_path = 'self'

    keys.each_index do |i|
      begin
        key_path_next = key_path + '[' + keys[i].to_s + ']'
        eval(key_path_next + " = {}") unless eval(key_path_next).is_a?(Hash)
      
      rescue TypeError, SyntaxError
        # Cannot call eval on an object in the format myHash[#<Class:0x007fe994026a18>]
        # Need to reference it by its object_id
        key_path_next = "#{key_path}[ObjectSpace._id2ref(" + keys[i].object_id.to_s + ')]'
        eval(key_path_next + " = {}") unless eval(key_path_next).is_a?(Hash)
      
      ensure
        key_path = key_path_next
      end
    end

    key_path
  end

  private :get_key_path_to_value


end
