extends Window

@onready var create_player_button = $"../UIGridContainer/ButtonRow1/CreatePlayerButton"
@onready var name_input = $"MarginContainer/CreatePlayer/VBoxContainer/HBoxContainer/NameEdit"
@onready var create_player_modal = $MarginContainer/CreatePlayer

func _ready():
	await create_player_button.ready
	create_player_button.pressed.connect(Callable(self, "_on_create_player_button_pressed"))
	create_player_modal.connect("close_popup", Callable(self, "_on_create_player_popup_closed"))
	close_requested.connect(Callable(self, "_on_create_player_popup_closed"));
	
func _on_create_player_button_pressed() -> void:
	show()

func _on_create_player_popup_closed() -> void:
	hide()

func _on_edit_player_button_pressed(player_data: Player) -> void:
	show()
