extends PanelContainer

signal edit_player

var player: Player
var is_touch_dragging = false

@onready var label = $HBoxContainer/PlayerName
@onready var editPlayerButton = $HBoxContainer/EditPlayerButton
@onready var attr_total_label = $HBoxContainer/AttrTotalLabel

func _ready():
	await get_tree().process_frame
	editPlayerButton.pressed.connect(Callable(self, "_set_player_to_edit"))

func set_player(new_player: Player):
	player = new_player
	set_player_name()
	set_player_attributes()
	
	
func set_player_name() -> void:
	await ready
	label.text = player.name

func set_player_attributes() -> void:
	await ready
	attr_total_label.text = str(player.get_attribute_total())

func _can_drop_data(position, data):
	return true
	
func _gui_input(event):
	# Mouse-based dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		start_drag()
	
	# Touch-based dragging
	elif event is InputEventScreenTouch and event.pressed:
		is_touch_dragging = true

	elif event is InputEventScreenDrag and is_touch_dragging:
		is_touch_dragging = false  # Prevent multiple calls
		start_drag()

func start_drag():
	var drag_preview = self.duplicate()
	drag_preview.modulate = Color(1, 1, 1, 0.5)
	set_drag_preview(drag_preview)

func _get_drag_data(position):
	var drag_preview = self.duplicate()
	drag_preview.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent preview
	drag_preview.size = self.size  # Ensure it keeps the original size
	drag_preview.visible = true  # Make sure it's not hidden

	set_drag_preview(drag_preview)  # Set the preview inside _get_drag_data()
	return { "item": self }

func _drop_data(position, data):
	# Call the parent container's _drop_data function
	var parent_container = get_parent()
	if parent_container and parent_container.has_method("_drop_data"):
		parent_container._drop_data(position, data)
		
func _set_player_to_edit():
	edit_player.emit(player)
