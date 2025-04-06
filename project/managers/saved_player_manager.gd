extends Node
class_name SavedPlayerManager

signal saved_players_updated;

var saved_players: Array[Player] = [];

func load(loaded_saved_players: Array[Player]):
	saved_players = loaded_saved_players;
	saved_players_updated.emit();

func import_saved_player_data(saved_players_string: String, attributes: Array[Attribute]):
	var imported_players = Array(saved_players_string.split("\n")).map(func(x):
		if x == "":
			return null
		var player_string: Array = x.split(",");
		var player_name = player_string.pop_front();
		
		var attribute_values: Array[AttributeValue] = [];
		
		for attribute in attributes:
			if player_string.size() == 0:
				break;
			var attribute_value = clamp(int(player_string.pop_front()), 0, 100);
			attribute_values.append(AttributeValue.new(attribute.attribute_name, attribute.attribute_weight, attribute_value));
			
		return Player.new(player_name,attribute_values);
	);
	saved_players = [];
	for player in imported_players.filter(func(x): return x != null):
		try_add_saved_player(player);
	
func export_saved_player_data() -> String:
	return "\n".join(PackedStringArray(saved_players.map(func(x): return x.export_as_string())));
	
func try_add_saved_player(player: Player, is_edit: bool = false, previous_name: String = "") -> bool:
	if previous_name == "":
		previous_name = player.name
	for i in range(saved_players.size()):
		if saved_players[i].name == previous_name:
			if is_edit == false or (_is_player_in_list(player, saved_players) and player.name != previous_name):
				return false;
			else:
				saved_players[i] = player;
				saved_players_updated.emit();
				return true;
	saved_players.append(player);
	saved_players_updated.emit();
	return true


func removed_saved_player(player: Player) -> void:
	# need to add functionality
	pass;

func _is_player_in_list(player:Player, player_list: Array[Player]):
	return player_list.map(func(x): return x.name).has(player.name)
