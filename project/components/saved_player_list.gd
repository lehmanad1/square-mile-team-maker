extends Node

signal mark_player_as_unavailable(player_data:Player)

func _can_drop_data(position, data):
	return true
	
func _drop_data(position, data):
	var dragged_item = data["item"]
	if !dragged_item:
		return
		
	var original_parent = dragged_item.get_parent()
	
	if dragged_item is PanelContainer and "player" in dragged_item:
		mark_player_as_unavailable.emit(dragged_item.player)
