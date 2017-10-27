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

    return self if key_path.empty?
    
    value = format_value_for_eval(value) 
    keys  = format_keys_for_eval(key_path)

    key_path = create_key_path_to_value_if_missing(keys)
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
    # hash:   {"A" => {"B" => { "C" => "D" , "E" => "F" } } }
    #
    # hash.flatten_keys
    #
    #   => ["A", "B", "C", "E" ]

    self.map {|k, v| v.is_a?(Hash) ? [k, v.flatten_keys].flatten : [k] }.flatten
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

    self.map {|k, v| v.is_a?(Hash) ? v.flatten_values : [v] }.flatten
  end

  
  def flatten_all
    #
    # Similar to the `flatten` method on Array
    # Will return all hash keys and values, irrespsective of their nesting
    #
    # hash:   {"A" => {"B" => { "C" => "D" , "E" => "F" } } , "G" => "H" }
    #
    # hash.flatten_values
    #
    #   => ["A", "B", "C", "D", "E", "F", "G", "H"]

    self.map {|k, v| v.is_a?(Hash) ? [k, v.flatten_all] : [k, v] }.flatten
  end
  
  
  def key_hierarchy #FIXME
    #
    # Similar to the `flatten` method on Array
    # Will return all hash keys, irrespsective of their nesting
    #
    # hash:   {"A" => {"B" => { "C" => "D" , "E" => "F" } } }
    #
    # hash.flatten_keys
    #
    #   => ["A", "B", "C", "E" ]

    self.map {|k, v| v.is_a?(Hash) ? [k, *v.key_hierarchy] : k }
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


  def create_key_path_to_value_if_missing(keys)
    
    # Create intermediate keys if necessary
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

  private :create_key_path_to_value_if_missing


end
