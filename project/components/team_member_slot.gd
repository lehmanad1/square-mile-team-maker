extends PanelContainer

signal dragged_player_to_team(team_name: String, player: Player)
signal dragged_player_from_team(team_name: String, player: Player)

func _try_add_player_to_team(item, target):
	if item is PanelContainer and "player" in item and "team" in target.get_parent().get_parent():
		dragged_player_to_team.emit(target.get_parent().get_parent().team.team_name, item.player)
		
func _try_remove_player_from_team(item, target):
	if item is PanelContainer and "player" in item and "team" in target.get_parent().get_parent():
		dragged_player_from_team.emit(item.player)
		
func _can_drop_data(position, data):
	return true

func _drop_data(position, data):

	var dragged_item = data["item"]
	if !dragged_item:
		printerr("Error: No dragged item found in data.")
		return
	
	var existing_items = get_children()
	#var target_index = -1
	var target_item = null
	var min_distance = INF
	var local_pos = get_local_mouse_position()  # Convert position to local coordinates

	# Iterate through existing items to find the closest one
	for i in range(existing_items.size()):
		var item = existing_items[i]
		var item_rect = item.get_global_rect()

		if item_rect.has_point(position):  # Try local_pos if this still fails
			target_item = item
			break

		# Alternative: Find the item closest to drop position
		var item_center = item_rect.position + (item_rect.size / 2)
		var distance = item_center.distance_to(position)

		if distance < min_distance:
			min_distance = distance
			target_item = item

	var original_parent = dragged_item.get_parent()
	
	# Ensure swapping instead of just moving
	if target_item and target_item != dragged_item:

		# Remove both items from their current parents
		if original_parent:
			_try_remove_player_from_team(dragged_item, original_parent)
			
		_try_remove_player_from_team(target_item, self)

		# Swap positions
		_try_add_player_to_team(dragged_item, self)
		
		if original_parent:
			_try_add_player_to_team(target_item, original_parent)
	else:
		# Default behavior if there's no existing item at the position
		if original_parent:
			_try_remove_player_from_team(dragged_item, original_parent)

		# add_child(dragged_item)
		_try_add_player_to_team(dragged_item, self)
		
		
	
