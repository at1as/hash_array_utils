class Array

  def replace_with(old_value, new_value)
    #
    # Similar to gsub for strings "hello".gsub('e', 3) => "h3llo"
    #
    # ["A", "B", "C", "D", "A", "B", "C", "D"].replace_with("A", "NEW")
    #
    # => ["NEW", "B", "C", "D", "NEW",B", "C", "D"]
    #
    self.map {|x| x == old_value ? new_value : x }
  end

  def replace_with!(old_value, new_value)
    #
    # The in place version of the `replace_with` method
    #
    self.map! {|x| x == old_value ? new_value : x }
  end

end
