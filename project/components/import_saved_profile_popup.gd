extends Window

@onready var import_profile_list_button = $"../UIGridContainer/ButtonRow1/ImportProfileButton"
@onready var close_popup_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var import_popup_button = $VBoxContainer/HBoxContainer/ImportButton

func _ready():
	await import_profile_list_button.ready
	import_profile_list_button.pressed.connect(Callable(self, "_on_import_profile_button_pressed"))
	close_popup_button.connect("pressed", Callable(self, "_on_import_profile_popup_closed"))
	import_popup_button.connect("pressed", Callable(self, "_on_import_profile_popup_closed"))
	close_requested.connect(Callable(self, "_on_import_profile_popup_closed"));

func _close_requested():
	_on_import_profile_popup_closed

func _on_import_profile_button_pressed() -> void:
	show();

func _on_import_profile_popup_closed() -> void:
	hide();
