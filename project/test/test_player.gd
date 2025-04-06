extends GutTest

var Player = preload("res://models/player.gd");

var player: Player;

func test_player_init_and_properties():
	var name = "test";
	var attributes = [1, 10, 3, 5];
	player = Player.new(name, attributes[0], attributes[1], attributes[2], attributes[3]);
	assert_eq(player.name, name);
	assert_eq(player.attr1, attributes[0]);
	assert_eq(player.attr2, attributes[1]);
	assert_eq(player.attr3, attributes[2]);
	assert_eq(player.attr4, attributes[3]);
	
func test_player_export_as_string():
	var name = "test";
	var attributes = [1, 10, 3, 5];
	player = Player.new(name, attributes[0], attributes[1], attributes[2], attributes[3]);
	var player_export_line = player.export_as_string();
	assert_eq(player_export_line, "test,1,10,3,5")

func test_player_get_attribute_total():
	var name = "test";
	var attributes = [1, 10, 3, 5];
	player = Player.new(name, attributes[0], attributes[1], attributes[2], attributes[3]);
	var attribute_total = player.get_attribute_total();
	assert_eq(attribute_total, 19);
