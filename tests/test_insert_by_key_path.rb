require 'minitest/autorun'
require_relative '../hash_utils.rb'

class TestInsertByKeyPath < MiniTest::Test

  def setup
  end

  ### EMPTY HASH

  def test_insert_empty_keys_list_from_empty_hash
    assert_equal(
      {}.insert_by_key_path([], nil),
      {}
    )
    
    assert_equal(
      {}.insert_by_key_path([], "HELLO"),
      {}
    )
  end

  def test_insert_new_keys_into_empty_hash
    assert_equal(
      {}.insert_by_key_path(["NEWLY", "CREATED", "KEYS"], "X"),
      {"NEWLY" => {"CREATED" => {"KEYS" => "X"}}}
    )
  end

  ### BASIC TESTS
  def test_update_existing_value
    assert_equal(
      {"Hello" => "World"}.insert_by_key_path(["Hello"], "Mars"),
      {"Hello" => "Mars"}
    )
  end

  def test_update_existing_value_with_adjacent_values_present
    assert_equal(
      {"Hello" => "World", "X" => "Y"}.insert_by_key_path(["X"], "Z"),
      {"Hello" => "World", "X" => "Z"}
    )
  end

  def test_insert_new_value_with_existing_adjacent_value
    assert_equal(
      {"Hello" => "World"}.insert_by_key_path(["X"], "Y"),
      {"Hello" => "World", "X" => "Y"}
    )
  end

  ### NESTING ###

  def test_insert_deeply_nested_last_key
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "E" }}}}.insert_by_key_path(["A", "B", "C", "D"], 99),
      {"A" => { "B" => { "C" => { "D" => 99 }}}}
    )
  end
  
  def test_insert_deeply_nested_middle_key
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "E" }}}}.insert_by_key_path(["A", "B"], 99),
      {"A" => { "B" => 99 } }
    )
  end
  
  def test_insert_deeply_nested_first_key
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "E" }}}}.insert_by_key_path(["A"], 99),
      {"A" => 99}
    )
  end

  ### VALUE TYPES
  def test_insert_array_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "X" }}}}.insert_by_key_path(["A", "B", "C", "D"], ["X"]),
      {"A" => { "B" => { "C" => { "D" => ["X"] }}}}
    )
  end
  
  def test_insert_numeric_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "X" }}}}.insert_by_key_path(["A", "B", "C", "D"], 99),
      {"A" => { "B" => { "C" => { "D" => 99 } } } }
    )
  end
  
  def test_insert_string_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "hello world"}}}}.insert_by_key_path(["A", "B", "C", "D"], "XYZ"),
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}
    )
  end
  
  def test_insert_empty_hash_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}.insert_by_key_path(["A", "B", "C", "D"], {}),
      {"A" => { "B" => { "C" => { "D" => {} }}}}
    )
  end
  
  def test_insert_hash_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}.insert_by_key_path(["A", "B", "C", "D"], {"abc" => "def"}),
      {"A" => { "B" => { "C" => { "D" => {"abc" => "def"} }}}}
    )
  end
  
  def test_insert_hash_value_with_mixed_keys
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}.insert_by_key_path(["A", "B", "C", "D"], {"abc" => "def", :abc => :def, [] => [], {} => {}}),
      {"A" => { "B" => { "C" => { "D" => {"abc" => "def", :abc => :def, [] => [], {} => {} } }}}}
    )
  end
  
  def test_insert_hash_value_with_mixed_nested_keys
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}.insert_by_key_path(["A", "B", "C", "D"], {"abc" => "def", :abc => :def, [] => [], {} => {:A => {:B => "C"}}}),
      {"A" => { "B" => { "C" => { "D" => {"abc" => "def", :abc => :def, [] => [], {} => {:A => {:B => "C" }} } }}}}
    )
  end
  
  def test_insert_symbol_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}.insert_by_key_path(["A", "B", "C", "D"], :xyz),
      {"A" => { "B" => { "C" => { "D" => :xyz }}}}
    )
  end
  
  def test_insert_nested_value
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "xyz" }}}}.insert_by_key_path(["A", "B", "C", "D"], {"x1" => { "x2" => {"x3" => ["A", 'A', :A, [], {}]} }}),
      {"A" => { "B" => { "C" => { "D" => {"x1" => {"x2" => {"x3" => ["A", 'A', :A, [], {}]}}}}}}}
    )
  end
  
  def test_insert_struct_value
    struct = Struct.new(:x)
    assert_equal(
      {"A" => { :B => { :C => { "D" => "XYZ" }}}}.insert_by_key_path(["A", :B, :C, "D"], struct),
      {"A" => { :B => { :C => { "D" => struct }}}}
    )
  end
  
  def test_insert_class_value
    struct = Struct
    assert_equal(
      {"A" => { "B" => { "C" => { "D" => "XYZ" }}}}.insert_by_key_path(["A", "B", "C", "D"], struct),
      {"A" => { "B" => { "C" => { "D" => struct }}}}
    )
  end
  
  ### KEY TYPES
  def test_insert_key_by_path_with_symbol
    assert_equal(
      {:a => { :b => { :c => :d }}}.insert_by_key_path([:a, :b, :c], 99),
      {:a => { :b => { :c => 99 } } }
    )
  end
  
  def test_insert_key_by_path_with_symbol_with_strings_present
    assert_equal(
      {"a" => { "b" => { "c" => :d }}}.insert_by_key_path([:a, :b, :c], 99),
      {"a" => { "b" => { "c" => :d } }, :a => { :b => { :c => 99 } } }
    )
  end
  
  def test_insert_via_path_with_numeric_keys
    assert_equal(
      {1 => { 2 => { 3 => 4 }}}.insert_by_key_path([1, 2, 3], "X"),
      {1 => { 2 => { 3 => "X" } } }
    )
  end
  
  def test_insert_via_path_with_mixed_keys
    assert_equal(
      {1 => { :two => { "three" => 4 }}}.insert_by_key_path([1, :two, "three", :FOUR], 99),
      {1 => { :two => { "three" => { :FOUR => 99 } } } }
    )
  end

  def test_insert_via_path_with_mixed_key_datastructures
    s = Struct.new(:x)
    assert_equal(
      {s => { [] => { {} => { [[[]]] => "A" } }}}.insert_by_key_path([s, [], {}, [[[]]]], "X"),
      {s => { [] => { {} => { [[[]]] => "X" } }}}
    )
  end
  
  def test_insert_via_path_with_hash_key
    assert_equal(
      {"A" => { "B" => { {} => 4 }}}.insert_by_key_path(["A", "B", {}], "X"),
      {"A" => { "B" => { {} => "X" } } }
    )
  end
  
  def test_insert_via_path_with_array_key
    assert_equal(
      {"A" => { "B" => { [] => 4 }}}.insert_by_key_path(["A", "B", []], :array ),
      {"A" => { "B" => { [] => :array } } }
    )
  end
 
  ### COMPEX Hash
  def test_update_nested_key_preserves_keys_at_same_level
    assert_equal(
      {
        "A" => {
          "B" => {
            "C" => {
              "D" => "D2",
              "E" => {
                "F1" => ["F2", "F3"], # TARGET KEY TO CHANGE
                "G1" => "G2"
              },
              "H" => "I",
            },
            "J" => {"K" => "L"}
          },
          "M" => {"N" => {"O" => {"P" => []}}}
        }
      }.insert_by_key_path(["A", "B", "C", "E", "F1"], ["XYZ"]),
      {
        "A" => {
          "B" => {
            "C" => {
              "D" => "D2",
              "E" => {
                "F1" => ["XYZ"], # CHANGED KEY
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
  
  def test_insert_nested_key_preserves_keys_at_same_level
    assert_equal(
      {
        "A" => {
          "B" => {
            "C" => {
              "D" => "D2",
              "E" => {  # INSERT HERE
                "F1" => ["F2", "F3"],
                "G1" => "G2"
              },
              "H" => "I",
            },
            "J" => {"K" => "L"}
          },
          "M" => {"N" => {"O" => {"P" => []}}}
        }
      }.insert_by_key_path(["A", "B", "C", "E", "F2"], "XYZ"),
      {
        "A" => {
          "B" => {
            "C" => {
              "D" => "D2",
              "E" => {
                "F1" => ["F2", "F3"],
                "G1" => "G2",
                "F2" => "XYZ" # INSERTED KEY
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

  def test_insert_into_hash_is_still_value_object
    first  = {"A" => "B"}
    second = {"A" => "B"}

    assert(first == second)
    assert(first === second)

    first.insert_by_key_path(["X1", "X2"], "Y")
    
    assert !(first == second)
    assert !(first === second)
    
    second.insert_by_key_path(["X1", "X2"], "Y")
    
    assert(first == second)
    assert(first === second)
  end

end
