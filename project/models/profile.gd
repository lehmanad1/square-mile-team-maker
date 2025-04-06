class_name Profile

var profile_name: String;
var saved_players: Array[Player];
var available_players: Array[Player];
var teams: Array[Team];
var attributes: Array[Attribute];
var max_team_size: int;

func to_json() -> String:
	var profile_dict = {
		"profile_name": profile_name,
		"saved_players": saved_players.map(func(p): return p.to_dict()),
		"available_players": available_players.map(func(p): return p.to_dict()),
		"teams": teams.map(func(t): return t.to_dict()),
		"attributes": attributes.map(func(a): return a.to_dict()),
		"max_team_size": max_team_size
	}
	return JSON.stringify(profile_dict)

func from_json(json_str: String):
	var profile_dict = JSON.parse_string(json_str);
	profile_name = profile_dict["profile_name"];
	saved_players.assign(profile_dict["saved_players"].map(func(p): return Player.new().from_dict(p)));
	available_players.assign(profile_dict["available_players"].map(func(p): return Player.new().from_dict(p)));
	teams.assign(profile_dict["teams"].map(func(t): return Team.new().from_dict(t)));
	attributes.assign(profile_dict["attributes"].map(func(a): return Attribute.new().from_dict(a)));
	max_team_size = profile_dict["max_team_size"];
	return self;
