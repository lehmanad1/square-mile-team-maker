extends Control

var attributes_to_add: Array[Attribute] = []

@onready var attribute_name_edit = $MarginContainer/ProfileEditContainer/VBoxContainer3/HBoxContainer/AttributeNameEdit
@onready var attribute_weight_slider = $MarginContainer/ProfileEditContainer/VBoxContainer3/HBoxContainer2/AttributeWeightSlider
@onready var attribute_weight_percent_label = $MarginContainer/ProfileEditContainer/VBoxContainer3/HBoxContainer2/AttributeWeightPercentLabel
@onready var add_or_update_attribute_button = $MarginContainer/ProfileEditContainer/VBoxContainer3/AddOrUpdateAttributeButton
@onready var attribute_validation_label = $MarginContainer/ProfileEditContainer/VBoxContainer3/AttributeValidationLabel
@onready var attribute_list_container = $MarginContainer/ProfileEditContainer/AttributeScrollContainer/AttributeListContainer

var editable_attribute_panel:PackedScene = preload("res://components/editable_attribute_panel.tscn");

func _ready():
	await get_tree().process_frame
	_connect_signals();
	
func _connect_signals():
	add_or_update_attribute_button.pressed.connect(Callable(self, "_try_add_attribute"));
	attribute_weight_slider.value_changed.connect(Callable(self, "_adjust_weight_text"));

func _try_add_attribute():
	var text = attribute_name_edit.text;
	#if text == "":
	#	_show_attribute_validation_text("please enter an attribute name");
	#	return;
	#if attributes_to_add.map(func(x): return x.attribute_name).has(text):
	#	_show_attribute_validation_text("attribute already added");
	#	return;
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
	print("attempting to remove attribute");
	attributes_to_add.erase(attribute);
	_redraw_attribute_list();
	
func _adjust_weight_text(value:int):
	attribute_weight_percent_label.text = str(value) + "%"
