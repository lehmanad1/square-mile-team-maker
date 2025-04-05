class_name Player
var name:String = ""

var attributes:Array[AttributeValue] = [];

var attr1:int = 1
var attr2:int = 1
var attr3:int = 1
var attr4:int = 1

func _init(n="",a1=0,a2=0,a3=0,a4=0):
	name = n
	attr1 = a1
	attr2 = a2
	attr3 = a3
	attr4 = a4
	attributes = [AttributeValue.new("", 100, a1), AttributeValue.new("", 100, a2), AttributeValue.new("", 100, a3), AttributeValue.new("", 100, a4)]
	
func export_as_string():
	var export_items = [name]
	export_items.append_array(attributes.map(func(x): return x.attribute_value))
	return ",".join(export_items);

func get_attribute_total():
	return attributes.map(func(x): return x.attribute_value).reduce(func(acc, x): return acc+x, 0);
