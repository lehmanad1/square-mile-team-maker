class_name Team

var team_name = ""
var players : Array[Player] = []

func _init(t_n: String = "", pls: Array[Player] = []):
	team_name = t_n
	players = pls

func get_attribute_total():
	return players.reduce(func(acc, p:Player): return acc + p.get_attribute_total(), 0);

func to_dict() -> Dictionary:
	return {
		"team_name": team_name,
		"players": players.map(func(p): return p.to_dict())
	}

func from_dict(dict: Dictionary):
	team_name = dict["team_name"]
	players.assign(dict["players"].map(func(p): return Player.new().from_dict(p)))
	return self;
