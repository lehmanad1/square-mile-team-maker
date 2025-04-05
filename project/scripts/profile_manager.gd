class_name ProfileManager

signal teamless_players_updated
signal teams_updated
signal saved_players_updated

var allSavedPlayers: Array[Player] = []
var availablePlayers: Array[Player] = []
var teamlessPlayers: Array[Player] = []
var teams: Array[Team] = []
var maxTeams = 6
var teamSize = 8

func import_saved_player_data(saved_players_string: String):
	var imported_players = Array(saved_players_string.split("\n")).map(func(x):
		if x == "":
			return null
		var player_string = x.split(",");
		if player_string.size() < 5:
			return Player.new(player_string[0],1,1,1,1);
		else:
			return Player.new(player_string[0],
			_import_attribute_with_limits(player_string[1]),
			_import_attribute_with_limits(player_string[2]),
			_import_attribute_with_limits(player_string[3]),
			_import_attribute_with_limits(player_string[4])
		)
	);
	allSavedPlayers = [];
	for player in imported_players.filter(func(x): return x != null):
		try_add_saved_player(player);
	
func export_saved_player_data() -> String:
	return "\n".join(PackedStringArray(allSavedPlayers.map(func(x): return x.export_as_string())));
	
func try_add_saved_player(player: Player, is_edit: bool = false, previous_name: String = "") -> bool:
	if previous_name == "":
		previous_name = player.name
	for i in range(allSavedPlayers.size()):
		if allSavedPlayers[i].name == previous_name:
			if is_edit == false or (_is_player_in_list(player, allSavedPlayers) and player.name != previous_name):
				return false;
			else:
				allSavedPlayers[i] = player;
				saved_players_updated.emit();
				return true;
	allSavedPlayers.append(player);
	saved_players_updated.emit();
	return true
	
func mark_player_as_available(player: Player) -> void:
	if(not _is_player_in_list(player, availablePlayers)):
		availablePlayers.append(player);
		saved_players_updated.emit();
	if(not _is_player_in_list(player, teamlessPlayers)):
		teamlessPlayers.append(player);		
		teamless_players_updated.emit()
	
func mark_player_as_unavailable(player: Player) -> void:
	if(_is_player_in_list(player, availablePlayers)):
		availablePlayers.erase(player);
	if(_is_player_in_list(player, teamlessPlayers)):
		teamlessPlayers.erase(player);
		teamless_players_updated.emit();
	remove_player_from_team(player);
	saved_players_updated.emit();

func add_player_to_team(team_name: String, target_player: Player):
	remove_player_from_team(target_player);
	for team in teams:
		if team.team_name == team_name:
			if _is_player_on_team(target_player, team):
				return;
			team.players.append(target_player)
			_emit_teams_update()

func remove_player_from_team(target_player: Player):
	for team in teams:
		for player in team.players:
			if player.name == target_player.name:
				print("removing player: ", player.name);
				team.players.erase(player);
				_emit_teams_update();
				break;

func removed_saved_player(player: Player) -> void:
	# need to add functionality
	pass;

func get_unavailable_players() -> Array[Player]:
	return allSavedPlayers.filter(func(x): return not _is_player_in_list(x, availablePlayers));

func autofill_players_to_teams_randomly():
	if teams.is_empty():
		return
	var players_to_assign: Array[Player] = teamlessPlayers.duplicate(true)
	if players_to_assign.is_empty():
		return
	players_to_assign.shuffle()
	for player in players_to_assign:
		var team_to_add = _get_team_with_least_players()
		if team_to_add != null:
			team_to_add.players.append(player)
		else:
			break
	_emit_teams_update()

func autofill_players_to_team_by_attributes():
	if teams.is_empty():
		return
		
	var players_to_assign: Array[Player] = teamlessPlayers.duplicate(true)
	if players_to_assign.is_empty():
		return

	players_to_assign.sort_custom(func(a:Player,b:Player): return a.get_attribute_total() > b.get_attribute_total())
	for player in players_to_assign:
		var best_team_to_add: Team = null
		var lowest_current_team_score = INF
		for team in teams:
			if team.players.size() >= teamSize:
				continue
			var current_team_total = team.get_attribute_total()
			if current_team_total < lowest_current_team_score:
				lowest_current_team_score = current_team_total
				best_team_to_add = team
		if best_team_to_add != null:
			print("Assigning %s to %s (Current score: %f)" % [player.name, best_team_to_add.team_name, lowest_current_team_score])
			best_team_to_add.players.append(player)	
	_emit_teams_update()	
	
