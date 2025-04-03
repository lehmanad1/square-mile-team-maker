extends PopupPanel

@onready var import_player_list_button = $"../UIGridContainer/ButtonRow1/ImportPlayerListButton"
@onready var close_popup_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var import_popup_button = $VBoxContainer/HBoxContainer/ImportButton

func _ready():
	await import_player_list_button.ready
	import_player_list_button.pressed.connect(Callable(self, "_on_import_player_button_pressed"))
	close_popup_button.connect("pressed", Callable(self, "_on_import_player_popup_closed"))
	import_popup_button.connect("pressed", Callable(self, "_on_import_player_popup_closed"))

func _on_import_player_button_pressed() -> void:
	visible = true

func _on_import_player_popup_closed() -> void:
	visible = false
