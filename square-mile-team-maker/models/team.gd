class_name Team

var team_name = ""
var players : Array[Player] = []

func _init(t_n: String, pls: Array[Player] = []):
	team_name = t_n
	players = pls

func get_attribute_total():
	return players.reduce(func(acc, p:Player): return acc + p.get_attribute_total(), 0);
