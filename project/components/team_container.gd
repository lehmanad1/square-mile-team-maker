extends VBoxContainer

signal add_player_to_team
signal remove_player_from_team

var team: Team = Team.new("", [])

@onready var team_members_container = $TeamMembers

var PlayerPanelScene = preload("res://components/draggable_player_panel.tscn")

func _ready():
	for slot_manager in team_members_container.get_children():
		slot_manager.connect("dragged_player_to_team", Callable(self, "_add_player_to_team"))
		slot_manager.connect("dragged_player_from_team", Callable(self, "_remove_player_from_team"))
	_set_text()
	
func set_team(new_team: Team):
	await ready
	team = new_team
	_set_text()
	_set_team_members()
	
func _set_text():
	$"TeamName".text = str(team.team_name)

func _add_player_to_team(team_name:String, player:Player):
	add_player_to_team.emit(team_name, player)
	
func _remove_player_from_team(player:Player):
	remove_player_from_team.emit(player)
	
func _set_team_members():
	for i in team.players.size():
		var new_player_container = PlayerPanelScene.instantiate()
		new_player_container.set_player(team.players[i])
		var team_member_slot = team_members_container.get_child(i)
		for j in team_member_slot.get_child_count():
			team_member_slot.remove_child(team_member_slot.child(j))
		team_member_slot.add_child(new_player_container)
			
