class_name Player
var name:String = ""

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
	
func export_as_string():
	return "%s,%s,%s,%s,%s" % [name, str(attr1), str(attr2), str(attr3), str(attr4)]

func get_attribute_total():
	return attr1 + attr2 + attr3 + attr4;
