# Array Hash Utils

Useful methods added to Hash and Array classes


## Hash Utils

### `delete_by_key_path(<path>)`

Similar to Hash's `dig` method for retrieving a nested value by a path of keys. Instead of retrieving the value at the deepest key passed, will delete the value.

```
hash = {"A" => { "B" => { "C1" => :deleteme, "C2" => :saveme } } }

hash.delete_by_key_path(["A", "B", "C"])

=> {"A" => { "B" => { "C2" => :saveme } }}
```

Note: If the value is not found, will return self



### `insert_by_key_path(<path>, <value>)`

Similar to Hash's `dig` method for retrieving a nested value by a path of keys, but will set or update the value at the deepest key passed. 

```
hash = {}

hash.insert_by_key_path([:x, :y, :z], "XYZ")

=> {:x => {:y => {:z => "XYZ"}}}
```

```
hash = {:a => { "B" => { [] => "lowercase" } }}

hash.insert_by_key_path([:a, :B, []], "UPPERCASE")

=> {:a => {"B" => { [] => "UPPERCASE"}}}
```

* If keys along the `<path>` do not exist, they will be created
* Keys can be of any type (hash, key, object, class, string, etc)



### `flatten_keys`

Returns all hash keys (including nested keys)

```
hash = {"A" => {"B" => { "C" => "D" , "E" => "F"  } } , "G" => "H" }

hash.flatten_keys

=> ["A", "B", "C", "E", "G"]
```

Note that if keys are repeated, they will appear in the list multiple times



### `flatten_values`

Returns all hash values (included nested values)

```
hash = {"A" => {"B" => { "C" => "D" , "E" => "F"  } } , "G" => "H" }

hash.flatten_values

=> ["D", "F", "H"]
```

Note that if values are repeated, they will appear in the list multiple times



### `flatten_key_values`

A combination of the `flatten_keys` and `flatten_values` methods, returning the full set of all hash keys and values

```
hash = {"A" => {"B" => { "C" => "D" , "E" => "F"  } } , "G" => "H" }

hash.flatten_all

=> ["A", "B", "C", "D", "E", "F", "G", "H"]
```

Note that if keys or values are repeated, they will appear in the list multiple times



### `key_hierarchy`

Return all keys (and nested keys) in hash. Essentially converts each hash and subhash to a tuple of its keys

```
{"A" => "B" , "C" => "D"}.key_hierarchy

  => [["A"], ["C"]]

{"A" => {"B" => "b"} , "C" => {"D" => 'd'}}.key_hierarchy
  => [["A", [["B"]]], ["C", [["D"]]]]

{"A"=>{"B"=>{"C"=>"D", "E"=>"F"}, "x"=>{"y"=>{"z"=>{"q"=>"l"}}}}, "a"=>"b"}.key_hierarchy
  => [["A", [["B", [["C"], ["E"]]], ["x", [["y", [["z", [["q"]]]]]]]]], ["a"]]
```



## Array Utils

### `replace_with(<value>, <new_value>)`

An array method similar to the gsub method on String, which replaces a char with another value `"hello".gsub('e', 3) => "h3llo"`

```
array = ["A", "B", "C", "D", "A", "B", "C", "D"].replace_with("A", "NEW")

array.replace_with("A", "NEW")

=> ["NEW", "B", "C", "D", "NEW", "B", "C", "D"]
```


### `replace_with!(<value>, <new_value>)`

The in place version of the `replace_with` method


## Notes

* Build on Ruby 2.4.0 on macOS