#experimental
func autofill_players_by_pool_variability(variability: int):
	if teams.is_empty():
		printerr("Autofill failed: No teams available.")
		return
		
	var players_to_assign: Array[Player] = teamlessPlayers.duplicate(true) # Work on a copy
	var total_players_to_assign = players_to_assign.size()
	
	if total_players_to_assign == 0:
		print("Autofill: No teamless players to assign.")
		return

	var num_teams = teams.size()
	if num_teams == 0: # Should be caught by the first check, but belts and suspenders
		printerr("Autofill failed: No teams available.")
		return
		
	# --- Calculate Target Team Sizes ---
	# Integer division gives the minimum number of players per team
	var base_size_per_team = total_players_to_assign / num_teams 
	# Modulo gives the number of teams that will get one extra player
	var teams_with_extra_player = total_players_to_assign % num_teams 
	
	print("Autofill Target: %d players for %d teams. Base size: %d, Teams with +1: %d" % [
		total_players_to_assign, num_teams, base_size_per_team, teams_with_extra_player
	])

	# Clear existing players from teams if this function is meant to fully reset teams
	# Comment this out if you are adding to teams that might already have players
	for team in teams:
		team.players.clear() 

	# Clamp variability to the 0-100 range
	var clamped_variability = clamp(variability, 0, 100)

	# Sort players by skill (descending) - helps ensure stronger players are placed first
	players_to_assign.sort_custom(func(a:Player, b:Player): return a.get_attribute_total() > b.get_attribute_total())

	# Track how many teams have received their 'extra' player
	var extra_players_assigned_count = 0

	# --- Assign Players Iteratively ---
	for player in players_to_assign:
		# --- Find and Rank Available Teams based on target sizes ---
		var available_teams_with_scores: Array = [] # Array to store dictionaries: {team: Team, score: float}
		
		for team in teams:
			var current_team_size = team.players.size()
			var team_can_take_extra = (extra_players_assigned_count < teams_with_extra_player)
			
			# Determine if this team is eligible to receive a player
			var is_team_available = false
			if current_team_size < base_size_per_team:
				# Team is below the base size, always available
				is_team_available = true
			elif current_team_size == base_size_per_team and team_can_take_extra:
				# Team is at base size, can take one more if quota for extra players isn't met
				is_team_available = true
				
			if is_team_available:
				var current_score = team.get_attribute_total()
				available_teams_with_scores.append({"team": team, "score": current_score})

		# Sanity check: If no team is available, something is wrong with the logic or input numbers
		if available_teams_with_scores.is_empty():
			printerr("Autofill Error: No available teams found for player %s! Aborting assignment for this player. (Check player/team counts)" % player.name)
			continue # Move to the next player

		# Sort available teams by score (ascending - lower score is better)
		available_teams_with_scores.sort_custom(func(a, b): return a.score < b.score)
		
		# --- Determine Target Team Based on Variability ---
		var target_team: Team = null
		var num_available_now = available_teams_with_scores.size()

		if clamped_variability == 0:
			# Variability 0: Always pick the single best team from the available ones
			target_team = available_teams_with_scores[0].team
			print("Assigning %s optimally (V=0) to %s (Score: %f)" % [player.name, target_team.team_name, available_teams_with_scores[0].score])
		else:
			# Variability > 0: Determine the pool size based on percentage
			var pool_percentage = float(clamped_variability) / 100.0
			var pool_size_float = ceil(num_available_now * pool_percentage) 
			var pool_size = min(num_available_now, int(pool_size_float))
			pool_size = max(1, pool_size) # Ensure at least 1 team in pool if variability > 0

			# Randomly select an index from the calculated pool (top 'pool_size' teams)
			var random_index = randi() % pool_size 
			target_team = available_teams_with_scores[random_index].team
			
			print("Assigning %s from top %d%% pool (size %d/%d) to %s (Score: %f)" % [
				player.name, 
				clamped_variability, 
				pool_size,
				num_available_now,
				target_team.team_name, 
				available_teams_with_scores[random_index].score
			])

		# --- Assign Player and Update Extra Count ---
		if target_team != null:
			# Check if this team was at base size before adding (meaning it just got its extra player)
			if target_team.players.size() == base_size_per_team:
				extra_players_assigned_count += 1
				
			target_team.players.append(player)
		else:
			printerr("Failed to determine target team for player %s" % player.name)
			
	# --- Final Check (Optional Debugging) ---
	print("Autofill Complete. Final team sizes:")
	for team in teams:
		print("- %s: %d players (Score: %f)" % [team.team_name, team.players.size(), team.get_attribute_total()])

	# Emit signal or call update method
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
	teamlessPlayers = availablePlayers.filter(func(x): return not _is_player_on_any_team(x));
	teamless_players_updated.emit();

func _import_attribute_with_limits(attribute: String) -> int:
	var attribute_value: int = int(attribute);
	#todo: just learned what clamp() does, come back here and use it later
	if attribute_value <= 0:
		return 1;
	if attribute_value > 10:
		return 10;
	else: 
		return attribute_value;
	
