require 'minitest/autorun'
require_relative '../hash_utils.rb'

class TestFlattenKeys < MiniTest::Test

  def setup
  end

  # Basic
  def test_flatten_keys_empty_hash
    assert_equal(
      [],
      {}.flatten_keys
    )
  end

  def test_flatten_keys_single_kv_pair
    assert_equal(
      ["A"],
      {"A" => "B"}.flatten_keys
    )
  end
  
  def test_flatten_keys_multiple_kv_pairs
    assert_equal(
      ["A", "C"],
      {"A" => "B", "C" => "D"}.flatten_keys
    )
  end
  
  def test_flatten_keys_single_nested_kv_pairs
    assert_equal(
      ["A", "B", "C"],
      {"A" => {"B" => {"C" => "D"}}}.flatten_keys
    )
  end
  
  def test_flatten_keys_multiple_nested_kv_pairs
    assert_equal(
      [
        "A", "B", "C",
        "a", "b", "c"
      ],
      {
        "A" => {"B" => {"C" => "D"}},
        "a" => {"b" => {"c" => "d"}}
      }.flatten_keys
    )
  end

  def test_flatten_keys_multiple_nested_kv_pairs_unequal_nesting
    assert_equal(
      [
        "A", "B", "C",
        "a", "b", "c", "d",
        "_A_",
        "_a_", "_b_"
      ],
      {
        "A"   => {"B" => {"C" => "D"}},
        "a"   => {"b" => {"c" => {"d" => "e"}}},
        "_A_" => "_B_",
        "_a_" => {"_b_" => "_c_"}
      }.flatten_keys
    )
  end

  # Keys 
  def test_only_repeated_nested_keys
    assert_equal(
      ["A", "A", "A"],
      {"A" => {"A" => { "A" => "B"}}}.flatten_keys
    )
  end
  
  def test_intermixed_repeated_keys
    assert_equal(
      ["A", "C", "A", "D", "A", "B"],
      {
        "A" => "B",
        "C" => {"A" => "_"},
        "D" => {"A" => {"B" => "_"}}
      }.flatten_keys
    )
  end

  def test_value_object_is_returned
    first  = {"Hello" => "World"}
    second = {"Hello" => "World"}

    assert(first == second)
    assert(first === second)

    first = first.flatten_keys

    assert !(first == second)
    assert !(first === second)

    second = second.flatten_keys

    assert(first == second)
    assert(first === second)
  end

  # Types
  def test_keys_can_be_mixed_values
    assert_equal(
      [
        "A",
        :B, [], {},
        "C",
        [],
        2
      ],
      {
        "A" => {
          :B  => { [] => { {} => :X } },
          "C" => {},
          []  => []
        },
        2 => 4
      }.flatten_keys
    )
  end

  def test_keys_can_be_objects
    s = Struct.new(:abc)
    
    assert_equal(
      [s, s],
      {
        s => {
          s => "ABC"
        }
      }.flatten_keys
    )
  end

end
