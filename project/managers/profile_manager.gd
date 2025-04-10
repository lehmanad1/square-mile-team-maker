extends Node
class_name ProfileManager

#region signals
signal teamless_players_updated
signal teams_updated
signal saved_players_updated
signal saved_profiles_updated
signal save_requested
#endregion

#region managers
@onready var saved_player_manager = $SavedPlayerManager;
@onready var available_player_manager = $AvailablePlayerManager;
@onready var team_manager = $TeamManager;
@onready var attributes_manager = $AttributesManager;
@onready var saved_profiles_manager = $SavedProfilesManager;
#endregion

#region getters
var attributes: Array[Attribute] :
	get:
		return attributes_manager.attributes

var saved_players: Array[Player] :
	get:
		return saved_player_manager.saved_players;

var available_players: Array[Player] :
	get:
		return available_player_manager.available_players;

var teamless_players: Array[Player] :
	get:
		return available_player_manager.teamless_players;
		
var teams: Array[Team] :
	get:
		return team_manager.teams;
		
var saved_profiles: Array[Profile] :
	get:
		return saved_profiles_manager.saved_profiles;

var active_profile: Profile :
	get:
		return saved_profiles_manager.active_profile;

var max_team_size: int : 
	get:
		return saved_profiles_manager.active_profile.max_team_size;

#endregion

#region setup funcs
func _ready():
	await get_tree().process_frame
	await _await_child_node(saved_player_manager)
	await _await_child_node(available_player_manager)
	await _await_child_node(team_manager)
	
	_manage_child_signals();
	
func _await_child_node(node: Node):
	if not node:
		await node.ready

func _manage_child_signals():
	saved_player_manager.saved_players_updated.connect(Callable(self, "_emit_saved_players_updated"));
	available_player_manager.saved_players_updated.connect(Callable(self, "_emit_saved_players_updated"));
	available_player_manager.teamless_players_updated.connect(Callable(self, "_emit_teamless_players_updated"));
	team_manager.teams_updated.connect(Callable(self,"_emit_teams_update"));
	saved_profiles_manager.saved_profiles_updated.connect(Callable(self,"_emit_saved_profiles_updated"));
	saved_profiles_manager.switch_active_profile.connect(Callable(self, "load_active_profile"));
#endregion

#region profile management
func set_active_profile(profile:Profile):
	saved_profiles_manager.set_active_profile(profile);

func load_active_profile():
	load_profile(active_profile);

func load_profile(profile: Profile) -> void:
	attributes_manager.load(profile.attributes);
	saved_player_manager.load(profile.saved_players);
	team_manager.load(profile.teams);
	available_player_manager.load(profile.available_players, profile.teams);
	teamless_players_updated.emit();
	teams_updated.emit();
	saved_players_updated.emit();
	_resync_active_profile();

func export_profile() -> Profile:
	var profile = Profile.new();
	profile.profile_name = active_profile.profile_name;
	profile.teams = teams;
	profile.saved_players = saved_players;
	profile.available_players = available_players;
	profile.attributes = attributes;
	profile.max_team_size = max_team_size;
	return profile;
	
func try_add_saved_profile(profile: Profile) -> bool:
	return saved_profiles_manager.try_add_profile(profile);

func delete_profile(profile: Profile):
	saved_profiles_manager.delete_profile(profile);

func _resync_active_profile():
	saved_profiles_manager.resync_active_profile(export_profile());

func _emit_saved_profiles_updated():
	saved_profiles_updated.emit();
	save_requested.emit();
	print("save requested at _emit_saved_profiles_updated");
#endregion

#region saved_player_manager passthroughs
func import_saved_player_data(saved_players_string: String):
	return saved_player_manager.import_saved_player_data(saved_players_string, attributes);
	
func export_saved_player_data() -> String:
	return saved_player_manager.export_saved_player_data();
	
func try_add_saved_player(player: Player, is_edit: bool = false, previous_name: String = "") -> bool:
	return saved_player_manager.try_add_saved_player(player, is_edit, previous_name);

func delete_player(player: Player):
	saved_player_manager.removed_saved_player(player);

func _emit_saved_players_updated():
	saved_players_updated.emit();
	save_requested.emit();
	print("save requested at _emit_saved_players_updated");
#endregion

#region available_player_manager passthroughs
func mark_player_as_available(player: Player) -> void:
	available_player_manager.mark_player_as_available(player);
	
func mark_player_as_unavailable(player: Player) -> void:
	available_player_manager.mark_player_as_unavailable(player);

func get_unavailable_players() -> Array[Player]:
	return available_player_manager.get_unavailable_players(saved_players);

func _recheck_teamless_player_list():
	available_player_manager.recheck_teamless_player_list(teams);
	
func _emit_teamless_players_updated():
	teamless_players_updated.emit();
	_resync_active_profile();
#endregion

#region teams_manager passthroughs
func add_player_to_team(team_name: String, target_player: Player):
	team_manager.add_player_to_team(team_name, target_player);

func remove_player_from_team(target_player: Player):
	team_manager.remove_player_from_team(target_player);

func autofill_players_by_pool_variability(variability: int):
	team_manager.autofill_players_by_pool_variability(variability, available_players.size(), teamless_players, max_team_size);

func add_new_team():
	team_manager.add_new_team();

func remove_team():
	team_manager.remove_team();

func reset_teams():
	team_manager.reset_teams();

func _emit_teams_update():
	teams_updated.emit();
	_recheck_teamless_player_list();
	
func _is_player_in_list(player:Player, player_list: Array[Player]):
	return player_list.map(func(x): return x.name).has(player.name)

func _is_player_on_team(player:Player, team: Team):
	return _is_player_in_list(player, team.players)
	
func _is_player_on_any_team(player: Player):
	return teams.any(func(x): return _is_player_on_team(player, x))

#endregion	
