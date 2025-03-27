extends Node

signal remove_player_from_team

func _can_drop_data(position, data):
	return true
	
func _drop_data(position, data):
	print("attempting drop")
	var dragged_item = data["item"]
	if !dragged_item:
		print("Error: No dragged item found in data.")
		return
		
	var original_parent = dragged_item.get_parent()
	
	if dragged_item is PanelContainer and "player" in dragged_item and "team" in original_parent.get_parent().get_parent():
		remove_player_from_team.emit(original_parent.get_parent().get_parent().team.team_name, dragged_item.player)
	
