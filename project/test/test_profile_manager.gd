extends GutTest

var ProfileManager = preload("res://managers/profile_manager.tscn");

var profile_manager: ProfileManager;

func before_each():
	profile_manager = await ProfileManager.instantiate();
	add_child(profile_manager)
	await get_tree().process_frame;
		
func after_each():
	remove_child(profile_manager);
	profile_manager.queue_free();

func test_saved_players_updated_signal():
	watch_signals(profile_manager);
	var attributes:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	profile_manager.try_add_saved_player(Player.new("Player1", attributes));
	assert_signal_emitted(profile_manager, "saved_players_updated", "saved_players_updated signal should be emitted");

func test_teamless_players_updated_signal():
	watch_signals(profile_manager);
	var attributes:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	profile_manager.mark_player_as_available(Player.new("Player2", attributes));
	assert_signal_emitted(profile_manager, "teamless_players_updated", "teamless_players_updated signal should be emitted");

func test_teams_updated_signal():
	watch_signals(profile_manager);
	profile_manager.add_new_team();
	assert_signal_emitted(profile_manager, "teams_updated", "teams_updated should be emitted");

func test_add_remove_player_from_team():
	var attributes:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	var player = Player.new("Player3", attributes);
	profile_manager.add_new_team();
	profile_manager.add_player_to_team("Team #1", player);
	assert_true(profile_manager._is_player_on_team(player, profile_manager.teams[0]), "Player should be added to the team");
	profile_manager.remove_player_from_team(player);
	assert_false(profile_manager._is_player_on_team(player, profile_manager.teams[0]), "Player should be removed from the team");

# Test importing and exporting player data
func test_import_export_player_data():
	var player_data = "Player4,5,6,7,8\nPlayer5,6,7,8,9";
	profile_manager.attributes_manager.attributes.assign([Attribute.new(), Attribute.new(), Attribute.new(), Attribute.new()])
	profile_manager.import_saved_player_data(player_data);
	assert_true(profile_manager._is_player_in_list(Player.new("Player4", []), profile_manager.saved_players), "Player4 should be imported");
	assert_true(profile_manager._is_player_in_list(Player.new("Player5", []), profile_manager.saved_players), "Player5 should be imported");
	var exported_data = profile_manager.export_saved_player_data();
	assert_true(exported_data.contains("Player4,5,6,7,8"), "Player4 should be exported");
	assert_true(exported_data.contains("Player5,6,7,8,9"), "Player5 should be exported");

# Test autofill players by pool variability
func test_autofill_players_by_pool_variability():
	var profile = Profile.new();
	profile.max_team_size = 5;
	profile_manager.set_active_profile(profile);
	
	profile_manager.add_new_team();
	profile_manager.add_new_team();
	var player_1 = Player.new("Player1", []);
	var player_2 = Player.new("Player2", []);
	profile_manager.mark_player_as_available(player_1);
	profile_manager.mark_player_as_available(player_2);
	profile_manager.autofill_players_by_pool_variability(50);
	assert_true(profile_manager._is_player_on_any_team(player_1), "Player1 should be assigned to a team");
	assert_true(profile_manager._is_player_on_any_team(player_2), "Player2 should be assigned to a team");
	
func test_load_active_profile():
	var profile = Profile.new()
	var attributes: Array[Attribute] = [Attribute.new("Strength", 10), Attribute.new("Agility", 8)]
	var attribute_values:Array[AttributeValue] = [AttributeValue.new("attr1",100,1), AttributeValue.new("attr2",100,10),AttributeValue.new("attr3",100,3),AttributeValue.new("attr4",100,5)];
	
	var player_1 = Player.new("Player1", attribute_values);
	var player_2 = Player.new("Player2", attribute_values);
	
	var saved_players: Array[Player] = [player_1, player_2];
	var available_players: Array[Player] = [saved_players[0]]
	var teams: Array[Team] = [Team.new("Team1", [available_players[0]])];
	profile.attributes = attributes;
	profile.saved_players = saved_players;
	profile.available_players = available_players;
	profile.max_team_size = 10;
	profile.teams = teams;
	
	profile_manager.set_active_profile(profile);
	profile_manager.load_active_profile();

	assert_eq(profile_manager.attributes.size(), 2)
	assert_eq(profile_manager.saved_players.size(), 2)
	assert_eq(profile_manager.available_players.size(), 1)
	assert_eq(profile_manager.teams.size(), 1)
	assert_eq(profile_manager.max_team_size, 10)

func test_export_profile():
	var attributes: Array[Attribute] = [Attribute.new("Strength", 10), Attribute.new("Agility", 8)]
	var saved_players: Array[Player] = [Player.new("Player1", []), Player.new("Player2", [])]
	var available_players: Array[Player] = [saved_players[0]]
	var teams: Array[Team] = [Team.new("Team1", [available_players[0]])];
	
	var active_profile = Profile.new();
	active_profile.max_team_size = 10;
	active_profile.attributes = attributes;
	active_profile.saved_players = saved_players;
	active_profile.available_players = available_players;
	active_profile.teams = teams;
	profile_manager.set_active_profile(active_profile);

	var profile = profile_manager.export_profile()

	assert_eq(profile.attributes.size(), 2)
	assert_eq(profile.saved_players.size(), 2)
	assert_eq(profile.available_players.size(), 1)
	assert_eq(profile.teams.size(), 1)
	assert_eq(profile.max_team_size, 10)
