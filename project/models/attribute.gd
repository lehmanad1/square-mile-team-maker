class_name Attribute

var attribute_name: String = ""
var attribute_weight: int = 0


func _init(name:String = "", weight:int = 0):
	attribute_name = name;
	attribute_weight = weight;

func to_dict() -> Dictionary:
	return {
		"attribute_name": attribute_name,
		"attribute_weight": attribute_weight
	}

func from_dict(dict: Dictionary):
	attribute_name = dict["attribute_name"];
	attribute_weight = dict["attribute_weight"];
	return self;
