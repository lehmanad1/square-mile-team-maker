class_name Team

var team_name = ""
var players : Array[Player] = []

func _init(t_n: String, pls: Array[Player] = []):
	team_name = t_n
	players = pls
