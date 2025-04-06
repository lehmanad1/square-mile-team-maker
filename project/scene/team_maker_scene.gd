extends Node2D

@onready var save_data_manager = $SaveDataManager
@onready var profile_manager = $ProfileManager

#region ProfileCanvasLayler Nodes
@onready var profile_canvas_layer = $ProfileCanvasLayer
@onready var profile_list_container = $ProfileCanvasLayer/UIGridContainer/MainRow/VBoxContainer/ProfileScrollboxContainer/ProfileListContainer
@onready var create_profile_form = $ProfileCanvasLayer/EditProfileSettingsPopup/CreateProfile
@onready var profile_name_label = $ProfileCanvasLayer/UIGridContainer/MainRow/ProfileViewContainer/VBoxContainer/HBoxContainer/ProfileNameLabel
@onready var max_teams_size_label = $ProfileCanvasLayer/UIGridContainer/MainRow/ProfileViewContainer/VBoxContainer/HBoxContainer2/MaxTeamSizeLabel
@onready var attribute_display_list = $ProfileCanvasLayer/UIGridContainer/MainRow/ProfileViewContainer/AttributeListScrollContainer/AttributeDisplayList
@onready var export_profile_button = $ProfileCanvasLayer/UIGridContainer/ButtonRow1/ExportProfileButton
@onready var profile_view_container = $ProfileCanvasLayer/UIGridContainer/MainRow/ProfileViewContainer
@onready var import_saved_profile_popup = $ProfileCanvasLayer/ImportSavedProfilePopup
@onready var edit_profile_settings_popup = $ProfileCanvasLayer/EditProfileSettingsPopup
@onready var import_saved_profile_button = $ProfileCanvasLayer/ImportSavedProfilePopup/VBoxContainer/HBoxContainer/ImportButton
@onready var import_saved_profile_text_box = $ProfileCanvasLayer/ImportSavedProfilePopup/VBoxContainer/MarginContainer/ImportProfileTextEdit
@onready var profile_team_show_player_canvas_button = $ProfileCanvasLayer/UIGridContainer/BottomRow/ShowPlayerCanvasButton
@onready var profile_show_teams_canvas_button = $ProfileCanvasLayer/UIGridContainer/BottomRow/ShowTeamsCanvasButton
#endregion

#region PlayerCanvasLayer Nodes
@onready var player_canvas_layer = $PlayerCanvasLayer
@onready var create_saved_player_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/CreatePlayerButton
@onready var available_players_list = $PlayerCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/AvailablePlayerList
@onready var saved_players_list = $PlayerCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer2/SavedPlayerList
@onready var show_team_canvas_button = $PlayerCanvasLayer/UIGridContainer/BottomRow/ShowTeamCanvasButton
@onready var show_profile_canvas_button = $PlayerCanvasLayer/UIGridContainer/BottomRow/ImportProfileCanvasButton
@onready var import_players_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/ImportPlayerListButton
@onready var export_players_button = $PlayerCanvasLayer/UIGridContainer/ButtonRow1/ExportToClipboardButton
@onready var import_saved_players_button = $PlayerCanvasLayer/ImportSavedPlayersPopup/VBoxContainer/HBoxContainer/ImportButton
@onready var import_saved_players_text = $PlayerCanvasLayer/ImportSavedPlayersPopup/VBoxContainer/MarginContainer/TextEdit
@onready var create_player_popup_form = $PlayerCanvasLayer/CreatePlayerPopup/CreatePlayer
@onready var create_player_popup = $PlayerCanvasLayer/CreatePlayerPopup
#endregion

#region TeamCanvasLayer Nodes
@onready var team_canvas_layer = $TeamCanvasLayer
@onready var teamless_player_list = $TeamCanvasLayer/UIGridContainer/MainRow/PlayerListScrollContainer/PlayerList
@onready var teams_list = $TeamCanvasLayer/UIGridContainer/MainRow/TeamsListScrollContainer/TeamsList
@onready var create_team_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow1/CreateTeamButton"
@onready var reset_teams_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow1/ResetTeamsButton"
@onready var autofill_teams_randomly_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow2/AutofillTeamsButton"
@onready var autofill_teams_attribute_button = $"TeamCanvasLayer/UIGridContainer/ButtonRow2/AutofillTeamsButton2"
@onready var team_show_player_canvas_button = $TeamCanvasLayer/UIGridContainer/BottomRow/ShowPlayerCanvasButton
@onready var team_show_profile_canvas_button = $TeamCanvasLayer/UIGridContainer/BottomRow/ImportProfileCanvasButton
@onready var skill_slider = $TeamCanvasLayer/UIGridContainer/SliderRow/SkillSlider
#endregion

