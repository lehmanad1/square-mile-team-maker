extends Control

signal submit_profile_to_add(profile: Profile);

var attributes_to_add: Array[Attribute] = []

#region attribute nodes
@onready var attribute_name_edit = $MarginContainer/ProfileEditContainer/VBoxContainer3/HBoxContainer/AttributeNameEdit
@onready var attribute_weight_slider = $MarginContainer/ProfileEditContainer/VBoxContainer3/HBoxContainer2/AttributeWeightSlider
@onready var attribute_weight_percent_label = $MarginContainer/ProfileEditContainer/VBoxContainer3/HBoxContainer2/AttributeWeightPercentLabel
@onready var add_or_update_attribute_button = $MarginContainer/ProfileEditContainer/VBoxContainer3/AddOrUpdateAttributeButton
@onready var attribute_validation_label = $MarginContainer/ProfileEditContainer/VBoxContainer3/AttributeValidationLabel
@onready var attribute_list_container = $MarginContainer/ProfileEditContainer/AttributeScrollContainer/AttributeListContainer
#endregion

@onready var save_profile_button = $MarginContainer/ProfileEditContainer/HBoxContainer/SaveProfileButton
@onready var profile_name_edit = $MarginContainer/ProfileEditContainer/VBoxContainer/HBoxContainer/ProfileNameEdit
@onready var profile_team_size = $MarginContainer/ProfileEditContainer/VBoxContainer/HBoxContainer2/MaxTeamSizeSpinBox
@onready var profile_validation_label = $MarginContainer/ProfileEditContainer/ProfileValidationLabel

var editable_attribute_panel:PackedScene = preload("res://components/editable_attribute_panel.tscn");

func _ready():
	await get_tree().process_frame
	_connect_signals();
	
func _connect_signals():
	add_or_update_attribute_button.pressed.connect(Callable(self, "_try_add_attribute"));
	attribute_weight_slider.value_changed.connect(Callable(self, "_adjust_weight_text"));
	save_profile_button.pressed.connect(Callable(self, "_try_save_profile"));

#region profile management
func _try_save_profile():
	var text = profile_name_edit.text;
	if text == "":
		show_profile_validation_text("please enter a profile name");
		return;
	else:
		var new_profile = Profile.new();
		new_profile.attributes = attributes_to_add;
		new_profile.profile_name = text;
		new_profile.max_team_size = profile_team_size.value;
		submit_profile_to_add.emit(new_profile);

func show_profile_validation_text(text:String, failure:bool = true) -> void:
	if failure:
		profile_validation_label.set("theme_override_colors/font_color", Color(255, 0, 0))
	else:
		profile_validation_label.set("theme_override_colors/font_color", Color(0, 255, 0))
	profile_validation_label.text = text
#endregion	
	
#region attribute management
func _try_add_attribute():
	var text = attribute_name_edit.text;
	if text == "":
		_show_attribute_validation_text("please enter an attribute name");
		return;
	if attributes_to_add.map(func(x): return x.attribute_name).has(text):
		_show_attribute_validation_text("attribute already added");
		return;
	var attribute = Attribute.new(text, attribute_weight_slider.value);
	attributes_to_add.append(attribute);
	_redraw_attribute_list();
	
func _redraw_attribute_list():
	for attribute_panel in attribute_list_container.get_children():
		attribute_panel.queue_free();
	for attribute in attributes_to_add:
		var attribute_panel = editable_attribute_panel.instantiate();
		attribute_panel.get_node("HBoxContainer/HBoxContainer/AttributeName").text = attribute.attribute_name;
		attribute_panel.get_node("HBoxContainer/HBoxContainer/AttributeWeight").text = str(attribute.attribute_weight) + "%";
		
		attribute_panel.get_node("HBoxContainer/DeleteAttributeButton").pressed.connect(Callable(self, "_remove_attribute").bind(attribute));
		attribute_list_container.add_child(attribute_panel);
		
func _show_attribute_validation_text(text:String, failure:bool = true) -> void:
	if failure:
		attribute_validation_label.set("theme_override_colors/font_color", Color(255, 0, 0))
	else:
		attribute_validation_label.set("theme_override_colors/font_color", Color(0, 255, 0))
	attribute_validation_label.text = text

func _remove_attribute(attribute: Attribute):
	attributes_to_add.erase(attribute);
	_redraw_attribute_list();
	
func _adjust_weight_text(value:int):
	attribute_weight_percent_label.text = str(value) + "%"
#endregion
