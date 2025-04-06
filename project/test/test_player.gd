extends GutTest

var Player = preload("res://models/player.gd");

var player: Player;

func test_player_init_and_properties():
	var name = "test";
	var attributes:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	player = Player.new(name, attributes);
	assert_eq(player.name, name);
	assert_eq(player.attributes, attributes);
	
func test_player_export_as_string():
	var name = "test";
	var attributes:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	player = Player.new(name, attributes);
	var player_export_line = player.export_as_string();
	assert_eq(player_export_line, "test,1,10,3,5")

func test_player_get_attribute_total():
	var name = "test";
	var attributes:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	player = Player.new(name, attributes);
	var attribute_total = player.get_attribute_total();
	assert_eq(attribute_total, 19);
