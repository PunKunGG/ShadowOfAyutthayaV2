extends Node

var last_played_scene: String = ""

var total_score := 0
var enemy_kill := {
	"soldier": 0,
	"archer": 0,
	"incantation": 0,
	"juggernaut": 0,
	"boss": 0,
}

var unlocked_levels := {
	"Prologue": true,
	"Level1": true,
	"Level2": false,
	"Level3": false,
	"Level4": false,
	"Level5": false
}

func unlock_level(_name: String):
	if _name in unlocked_levels:
		unlocked_levels[_name] = true

func add_score(amout: int) -> void:
	total_score += amout
	
func record_kill(enemy_type: String) -> void:
	if enemy_type in enemy_kill:
		enemy_kill[enemy_type] += 1
