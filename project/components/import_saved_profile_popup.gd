extends Window

@onready var import_profile_list_button = $"../UIGridContainer/ButtonRow1/ImportProfileButton"
@onready var close_popup_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var import_popup_button = $VBoxContainer/HBoxContainer/ImportButton
@onready var text_edit = $VBoxContainer/MarginContainer/ImportProfileTextEdit

func _ready():
	await import_profile_list_button.ready
	import_profile_list_button.pressed.connect(Callable(self, "_on_import_profile_button_pressed"))
	close_popup_button.connect("pressed", Callable(self, "_on_import_profile_popup_closed"))
	import_popup_button.connect("pressed", Callable(self, "_on_import_profile_popup_closed"))
	close_requested.connect(Callable(self, "_on_import_profile_popup_closed"));
	text_edit.gui_input.connect(Callable(self, "_on_text_gui_input"));
	
func _on_text_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		DisplayServer.virtual_keyboard_hide();

func _close_requested():
	_on_import_profile_popup_closed

func _on_import_profile_button_pressed() -> void:
	show();

func _on_import_profile_popup_closed() -> void:
	hide();
