class_name Player
var name:String = ""

var attributes:Array[AttributeValue] = [];

func _init(n="", attrs: Array[AttributeValue] = []):
	name = n
	attributes = attrs
	
func export_as_string():
	var export_items = [name]
	export_items.append_array(attributes.map(func(x): return x.attribute_value))
	return ",".join(export_items);

func get_attribute_total() -> float:
	return attributes.reduce(
		func(acc, x):
			return acc+(x.attribute_value * x.attribute_weight/100),
		0);

func to_dict() -> Dictionary:
	return {
		"name": name,
		"attributes": attributes.map(func(a): return a.to_dict())
	}

func from_dict(dict: Dictionary):
	name = dict["name"];
	attributes.assign(dict["attributes"].map(func(a): return AttributeValue.new().from_dict(a)))
	return self;
