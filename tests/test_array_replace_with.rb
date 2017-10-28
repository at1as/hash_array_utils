require 'minitest/autorun'
require_relative '../array_utils.rb'

class TestArrayReplaceWith < MiniTest::Test

  def setup
  end

  # BASIC TESTS
  def test_replace_with_empty_hash
    assert_equal(
      [],
      [].replace_with("X", "Y")
    )
  end

  def test_replace_with_key_not_present
    assert_equal(
      ["X"],
      ["X"].replace_with("NOT HERE", "REPLACEMENT KEY")
    )
  end
  
  def test_replace_with_key_not_present
    assert_equal(
      ["X"],
      ["X"].replace_with("NOT HERE", "REPLACEMENT KEY")
    )
  end
  
  def test_replace_with_key_not_present_and_adjacent_keys_unmodified
    assert_equal(
      ["A", "replaced!", "Z"],
      ["A", "X", "Z"].replace_with("X", "replaced!")
    )
  end

  # IN PLACE CHANGES
  def test_replace_with_does_not_replace_in_place
    array = ["A", "B", "C"]
    assert_equal(["A", "B", "_"], array.replace_with("C", "_"))

    assert_equal(["A", "B", "C"], array)
  end
  
  def test_replace_with_bang_replaces_in_place
    array = ["A", "B", "C"]
    assert_equal(["A", "B", "_"], array.replace_with!("C", "_"))

    assert_equal(["A", "B", "_"], array)
  end

  def test_replaced_objects_are_value_objects
    first  = ["A", "B", "C"]
    second = ["A", "B", "C"]

    assert(first == second)
    assert(first === second)

    first.replace_with!("A", "first")

    assert !(first == second)
    assert !(first === second)
    
    second.replace_with!("A", "first")
    
    assert(first == second)
    assert(first === second)
  end

  # TYPE TESTS
  def test_replace_array_key
    assert(
      ["A", "Array", "C"],
      ["A", [], "C"].replace_with([], "Array")
    )
  end

  def test_replace_array_value
    assert(
      ["A", [], "C"],
      ["A", "Array", "C"].replace_with("Array", [])
    )
  end
  
  def test_replace_hash_key
    assert(
      ["A", "Hash", "C"],
      ["A", {}, "C"].replace_with({}, "Hash")
    )
  end
  
  def test_replace_hash_value
    assert(
      ["A", {}, "C"],
      ["A", "Hash", "C"].replace_with("Hash", {})
    )
  end
  
  def test_replace_struct_key
    s = Struct.new(:x)
    assert(
      ["A", "Struct", "C"],
      ["A", s, "C"].replace_with(s, "Struct")
    )
  end
  
  def test_replace_struct_value
    s = Struct.new(:x)
    assert(
      ["A", s, "C"],
      ["A", "Struct", "C"].replace_with("Struct", s)
    )
  end
  
  def test_replace_symbol_key
    assert(
      ["A", "Symbol", "C"],
      ["A", :symbol, "C"].replace_with(:symbol, "Symbol")
    )
  end
  
  def test_replace_struct_value
    assert(
      ["A", :symbol, "C"],
      ["A", "Symbol", "C"].replace_with("Symbol", :symbol)
    )
  end

  # COMPLEX Patterns
  def test_replace_with_complex_nested_array
    assert(
      [
        "A",
        [:A, {[] => {"C" => {} }}],
        "Z"
      ],
      ["A", [["B", ["C"]]], "Z"].replace_with( [["B", ["C"]]] , [:A, {[] => {"C" => {} }}] )
    )
  end

end
