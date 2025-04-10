extends Window

@onready var import_player_list_button = $"../UIGridContainer/ButtonRow1/ImportPlayerListButton"
@onready var close_popup_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var import_popup_button = $VBoxContainer/HBoxContainer/ImportButton
@onready var text_edit = $VBoxContainer/MarginContainer/TextEdit

func _ready():
	await import_player_list_button.ready
	import_player_list_button.pressed.connect(Callable(self, "_on_import_player_button_pressed"))
	close_popup_button.connect("pressed", Callable(self, "_on_import_player_popup_closed"))
	import_popup_button.connect("pressed", Callable(self, "_on_import_player_popup_closed"))
	text_edit.connect("gui_input", Callable(self, "_on_text_gui_input"));
	
func _on_text_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		DisplayServer.virtual_keyboard_hide();
		
func _on_import_player_button_pressed() -> void:
	visible = true

func _on_import_player_popup_closed() -> void:
	visible = false
