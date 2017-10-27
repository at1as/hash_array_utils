require 'minitest/autorun'
require_relative '../hash_utils.rb'

class TestDeleteByKeyPath < MiniTest::Test

  def setup
  end

  ### EMPTY HASH

  def test_delete_empty_keys_list_from_empty_hash
    assert_equal(
      {}.delete_by_key_path([]),
      {}
    )
  end

  def test_delete_non_existent_keys_from_empty_hash
    assert_equal(
      {}.delete_by_key_path(["DOES", "NOT", "EXIST"]),
      {}
    )
  end

  ### BASIC TESTS

  def test_delete_empty_key_list_from_hash
    assert_equal(
      {"KEY" => "VALUE"}.delete_by_key_path([]),
      {"KEY" => "VALUE"}
    )
  end

  def test_delete_key_from_one_item_hash
    assert_equal(
      {"KEY" => "VALUE"}.delete_by_key_path(["KEY"]),
      {}
    )
  end
  
  def test_delete_non_existent_key_from_one_item_hash
    assert_equal(
      {"KEY" => "VALUE"}.delete_by_key_path(["FAKE KEY"]),
      {"KEY" => "VALUE"}
    )
  end

  def test_delete_key_from_multi_item_hash
    assert_equal(
      {"KEY1" => "VAL1", "KEY2" => "VAL2"}.delete_by_key_path(["KEY1"]),
      {"KEY2" => "VAL2"}
    )
  end
  
  def test_delete_non_existent_key_from_multi_item_hash
    assert_equal(
      {"KEY1" => "VAL1", "KEY2" => "VAL2"}.delete_by_key_path(["FAKE KEY"]),
      {"KEY1" => "VAL1", "KEY2" => "VAL2"}
    )
  end

  ### NESTING ###

  def test_delete_deeply_nested_last_key
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "E" }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_deeply_nested_middle_key
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "E" }}}}.delete_by_key_path(["A", "B"]),
      {"A" => {}}
    )
  end
  
  def test_delete_deeply_nested_first_key
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "E" }}}}.delete_by_key_path(["A"]),
      {}
    )
  end

  ### VALUE TYPES
  
  def test_delete_key_for_array_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => [] }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_numeric_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => 39393 }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_string_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "hello world"}}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_hash_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => {} }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_symbol_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => :hello }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_nested_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => {"HELLO" => {:world => []}}}}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_struct_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => Struct.new(:x) }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end
  
  def test_delete_key_for_class_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => Struct }}}}.delete_by_key_path(["A", "B", "C", "D"]),
      {"A" => { "B" => { "C" => {}}}}
    )
  end

  ### KEY TYPES
  def test_delete_key_for_symbol_key
    assert_equal(
      {:a => { :b => { :c => :d }}}.delete_by_key_path([:a, :b, :c]),
      {:a => { :b => {} } }
    )
  end
  
  def test_delete_key_for_numeric_key
    assert_equal(
      {1 => { 2 => { 3 => 4 }}}.delete_by_key_path([1, 2, 3]),
      {1 => { 2 => {} } }
    )
  end
  
  def test_delete_key_for_mixed_keys
    assert_equal(
      {1 => { :two => { "three" => 4 }}}.delete_by_key_path([1, :two, "three"]),
      {1 => { :two => {} } }
    )
  end
  
  def test_delete_key_hash_key
    assert_equal(
      {"A" => { "B" => { {} => 4 }}}.delete_by_key_path(["A", "B", {}]),
      {"A" => { "B" => { } } }
    )
  end
  
  def test_delete_key_array_key
    assert_equal(
      {"A" => { "B" => { [] => 4 }}}.delete_by_key_path(["A", "B", [] ]),
      {"A" => { "B" => { } } }
    )
  end
  
  def test_delete_key_mid_array_key
    assert_equal(
      {"A" => { [] => { [] => 4 }}}.delete_by_key_path(["A", [], [] ]),
      {"A" => { [] => { } } }
    )
  end
  
  def test_delete_key_deeply_nested_array_at_end
    key_path = [
      "A",
      [],
      [[], [[[]]], {}, ["X", "Y", ["Z", "A", ['a']]]]
    ]

    assert_equal(
      {"A" => { [] => { [[], [[[]]], {}, ["X", "Y", ["Z", "A", ['a']]]] => 4 }}}.delete_by_key_path(key_path),
      {"A" => { [] => { } } }
    )
  end
  
  def test_delete_key_deeply_nested_array_in_middle
    key_path = [
      "A",
      [[], [[[]]], {}, ["X", "Y", ["Z", "A", ['a']]]],
      "B",
      []
    ]

    assert_equal(
      {"A" => { [[], [[[]]], {}, ["X", "Y", ["Z", "A", ['a']]]] => { "B" => { [] => "C" } }}}.delete_by_key_path(key_path),
      {"A" => { [[], [[[]]], {}, ["X", "Y", ["Z", "A", ['a']]]] => { "B" => { } }}}
    )
  end
  
  def test_delete_key_struct_key
    struct = Struct.new(:x)
    assert_equal(
      {"A" => { "B" => { struct => 4 }}}.delete_by_key_path(["A", "B", struct ]),
      {"A" => { "B" => { } } }
    )
  end
  
  def test_delete_key_struct_key
    struct = Struct
    assert_equal(
      {"A" => { "B" => { struct => 4 }}}.delete_by_key_path(["A", "B", struct ]),
      {"A" => { "B" => { } } }
    )
  end

  ### COMPEX Hash
  def test_delete_nested_key_preserves_keys_at_same_level
    assert_equal(
      {
        "A" => {
          "B" => {
            "C" => {
              "D" => "D2",
              "E" => {
                "F1" => ["F2", "F3"], # TARGET KEY TO DELETE
                "G1" => "G2"
              },
              "H" => "I",
            },
            "J" => {"K" => "L"}
          },
          "M" => {"N" => {"O" => {"P" => []}}}
        }
      }.delete_by_key_path(["A", "B", "C", "E", "F1"]),
      {
        "A" => {
          "B" => {
            "C" => {
              "D" => "D2",
              "E" => {
                "G1" => "G2"
              },
              "H" => "I",
            },
            "J" => {"K" => "L"}
          },
          "M" => {"N" => {"O" => {"P" => []}}}
        }
      }
    )
  end

  def test_objects_are_value_objects
    first  = {"X" => "Y", "A" => "B"}
    second = {"X" => "Y", "A" => "B"}

    assert(first == second)
    assert(first === second)

    first.delete_by_key_path(["A"])

    assert !(first == second)
    assert !(first === second)

    second.delete_by_key_path(["A"])

    assert(first == second)
    assert(first === second)
  end

end
