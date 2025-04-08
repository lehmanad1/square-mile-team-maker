extends Node

@onready var profile_manager = $"../ProfileManager";

var SAVE_LOCATION = "user://team-maker-data.json";

func _ready():
	if not profile_manager:
		await profile_manager.ready;
	profile_manager.saved_profiles_updated.connect(Callable(self,"_save_profiles"));
	profile_manager.saved_players_updated.connect(Callable(self,"_save_profiles"));
	profile_manager.teamless_players_updated.connect(Callable(self,"_save_profiles"));
	profile_manager.teams_updated.connect(Callable(self,"_save_profiles"));
	
func _save_profiles():
	var save_dict:Dictionary[String, String] = {};
	var save_file = FileAccess.open(SAVE_LOCATION, FileAccess.WRITE);
	for profile in profile_manager.saved_profiles:
		save_dict.get_or_add(profile.profile_name, profile.to_json());
		
	var save_string = JSON.stringify(save_dict);
	print("saving...")
	save_file.store_line(save_string);
	
func load_profiles():
	# FileAccess.open(SAVE_LOCATION,FileAccess.WRITE).resize(0);
	if not FileAccess.file_exists(SAVE_LOCATION):
		return
	var file_as_string = FileAccess.get_file_as_string(SAVE_LOCATION);
	if file_as_string == "":
		return;
	var profile_dict = JSON.parse_string(file_as_string);
	for profile_string in profile_dict.values():
		var profile = Profile.new().from_json(profile_string);
		profile_manager.try_add_saved_profile(profile);
