extends Control

signal player_saved(new_value:Player)

@onready var save_button = $VBoxContainer/HBoxContainer6/SavePlayerButton
@onready var name_edit = $VBoxContainer/HBoxContainer/NameEdit
@onready var attr1_edit = $VBoxContainer/HBoxContainer2/Attr1Edit
@onready var attr2_edit = $VBoxContainer/HBoxContainer3/Attr2Edit
@onready var attr3_edit = $VBoxContainer/HBoxContainer4/Attr3Edit
@onready var attr4_edit = $VBoxContainer/HBoxContainer5/Attr4Edit
@onready var team_data = $"../../TeamData"

func _ready():
	save_button.connect("pressed", Callable(self, "_on_save_player_button_pressed"));
	var result = name_edit.connect("gui_input", Callable(self, "_on_text_gui_input"))
	print(result)

func _on_save_player_button_pressed() -> void:
	var player_data = Player.new(
		name_edit.text,
		attr1_edit.text,
		attr2_edit.text,
		attr3_edit.text,
		attr4_edit.text
	)
	if team_data.try_add_available_player(player_data):
		emit_signal("player_saved", player_data)
		name_edit.text = ""

func _on_text_gui_input(event: InputEvent) -> void:
	print("attr1_edit")
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		_on_save_player_button_pressed()
		get_viewport().set_input_as_handled()  # Prevents Enter from adding a new line
