extends PopupPanel

@onready var create_profile_button = $"../UIGridContainer/ButtonRow2/AddNewProfileButton"
@onready var close_popup_button = $CreateProfile/MarginContainer/ProfileEditContainer/HBoxContainer/ClosePopupButton

func _ready():
	if not create_profile_button:
		await create_profile_button.ready
	create_profile_button.pressed.connect(Callable(self, "_on_create_profile_button_pressed"));
	close_popup_button.pressed.connect(Callable(self, "_on_create_profile_popup_closed"));

func _on_create_profile_button_pressed() -> void:
	visible = true

func _on_create_profile_popup_closed() -> void:
	visible = false
