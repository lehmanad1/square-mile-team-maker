extends Control

signal player_saved(new_value:Player)
signal close_popup

@onready var save_button = $VBoxContainer/HBoxContainer6/SavePlayerButton
@onready var close_button = $VBoxContainer/HBoxContainer6/CloseButton
@onready var name_edit = $VBoxContainer/HBoxContainer/NameEdit
@onready var attribute_container = $VBoxContainer/ScrollContainer/AttributeSelectionContainer
@onready var validation_label = $VBoxContainer/ValidationLabel
#todo: this should be redone using signals
@onready var profile_manager = $"%ProfileManager"

var AttributeValueSelectorScene = preload("res://components/player_attribute_container.tscn");

var editable = false
var previous_name = ""

func _ready():
	save_button.connect("pressed", Callable(self, "_on_save_player_button_pressed"));
	close_button.connect("pressed", Callable(self, "_close_button_pressed"));
	name_edit.connect("gui_input", Callable(self, "_on_text_gui_input"));
	get_parent().get_parent().connect("close_requested", Callable(self, "_clear_input"));
	if not profile_manager:
		await profile_manager.ready;
	profile_manager.saved_players_updated.connect(Callable(self, "_create_new_attribute_list"));

func _close_button_pressed() -> void:
	emit_signal("close_popup")
	

func _on_save_player_button_pressed(close:bool = true) -> void:
	if name_edit.text == "":
		_show_validation_text("Please enter a name for this player")
		return
	
	var attribute_values: Array[AttributeValue] = [];
	
	for attribute_value_selector in attribute_container.get_children():
		var attribute_name = attribute_value_selector.get_node("AttributeLabel").text
		var attribute_value = attribute_value_selector.get_node("AttributeEdit").value
		var found_attribute_index = profile_manager.attributes.find_custom(func(x): return x.attribute_name == attribute_name);
		if found_attribute_index <= -1:
			return;
		
		var attribute_weight = profile_manager.attributes[found_attribute_index].attribute_weight
		attribute_values.append(AttributeValue.new(attribute_name, attribute_weight, attribute_value))
		
	var player_data = Player.new(
		name_edit.text,
		attribute_values
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
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		DisplayServer.virtual_keyboard_hide();
	
func _show_validation_text(text:String, failure:bool = true) -> void:
	if failure:
		validation_label.set("theme_override_colors/font_color", Color(255, 0, 0))
	else:
		validation_label.set("theme_override_colors/font_color", Color(0, 255, 0))
	validation_label.text = text

func _load_saved_player(player_data: Player):
	previous_name = player_data.name;
	name_edit.text = player_data.name;
	_reset_attribute_list(player_data.attributes);
	editable = true

func create_new_attribute_list():
	var attribute_values: Array[AttributeValue] = [];
	attribute_values.assign(profile_manager.attributes.map(func(x): return AttributeValue.new(x.attribute_name, x.attribute_weight, 1)))
	_reset_attribute_list(attribute_values);

func _reset_attribute_list(attributes: Array[AttributeValue]):
	for attribute_item in attribute_container.get_children():
		attribute_item.queue_free()
	for attribute in attributes:
		_instantiate_player_attribute_container(attribute);

func _instantiate_player_attribute_container(attribute: AttributeValue):
	var attribute_value_selector = AttributeValueSelectorScene.instantiate();
	attribute_value_selector.get_node("AttributeLabel").text = attribute.attribute_name
	attribute_value_selector.get_node("AttributeEdit").value = attribute.attribute_value if attribute.attribute_value != null else 0
	attribute_value_selector.get_node("AttributeEdit").connect("gui_input", Callable(self, "_on_text_gui_input"));
	attribute_container.add_child(attribute_value_selector)

func _clear_input() -> void:
	_show_validation_text("", false)
	name_edit.text = ""
	create_new_attribute_list()
	editable = false
	previous_name = ""
