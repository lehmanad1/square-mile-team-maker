extends PanelContainer

var player: Player

@onready var label = $HBoxContainer/PlayerName
@onready var attr1Label = $HBoxContainer/GridContainer/Attr1Label
@onready var attr2Label = $HBoxContainer/GridContainer/Attr2Label
@onready var attr3Label = $HBoxContainer/GridContainer/Attr3Label
@onready var attr4Label = $HBoxContainer/GridContainer/Attr4Label
@onready var editPlayerButton = $HBoxContainer/EditPlayerButton
var is_touch_dragging = false

func _ready():
	await get_tree().process_frame

func set_player(new_player: Player):
	player = new_player
	set_player_name()
	set_player_attributes()
	
	
func set_player_name() -> void:
	await ready
	label.text = player.name

func set_player_attributes() -> void:
	await ready
	attr1Label.text = str(player.attr1)
	attr2Label.text = str(player.attr2)
	attr3Label.text = str(player.attr3)
	attr4Label.text = str(player.attr4)

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
