extends Attribute
class_name AttributeValue

var attribute_value: int = 1;


func _init(name:String = "", weight:int = 0, value:int = 0):
	attribute_name = name;
	attribute_weight = weight;
	attribute_value = value;

func to_dict() -> Dictionary:
	return {
		"attribute_name": attribute_name,
		"attribute_weight": attribute_weight,
		"attribute_value": attribute_value
	}

func from_dict(dict: Dictionary):
	attribute_name = dict["attribute_name"];
	attribute_weight = dict["attribute_weight"];
	attribute_value = dict["attribute_value"];
	return self;