var ProfilePanelScene = preload("res://components/editable_profile_container.tscn");
var AttributePanelScene = preload("res://components/editable_attribute_panel.tscn");

var EditablePlayerPanelScene = preload("res://components/draggable_editable_player_panel.tscn");
var PlayerPanelScene = preload("res://components/draggable_player_panel.tscn");

var TeamScene = preload("res://components/team_container.tscn");




func _ready():
	await get_tree().process_frame
	
	#region ProfileCanvas Connections
	profile_manager.connect("saved_profiles_updated", Callable(self, "_redraw_saved_profiles"));
	create_profile_form.connect("submit_profile_to_add", Callable(self, "_try_add_new_profile"));
	export_profile_button.pressed.connect(Callable(self, "_export_active_profile_to_clipboard"));
	import_saved_profile_button.pressed.connect(Callable(self, "_import_profile"));
	profile_team_show_player_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility").bind(2));
	profile_show_teams_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility").bind(3));
	#endregion
	
	#region PlayerCanvas Connections
	profile_manager.connect("saved_players_updated", Callable(self, "_redraw_player_lists"));
	available_players_list.connect("mark_player_as_available", Callable(self, "_mark_player_as_available"));
	saved_players_list.connect("mark_player_as_unavailable", Callable(self, "_mark_player_as_unavailable"));
	show_profile_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility").bind(1));
	show_team_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility").bind(3));
	export_players_button.connect("pressed", Callable(self, "_export_saved_players"));
	import_saved_players_button.connect("pressed", Callable(self, "_import_saved_players"));
	#endregion
		
	#region TeamCanvas Connections
	profile_manager.connect("teams_updated", Callable(self, "_redraw_teams"));
	profile_manager.connect("teamless_players_updated", Callable(self, "_redraw_teamless_players"));
	create_team_button.pressed.connect(Callable(self, "_add_new_team"));
	reset_teams_button.pressed.connect(Callable(self, "_reset_teams"));
	autofill_teams_attribute_button.pressed.connect(Callable(self, "_autofill_teams_by_attribute"));
	teamless_player_list.connect("remove_player_from_team", Callable(self, "_remove_player_from_team"));
	team_show_profile_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility").bind(1));
	team_show_player_canvas_button.connect("pressed", Callable(self, "_toggle_canvas_visibility").bind(2));
	#endregion
	
	save_data_manager.load_profiles();
	
#region Shared Methods
func _toggle_canvas_visibility(active_canvas:int):
	profile_canvas_layer.visible = true if active_canvas == 1 else false;
	player_canvas_layer.visible = true if active_canvas == 2 else false;
	team_canvas_layer.visible = true if active_canvas == 3 else false;
	
func _instantiate_player_panel(player_data: Player, list:Control) -> void:
	var panel = PlayerPanelScene.instantiate();
	panel.set_player(player_data);
	list.add_child(panel);
#endregion

#region Profile View Methods

func _try_add_new_profile(profile: Profile):
	if not profile_manager.try_add_saved_profile(profile):
		create_profile_form.show_profile_validation_text("profile name already in use");
	
func _redraw_saved_profiles():
	import_saved_profile_popup.visible = false;
	edit_profile_settings_popup.visible = false;
	var active_profile_name = profile_manager.active_profile.profile_name;
	profile_team_show_player_canvas_button.disabled = false;
	profile_show_teams_canvas_button.disabled = false;
	for profile_panel in profile_list_container.get_children():
		profile_panel.queue_free();
	for profile in profile_manager.saved_profiles:
		var profile_panel = ProfilePanelScene.instantiate();
		profile_panel.get_node("HBoxContainer/HBoxContainer/PlayerName").text = profile.profile_name;
		if active_profile_name == profile.profile_name:
			profile_panel.get_node("HBoxContainer/HBoxContainer/PlayerName").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			profile_panel.get_node("HBoxContainer/ActiveCheckBox").button_pressed = true
			_redraw_active_profile_selection(profile);
		profile_panel.get_node("HBoxContainer/ActiveCheckBox").pressed.connect(Callable(profile_manager, "set_active_profile").bind(profile))
		profile_list_container.add_child(profile_panel);
		

