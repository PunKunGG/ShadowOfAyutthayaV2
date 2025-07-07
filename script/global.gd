extends Node

var total_score := 0
var enemy_kill := {
	"soldier": 0,
	"archer": 0,
	"incantation": 0,
	"juggernaut": 0,
	"boss": 0,
}

func add_score(amout: int) -> void:
	total_score += amout
	
func record_kill(enemy_type: String) -> void:
	if enemy_type in enemy_kill:
		enemy_kill[enemy_type] += 1
