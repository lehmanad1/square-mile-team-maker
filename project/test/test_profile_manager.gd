extends GutTest

var ProfileManager = preload("res://managers/profile_manager.tscn");

var profile_manager: ProfileManager;

func before_each():
	profile_manager = await ProfileManager.instantiate();

func after_each():
	profile_manager = null;

func test_saved_players_updated_signal():
	watch_signals(profile_manager);
	profile_manager.try_add_saved_player(Player.new("Player1", 2, 3, 4, 5));
	assert_signal_emitted(profile_manager, "saved_players_updated", "saved_players_updated signal should be emitted");

func test_teamless_players_updated_signal():
	watch_signals(profile_manager);
	profile_manager.mark_player_as_available(Player.new("Player2", 3, 4, 5, 6));
	assert_signal_emitted(profile_manager, "teamless_players_updated", "teamless_players_updated signal should be emitted");

func test_teams_updated_signal():
	watch_signals(profile_manager);
	profile_manager.add_new_team();
	assert_signal_emitted(profile_manager, "teams_updated", "teams_updated should be emitted");

func test_add_remove_player_from_team():
	var player = Player.new("Player3", 4, 5, 6, 7);
	profile_manager.add_new_team();
	profile_manager.add_player_to_team("Team #1", player);
	assert_true(profile_manager._is_player_on_team(player, profile_manager.teams[0]), "Player should be added to the team");
	profile_manager.remove_player_from_team(player);
	assert_false(profile_manager._is_player_on_team(player, profile_manager.teams[0]), "Player should be removed from the team");

# Test importing and exporting player data
func test_import_export_player_data():
	var player_data = "Player4,5,6,7,8\nPlayer5,6,7,8,9";
	profile_manager.import_saved_player_data(player_data);
	assert_true(profile_manager._is_player_in_list(Player.new("Player4", 5, 6, 7, 8), profile_manager.saved_players), "Player4 should be imported");
	assert_true(profile_manager._is_player_in_list(Player.new("Player5", 6, 7, 8, 9), profile_manager.saved_players), "Player5 should be imported");
	var exported_data = profile_manager.export_saved_player_data();
	assert_true(exported_data.contains("Player4,5,6,7,8"), "Player4 should be exported");
	assert_true(exported_data.contains("Player5,6,7,8,9"), "Player5 should be exported");

# Test autofill players to teams randomly
func test_autofill_players_to_teams_randomly():
	profile_manager.add_new_team();
	profile_manager.add_new_team();
	profile_manager.mark_player_as_available(Player.new("Player6", 7, 8, 9, 10));
	profile_manager.mark_player_as_available(Player.new("Player7", 8, 9, 10, 11));
	profile_manager.autofill_players_to_teams_randomly();
	assert_true(profile_manager._is_player_on_any_team(Player.new("Player6", 7, 8, 9, 10)), "Player6 should be assigned to a team");
	assert_true(profile_manager._is_player_on_any_team(Player.new("Player7", 8, 9, 10, 11)), "Player7 should be assigned to a team");

# Test autofill players to team by attributes
func test_autofill_players_to_team_by_attributes():
	profile_manager.add_new_team();
	profile_manager.add_new_team();
	profile_manager.mark_player_as_available(Player.new("Player8", 9, 10, 11, 12));
	profile_manager.mark_player_as_available(Player.new("Player9", 10, 11, 12, 13));
	profile_manager.autofill_players_to_team_by_attributes();
	assert_true(profile_manager._is_player_on_any_team(Player.new("Player8", 9, 10, 11, 12)), "Player8 should be assigned to a team");
	assert_true(profile_manager._is_player_on_any_team(Player.new("Player9", 10, 11, 12, 13)), "Player9 should be assigned to a team");

# Test autofill players by pool variability
func test_autofill_players_by_pool_variability():
	profile_manager.add_new_team();
	profile_manager.add_new_team();
	profile_manager.mark_player_as_available(Player.new("Player10", 11, 12, 13, 14));
	profile_manager.mark_player_as_available(Player.new("Player11", 12, 13, 14, 15));
	profile_manager.autofill_players_by_pool_variability(50);
	assert_true(profile_manager._is_player_on_any_team(Player.new("Player10", 11, 12, 13, 14)), "Player10 should be assigned to a team");
	assert_true(profile_manager._is_player_on_any_team(Player.new("Player11", 12, 13, 14, 15)), "Player11 should be assigned to a team");
