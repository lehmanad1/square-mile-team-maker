extends VBoxContainer

signal add_player_to_team
signal remove_player_from_team

var team: Team = Team.new("", [])

@onready var team_members_container = $TeamMembers

var PlayerPanelScene = preload("res://components/draggable_player_panel.tscn")
var TeamMemberSlotScene = preload("res://components/team_member_slot.tscn");

func _ready():
	_set_text()
	
func set_team(new_team: Team, max_team_size: int):
	await ready
	team = new_team
	_set_text()
	_set_team_members(max_team_size)
	
func _set_text():
	$"TeamName".text = str(team.team_name)

func _add_player_to_team(team_name:String, player:Player):
	add_player_to_team.emit(team_name, player)
	
func _remove_player_from_team(player:Player):
	remove_player_from_team.emit(player)
	
func _set_team_members(max_team_size: int):
	for slot in team_members_container.get_children():
		slot.queue_free();
	for player in team.players:
		var team_member_slot = TeamMemberSlotScene.instantiate(); 
		var new_player_container = PlayerPanelScene.instantiate();
		new_player_container.set_player(player)
		team_member_slot.add_child(new_player_container);
		team_member_slot.connect("dragged_player_to_team", Callable(self, "_add_player_to_team"))
		team_member_slot.connect("dragged_player_from_team", Callable(self, "_remove_player_from_team"))
		team_members_container.add_child(team_member_slot);
	if  max_team_size - team.players.size() > 0:
		for j in max_team_size - team.players.size():
			var team_member_slot = TeamMemberSlotScene.instantiate(); 
			team_member_slot.connect("dragged_player_to_team", Callable(self, "_add_player_to_team"))
			team_member_slot.connect("dragged_player_from_team", Callable(self, "_remove_player_from_team"))
			team_members_container.add_child(team_member_slot);
