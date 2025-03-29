extends PopupPanel

@onready var create_player_button = $"../UIGridContainer/ButtonRow1/CreatePlayerButton"
@onready var name_input = $"CreatePlayer/VBoxContainer/HBoxContainer/NameEdit"
@onready var create_player_modal = $CreatePlayer

func _ready():
	await create_player_button.ready
	create_player_button.pressed.connect(Callable(self, "_on_create_player_button_pressed"))
	create_player_modal.connect("close_popup", Callable(self, "_on_create_player_popup_closed"))

func _on_create_player_button_pressed() -> void:
	visible = true
	name_input.grab_focus()

func _on_create_player_popup_closed() -> void:
	visible = false
