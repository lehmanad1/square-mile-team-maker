extends Node

signal saved_profiles_updated;
signal switch_active_profile;

var saved_profiles: Array[Profile] = [];
var active_profile: Profile;

func try_add_profile(profile: Profile) -> bool:
	if saved_profiles.map(func(x): return x.profile_name).has(profile.profile_name):
		return false;
	else:
		saved_profiles.append(profile);
		active_profile = profile;
		saved_profiles_updated.emit();
		return true
		
func set_active_profile(profile: Profile):
	active_profile = profile;
	switch_active_profile.emit();
	

func resync_active_profile(profile:Profile):
	saved_profiles.assign(saved_profiles.map(func(x):
		if x.profile_name == profile.profile_name:
			return profile;
		else:
			return x;
	));
	saved_profiles_updated.emit();
	