func _redraw_active_profile_selection(profile: Profile):		
	create_player_popup_form.create_new_attribute_list();
	profile_view_container.visible = true;
	profile_name_label.text = profile.profile_name;
	max_teams_size_label.text = str(profile.max_team_size);
	
	for attribute_panel in attribute_display_list.get_children():
		attribute_panel.queue_free();
	for attribute in profile.attributes:
		var attribute_panel = AttributePanelScene.instantiate();
		attribute_panel.get_node("HBoxContainer/DeleteAttributeButton").visible = false;
		attribute_panel.get_node("HBoxContainer/HBoxContainer/AttributeName").text = attribute.attribute_name;
		attribute_panel.get_node("HBoxContainer/HBoxContainer/AttributeWeight").text = str(attribute.attribute_weight) + "%";
		attribute_display_list.add_child(attribute_panel);

func _import_profile():
	var profile_json:String = import_saved_profile_text_box.text;
	var profile = Profile.new().from_json(profile_json);
	profile_manager.try_add_saved_profile(profile);

func _export_active_profile_to_clipboard():
	DisplayServer.clipboard_set(profile_manager.active_profile.to_json());			
			
#endregion

#region Team View Methods
func _add_new_team():
	profile_manager.add_new_team();

func _reset_teams():
	profile_manager.reset_teams();

func _autofill_teams_by_attribute():
	var variability = skill_slider.value;
	profile_manager.autofill_players_by_pool_variability(variability)

func _create_team() -> void:
	var totalTeamCount = profile_manager.teams.size() + 1;
	var team_name = "Team #" + str(totalTeamCount);
	if totalTeamCount < 6:
		var newTeam = TeamScene.instantiate();
		newTeam.team_name = team_name;
		teams_list.add_child(newTeam);

func _redraw_teamless_players():
	for child in teamless_player_list.get_children():
		child.queue_free();
	for teamless_player in profile_manager.teamless_players:
		_instantiate_player_panel(teamless_player, teamless_player_list);

func _redraw_teams():
	for child in teams_list.get_children():
		teams_list.remove_child(child);
	for team in profile_manager.teams:
		var container = _instantiate_team_container(team);
		container.connect("add_player_to_team", Callable(profile_manager, "add_player_to_team"));
		container.connect("remove_player_from_team", Callable(profile_manager, "remove_player_from_team"));
		teams_list.add_child(container);


func _instantiate_team_container(team:Team) -> VBoxContainer:
	var newTeamScene = TeamScene.instantiate();
	newTeamScene.set_team(team);
	return newTeamScene

func _remove_team() ->  void:
	pass;
	
func _remove_player_from_team(target_player: Player):
	profile_manager.remove_player_from_team(target_player);
#endregion

#region Player View Methods
func _mark_player_as_available(player_data: Player):
	profile_manager.mark_player_as_available(player_data);
	
func _mark_player_as_unavailable(player_data: Player):
	profile_manager.mark_player_as_unavailable(player_data);	

func _instantiate_editable_player_panel(player_data: Player):
	var panel = EditablePlayerPanelScene.instantiate()
	panel.set_player(player_data)
	panel.connect("edit_player", Callable(create_player_popup_form, "_load_saved_player"))
	panel.connect("edit_player", Callable(create_player_popup, "_on_edit_player_button_pressed"))
	saved_players_list.add_child(panel)

func _redraw_player_lists():
	_redraw_saved_players_dropdown();
	_redraw_available_players_dropdown();
	
func _redraw_available_players_dropdown():
	for child in available_players_list.get_children():
		available_players_list.remove_child(child);
	for player in profile_manager.available_players:
		_instantiate_player_panel(player, available_players_list);
		
func _redraw_saved_players_dropdown():
	for child in saved_players_list.get_children():
		saved_players_list.remove_child(child);
	for player in profile_manager.get_unavailable_players():
		_instantiate_editable_player_panel(player);

func _import_saved_players():
	profile_manager.import_saved_player_data(import_saved_players_text.text)

func _export_saved_players():
	var export_string = profile_manager.export_saved_player_data();
	DisplayServer.clipboard_set(export_string);
#endregion
