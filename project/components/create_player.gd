extends Control

signal player_saved(new_value:Player)
signal close_popup

@onready var save_button = $VBoxContainer/HBoxContainer6/SavePlayerButton
@onready var close_button = $VBoxContainer/HBoxContainer6/CloseButton
@onready var name_edit = $VBoxContainer/HBoxContainer/NameEdit
@onready var attr1_edit = $VBoxContainer/HBoxContainer2/Attr1Edit
@onready var attr2_edit = $VBoxContainer/HBoxContainer3/Attr2Edit
@onready var attr3_edit = $VBoxContainer/HBoxContainer4/Attr3Edit
@onready var attr4_edit = $VBoxContainer/HBoxContainer5/Attr4Edit
@onready var validation_label = $VBoxContainer/ValidationLabel
@onready var profile_manager = $"../../../ProfileManager"

var editable = false
var previous_name = ""

func _ready():
	save_button.connect("pressed", Callable(self, "_on_save_player_button_pressed"));
	close_button.connect("pressed", Callable(self, "_close_button_pressed"));
	name_edit.connect("gui_input", Callable(self, "_on_text_gui_input"));
	get_parent().connect("close_requested", Callable(self, "_clear_input"));

func _close_button_pressed() -> void:
	emit_signal("close_popup")
	

func _on_save_player_button_pressed(close:bool = true) -> void:
	if name_edit.text == "":
		_show_validation_text("Please enter a name for this player")
		return
	
	var player_data = Player.new(
		name_edit.text,
		attr1_edit.value,
		attr2_edit.value,
		attr3_edit.value,
		attr4_edit.value
	)
	if profile_manager.try_add_saved_player(player_data, editable, previous_name):
		emit_signal("player_saved", player_data)
		_clear_input()
		if close:
			emit_signal("close_popup")
		else:
			_show_validation_text("Player Added", false)
	else:
		_show_validation_text("Please choose a different name for this player")

func _on_text_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		_show_validation_text("", false)
		
func _show_validation_text(text:String, failure:bool = true) -> void:
	if failure:
		validation_label.set("theme_override_colors/font_color", Color(255, 0, 0))
	else:
		validation_label.set("theme_override_colors/font_color", Color(0, 255, 0))
	validation_label.text = text

func _load_saved_player(player_data: Player):
	previous_name = player_data.name;
	name_edit.text = player_data.name;
	attr1_edit.value = player_data.attr1;
	attr2_edit.value = player_data.attr2;
	attr3_edit.value = player_data.attr3;
	attr4_edit.value = player_data.attr4;
	editable = true

func _clear_input() -> void:
	print("clearing input")
	_show_validation_text("", false)
	name_edit.text = ""
	attr1_edit.value = 0
	attr2_edit.value = 0
	attr3_edit.value = 0
	attr4_edit.value = 0
	editable = false
	previous_name = ""
