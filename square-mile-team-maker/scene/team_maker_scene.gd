extends Node2D

signal team_size_updated

# TeamCanvasLayer Nodes
@onready var create_player_modal = $"TeamCanvasLayer/CreatePlayerPopup/CreatePlayer"
@onready var teamless_player_list = $TeamCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/PlayerList
@onready var teams_list = $TeamCanvasLayer/UIGridContainer/MainRow/TeamsListScrollContainer/TeamsList
@onready var team_data = $TeamData
@onready var create_team_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow1/CreateTeamButton"
@onready var reset_teams_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow1/ResetTeamsButton"
@onready var autofill_teams_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow2/AutofillTeamsButton"

# PlayerCanvasLayer Nodes
@onready var create_saved_player_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/CreatePlayerButton

var PlayerPanelScene = preload("res://components/draggable_player_panel.tscn")
var TeamScene = preload("res://components/team_container.tscn")

func _ready():
	await get_tree().process_frame
	if teamless_player_list == null:
		teamless_player_list = $CanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/PlayerList
	
	# TeamCanvas Connections
	team_data.connect("teams_updated", Callable(self, "_redraw_teams"))
	team_data.connect("teamless_players_updated", Callable(self, "_redraw_teamless_players"))
	create_team_button.pressed.connect(Callable(self, "_add_new_team"))
	reset_teams_button.pressed.connect(Callable(self, "_reset_teams"))
	autofill_teams_button.pressed.connect(Callable(self, "_autofill_teams"))
	teamless_player_list.connect("remove_player_from_team", Callable(self, "_remove_player_from_team"))
	
	# PlayerCanvas Connections
	
	_redraw_teamless_players()
	_redraw_teams()

func _instantiate_player_panel(player_data: Player) -> void:
	var panel = PlayerPanelScene.instantiate()
	panel.set_player(player_data)
	teamless_player_list.add_child(panel)

func _add_new_team():
	team_data.add_new_team()

func _reset_teams():
	team_data.reset_teams();

func _autofill_teams():
	team_data.autofill_players_to_teams()

func _create_team() -> void:
	var totalTeamCount = team_data.teams.size() + 1
	var team_name = "Team #" + str(totalTeamCount)
	if totalTeamCount < 6:
		var newTeam = TeamScene.instantiate()
		newTeam.team_name = team_name
		teams_list.add_child(newTeam)

func _redraw_teamless_players():
	for child in teamless_player_list.get_children():
		child.queue_free()
	for teamless_player in team_data.teamlessPlayers:
		_instantiate_player_panel(teamless_player)

func _redraw_teams():
	for child in teams_list.get_children():
		teams_list.remove_child(child)
	for team in team_data.teams:
		var container = _instantiate_team_container(team)
		container.connect("add_player_to_team", Callable(team_data, "add_player_to_team"))
		container.connect("remove_player_from_team", Callable(team_data, "remove_player_from_team"))
		teams_list.add_child(container)
	pass;

func _instantiate_team_container(team:Team) -> VBoxContainer:
	var newTeamScene = TeamScene.instantiate()
	newTeamScene.set_team(team)
	return newTeamScene

func _remove_team() ->  void:
	pass;
	
func _remove_player_from_team(team_name: String, target_player: Player):
	team_data.remove_player_from_team(team_name, target_player);
