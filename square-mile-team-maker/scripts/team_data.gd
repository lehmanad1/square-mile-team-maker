extends Node

signal teamless_players_updated
signal teams_updated
signal saved_players_updated

var allSavedPlayers: Array[Player] = []
var availablePlayers: Array[Player] = []
var teamlessPlayers: Array[Player] = []
var teams: Array[Team] = []
var maxTeams = 6
var teamSize = 8

func _ready():
	await get_parent().ready
	# for i in range(4):  # Loop 17 times
	#	try_add_available_player(Player.new("Player " + str(i+1),0,0,0,0))
	# teamless_players_updated.emit()

func try_add_saved_player(player: Player) -> bool:
	if allSavedPlayers.map(func(x): return x.name).has(player.name):
		return false
	allSavedPlayers.append(player)
	saved_players_updated.emit()
	return true
	
func mark_player_as_available(player: Player) -> void:
	if(_is_player_in_list(player, availablePlayers)):
		return;
	availablePlayers.append(player)
	saved_players_updated.emit()
	
func mark_player_as_unavailable(player: Player) -> void:
	if(_is_player_in_list(player, allSavedPlayers) and not _is_player_in_list(player, availablePlayers)):
		return;
	availablePlayers.erase(player);
	saved_players_updated.emit()

func add_player_to_team(team_name: String, target_player: Player):
	for team in teams:
		if team.team_name == team_name:
			team.players.append(target_player)
			_emit_teams_update()
			
func remove_player_from_team(team_name: String, target_player: Player):
	for team in teams:
		if team.team_name == team_name:
			for player in team.players:
				if player.name == target_player.name:
					team.players.erase(player)
					_emit_teams_update()

func removed_saved_player(player: Player) -> void:
	# need to add functionality
	pass;

func get_unavailable_players() -> Array[Player]:
	return allSavedPlayers.filter(func(x): return not _is_player_in_list(x, availablePlayers));

func autofill_players_to_teams():
	if teams.is_empty():
		return
	var players_to_assign: Array[Player] = teamlessPlayers.duplicate(true)
	players_to_assign.shuffle()
	print(players_to_assign.size())
	for player in players_to_assign:
		var team_to_add = _get_team_with_least_players()
		if team_to_add != null:
			team_to_add.players.append(player)
		else:
			break
	_emit_teams_update()

func add_new_team():
	var totalTeamCount = teams.size() + 1
	var team_name = "Team #" + str(totalTeamCount)
	if totalTeamCount <= 6:
		var new_team = Team.new(team_name, [])
		teams.append(new_team)
		_emit_teams_update()

func reset_teams():
	teams = []
	_emit_teams_update()

func _get_team_with_least_players() -> Team:
	var min_team = teams[0]
	for team in teams:
		if team.players.size() < min_team.players.size():
			min_team = team
	if min_team.players.size() >= teamSize:
		return null
	else:
		return min_team

func _emit_teams_update():
	teams_updated.emit();
	_recheck_teamless_player_list()
	
func _is_player_in_list(player:Player, player_list: Array[Player]):
	return player_list.map(func(x): return x.name).has(player.name)

func _is_player_on_team(player:Player, team: Team):
	return _is_player_in_list(player, team.players)
	
func _is_player_on_any_team(player: Player):
	return teams.any(func(x): return _is_player_on_team(player, x))

func _recheck_teamless_player_list():
	var new_teamlessPlayers = teamlessPlayers.filter(func(x): return not _is_player_on_any_team(x))
	if new_teamlessPlayers.map(func(x): return x.name) == teamlessPlayers.map(func(x): return x.name):
		return
	else:
		teamlessPlayers = new_teamlessPlayers
		teamless_players_updated.emit()
