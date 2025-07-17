extends Area2D

@export var damage_tick_time := 0.5
@export var min_dmg := 1
@export var max_dmg := 2


func _ready():
	$Timer.wait_time = damage_tick_time
	$Timer.timeout.connect(_on_tick)
	$Timer.start()
	
	await get_tree().create_timer(10).timeout
	$SlashSound.stop()
	queue_free()

	
func _on_tick():
	$SlashSound.play()
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy"):
			print("⚔️ ฟันศัตรู: ", body.name)
			var dmg = randi_range(min_dmg, max_dmg)
			body.take_damage(dmg, global_position)
