extends Node2D

signal team_size_updated

# TeamCanvasLayer Nodes
@onready var team_canvas_layer = $TeamCanvasLayer
@onready var create_player_modal = $"TeamCanvasLayer/CreatePlayerPopup/CreatePlayer"
@onready var teamless_player_list = $TeamCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/PlayerList
@onready var teams_list = $TeamCanvasLayer/UIGridContainer/MainRow/TeamsListScrollContainer/TeamsList
@onready var profile_manager = $ProfileManager
@onready var create_team_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow1/CreateTeamButton"
@onready var reset_teams_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow1/ResetTeamsButton"
@onready var autofill_teams_randomly_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow2/AutofillTeamsButton"
@onready var autofill_teams_attribute_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow2/AutofillTeamsButton2"
@onready var show_player_canvas_button = $TeamCanvasLayer/UIGridContainer/BottomRow/ShowPlayerCanvasButton
@onready var skill_slider = $TeamCanvasLayer/UIGridContainer/SliderRow/SkillSlider

# PlayerCanvasLayer Nodes
@onready var player_canvas_layer = $PlayerCanvasLayer
@onready var create_saved_player_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/CreatePlayerButton
@onready var available_players_list = $PlayerCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/AvailablePlayerList
@onready var saved_players_list = $PlayerCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer2/SavedPlayerList
@onready var show_team_canvas_button = $PlayerCanvasLayer/UIGridContainer/BottomRow/ShowTeamCanvasButton
@onready var import_players_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/ImportPlayerListButton
@onready var export_players_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/ExportToClipboardButton
@onready var import_saved_players_button = $PlayerCanvasLayer/ImportSavedPlayersPopup/VBoxContainer/HBoxContainer/ImportButton
@onready var import_saved_players_text = $PlayerCanvasLayer/ImportSavedPlayersPopup/VBoxContainer/MarginContainer/TextEdit
@onready var create_player_popup_form = $PlayerCanvasLayer/CreatePlayerPopup/CreatePlayer
@onready var create_player_popup = $PlayerCanvasLayer/CreatePlayerPopup

var PlayerPanelScene = preload("res://components/draggable_player_panel.tscn")
var TeamScene = preload("res://components/team_container.tscn")

var EditablePlayerPanelScene = preload("res://components/draggable_editable_player_panel.tscn")

func _ready():
	await get_tree().process_frame
	if teamless_player_list == null:
		teamless_player_list = $CanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/PlayerList
	
	# TeamCanvas Connections
	profile_manager.connect("teams_updated", Callable(self, "_redraw_teams"))
	profile_manager.connect("teamless_players_updated", Callable(self, "_redraw_teamless_players"))
	create_team_button.pressed.connect(Callable(self, "_add_new_team"))
	reset_teams_button.pressed.connect(Callable(self, "_reset_teams"))
	autofill_teams_randomly_button.pressed.connect(Callable(self, "_autofill_teams_randomly"))
	autofill_teams_attribute_button.pressed.connect(Callable(self, "_autofill_teams_by_attribute"))
	teamless_player_list.connect("remove_player_from_team", Callable(self, "_remove_player_from_team"))
	show_player_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility"))
	
	# PlayerCanvas Connections
	profile_manager.connect("saved_players_updated", Callable(self, "_redraw_player_lists"))
	available_players_list.connect("mark_player_as_available", Callable(self, "_mark_player_as_available"))
	saved_players_list.connect("mark_player_as_unavailable", Callable(self, "_mark_player_as_unavailable"))
	show_team_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility"))
	export_players_button.connect("pressed", Callable(self, "_export_saved_players"))
	import_saved_players_button.connect("pressed", Callable(self, "_import_saved_players"))
#Shared View Methods
func _toggle_canvas_visibility():
	team_canvas_layer.visible = not team_canvas_layer.visible
	player_canvas_layer.visible = not player_canvas_layer.visible
	
func _instantiate_player_panel(player_data: Player, list:Control) -> void:
	var panel = PlayerPanelScene.instantiate()
	panel.set_player(player_data)
	list.add_child(panel)

# Team View Methods
func _add_new_team():
	profile_manager.add_new_team()

func _reset_teams():
	profile_manager.reset_teams();

func _autofill_teams_randomly():
	profile_manager.autofill_players_to_teams_randomly()

func _autofill_teams_by_attribute():
	var variability = skill_slider.value;
	profile_manager.autofill_players_by_pool_variability(variability)

func _create_team() -> void:
	var totalTeamCount = profile_manager.teams.size() + 1
	var team_name = "Team #" + str(totalTeamCount)
	if totalTeamCount < 6:
		var newTeam = TeamScene.instantiate()
		newTeam.team_name = team_name
		teams_list.add_child(newTeam)

func _redraw_teamless_players():
	for child in teamless_player_list.get_children():
		child.queue_free()
	for teamless_player in profile_manager.teamlessPlayers:
		_instantiate_player_panel(teamless_player, teamless_player_list)

func _redraw_teams():
	for child in teams_list.get_children():
		teams_list.remove_child(child)
	for team in profile_manager.teams:
		var container = _instantiate_team_container(team)
		container.connect("add_player_to_team", Callable(profile_manager, "add_player_to_team"))
		container.connect("remove_player_from_team", Callable(profile_manager, "remove_player_from_team"))
		teams_list.add_child(container)
	pass;

func _instantiate_team_container(team:Team) -> VBoxContainer:
	var newTeamScene = TeamScene.instantiate()
	newTeamScene.set_team(team)
	return newTeamScene

func _remove_team() ->  void:
	pass;
	
func _remove_player_from_team(team_name: String, target_player: Player):
	profile_manager.remove_player_from_team(target_player);
	
# Player View Methods
func _mark_player_as_available(player_data: Player):
	profile_manager.mark_player_as_available(player_data);
	
func _mark_player_as_unavailable(player_data: Player):
	profile_manager.mark_player_as_unavailable(player_data);	

func _instantiate_editable_player_panel(player_data: Player):
	var panel = EditablePlayerPanelScene.instantiate()
	panel.set_player(player_data)
	panel.connect("edit_player", Callable(create_player_popup_form, "_load_saved_player"))
	panel.connect("edit_player", Callable(create_player_popup, "_on_edit_player_button_pressed"))
	saved_players_list.add_child(panel)

func _redraw_player_lists():
	_redraw_saved_players_dropdown();
	_redraw_available_players_dropdown();
	
func _redraw_available_players_dropdown():
	for child in available_players_list.get_children():
		available_players_list.remove_child(child);
	for player in profile_manager.availablePlayers:
		print("avail ",player.name)
		_instantiate_player_panel(player, available_players_list);
		
func _redraw_saved_players_dropdown():
	for child in saved_players_list.get_children():
		saved_players_list.remove_child(child);
	for player in profile_manager.get_unavailable_players():
		print("saved ",player.name)
		_instantiate_editable_player_panel(player);

func _import_saved_players():
	profile_manager.import_saved_player_data(import_saved_players_text.text)
																				 
func _export_saved_players():
	var export_string = profile_manager.export_saved_player_data();
	DisplayServer.clipboard_set(export_string);
