extends GutTest

var Team = preload("res://models/team.gd");
var Player = preload("res://models/player.gd");

var team: Team;

func test_team_init_and_properties() -> void:
	var team_name = "Team Name";
	var player = Player.new("Test Player",[]);
	var team = Team.new(team_name, [player]);
	
	assert_eq(team.players[0], player);
	assert_eq(team.team_name, team_name);
	
func test_get_attribute_total() -> void: 
	var team_name = "Team Name";
	var attribute_value_1:AttributeValue = AttributeValue.new("attr1", 100, 5);
	var attribute_value_2:AttributeValue = AttributeValue.new("attr2", 100, 5);
	var attribute_value_3:AttributeValue = AttributeValue.new("attr1", 50, 10);
	var player_1 = Player.new("Test Player", [attribute_value_1, attribute_value_2, attribute_value_3]);
	var player_2 = Player.new("Test Player 2", [attribute_value_1, attribute_value_2, attribute_value_3]);
	
	var team = Team.new(team_name, [player_1, player_2]);
	
	assert_eq(team.get_attribute_total(), 30);
	
