extends Node
class_name AvailablePlayerManager

signal teamless_players_updated
signal saved_players_updated

var available_players: Array[Player] = []
var teamless_players: Array[Player] = []

func load(loaded_available_players: Array[Player], loaded_teams: Array[Team]):
	available_players = loaded_available_players;
	saved_players_updated.emit();
	recheck_teamless_player_list(loaded_teams);

func mark_player_as_available(player: Player) -> void:
	if(not _is_player_in_list(player, available_players)):
		available_players.append(player);
		saved_players_updated.emit();
	if(not _is_player_in_list(player, teamless_players)):
		teamless_players.append(player);		
		teamless_players_updated.emit()
	
func mark_player_as_unavailable(player: Player) -> void:
	if(_is_player_in_list(player, available_players)):
		available_players.erase(player);
	if(_is_player_in_list(player, teamless_players)):
		teamless_players.erase(player);
		teamless_players_updated.emit();
	# remove_player_from_team(player);
	saved_players_updated.emit();

func get_unavailable_players(saved_players: Array[Player]) -> Array[Player]:
	return saved_players.filter(func(x): return not _is_player_in_list(x, available_players));
	
func recheck_teamless_player_list(teams: Array[Team]):
	teamless_players = available_players.filter(func(x): return not _is_player_on_any_team(x, teams));
	teamless_players_updated.emit();
	
func _is_player_in_list(player:Player, player_list: Array[Player]):
	return player_list.map(func(x): return x.name).has(player.name)

func _is_player_on_team(player:Player, team: Team):
	return _is_player_in_list(player, team.players)
	
func _is_player_on_any_team(player: Player, teams: Array[Team]):
	return teams.any(func(x): return _is_player_on_team(player, x))
