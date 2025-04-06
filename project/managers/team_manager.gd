extends Node

signal teams_updated;

var teams: Array[Team] = []

func load(load_teams: Array[Team]):
	teams = load_teams;
	teams_updated.emit();

func add_player_to_team(team_name: String, target_player: Player):
	remove_player_from_team(target_player);
	for team in teams:
		if team.team_name == team_name:
			if _is_player_on_team(target_player, team):
				return;
			team.players.append(target_player)
			teams_updated.emit();

func remove_player_from_team(target_player: Player):
	for team in teams:
		for player in team.players:
			if player.name == target_player.name:
				team.players.erase(player);
				teams_updated.emit();
				break;

func removed_saved_player(player: Player) -> void:
	# need to add functionality
	pass;

func autofill_players_by_pool_variability(variability: int, teamless_players: Array[Player]):
	if teams.is_empty():
		printerr("Autofill failed: No teams available.")
		return
		
	var players_to_assign: Array[Player] = teamless_players.duplicate(true) # Work on a copy
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
	teams_updated.emit();

func add_new_team():
	var totalTeamCount = teams.size() + 1
	var team_name = "Team #" + str(totalTeamCount)
	if totalTeamCount <= 6:
		var new_team = Team.new(team_name, [])
		teams.append(new_team)
		teams_updated.emit();

func reset_teams():
	teams = []
	teams_updated.emit();

func _is_player_in_list(player:Player, player_list: Array[Player]):
	return player_list.map(func(x): return x.name).has(player.name)

func _is_player_on_team(player:Player, team: Team):
	return _is_player_in_list(player, team.players)
	
func _is_player_on_any_team(player: Player):
	return teams.any(func(x): return _is_player_on_team(player, x))
