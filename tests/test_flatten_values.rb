require 'minitest/autorun'
require_relative '../hash_utils.rb'

class TestFlattenValues < MiniTest::Test

  def setup
  end

  # Basic
  def test_flatten_values_empty_hash
    assert_equal(
      [],
      {}.flatten_values
    )
  end

  def test_flatten_values_single_kv_pair
    assert_equal(
      ["B"],
      {"A" => "B"}.flatten_values
    )
  end
  
  def test_flatten_values_multiple_kv_pairs
    assert_equal(
      ["B", "D"],
      {"A" => "B", "C" => "D"}.flatten_values
    )
  end
  
  def test_flatten_values_single_nested_kv_pairs
    assert_equal(
      ["D"],
      {"A" => {"B" => {"C" => "D"}}}.flatten_values
    )
  end
  
  def test_flatten_values_multiple_nested_kv_pairs
    assert_equal(
      [
        "D",
        "d"
      ],
      {
        "A" => {"B" => {"C" => "D"}},
        "a" => {"b" => {"c" => "d"}}
      }.flatten_values
    )
  end

  def test_flatten_values_multiple_nested_kv_pairs_unequal_nesting
    assert_equal(
      [
        "D",
        "e",
        "_B_",
        "_c_"
      ],
      {
        "A"   => {"B" => {"C" => "D"}},
        "a"   => {"b" => {"c" => {"d" => "e"}}},
        "A_" => "_B_",
        "_a_" => {"_b_" => "_c_"}
      }.flatten_values
    )
  end

  # Values
  def test_only_repeated_values
    assert_equal(
      ["B", "B", "B"],
      {
        "A1" => "B",
        "A2" => "B",
        "A3" => "B"
      }.flatten_values
    )
  end
  
  def test_intermixed_repeated_values
    assert_equal(
      ["B", "_", "B", "B", "X", "B"],
      {
        "A1" => "B",
        "A2" => {"A" => "_"},
        "A3" => {"A" => {"B1" => "B", "B2" => "B"}},
        "A4" => {"A" => {"B" => "X"}},
        "A5" => {"A" => "B"}
      }.flatten_values
    )
  end

  def test_value_object_is_returned
    first  = {"Hello" => "World"}
    second = {"Hello" => "World"}

    assert(first == second)
    assert(first === second)

    first = first.flatten_values

    assert !(first == second)
    assert !(first === second)

    second = second.flatten_values

    assert(first == second)
    assert(first === second)
  end

  # Types
  def test_values_can_be_mixed_values
    assert_equal(
      [
        :X,
        {},
        [],
        4,
        "Z"
      ],
      {
        "A" => {
          :B  => { [] => { {} => :X } },
          "C" => {},
          []  => []
        },
        2 => 4,
        "z" => "Z"
      }.flatten_values
    )
  end

  def test_values_can_be_objects
    s = Struct.new(:abc)
    
    assert_equal(
      [s, s],
      {
        "A" => {
          "B" => s,
          "C" => s
        }
      }.flatten_values
    )
  end

end
