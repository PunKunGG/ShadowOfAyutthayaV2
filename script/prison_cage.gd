extends StaticBody2D

signal cage_destroyed

@export var max_hp := 10
var current_hp := max_hp

@onready var sprite := $Sprite2D
@onready var sound := $AudioStreamPlayer

func _ready():
	add_to_group("cage")

func take_hit():
	var damage = randi_range(1, 3)
	current_hp -= damage
	print("🪓 กรงโดนตี - HP เหลือ: ", current_hp)
	sound.play()
	
	if current_hp <= 0:
		destroy_cage()

func destroy_cage():
	print("🆓 กรงพังแล้ว! ปล่อยตัวประกันได้")
	emit_signal("cage_destroyed")
	sound.play()
	await get_tree().create_timer(0.3).timeout
	queue_free()
