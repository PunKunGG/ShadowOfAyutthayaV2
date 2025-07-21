extends Area2D

signal enemy_entered(enemy)
signal enemy_exited(enemy)

var is_lit := true

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	add_to_group("torch")

func _on_body_entered(body):
	if not is_lit:
		return
	if body.is_in_group("enemy"):
		body.is_in_light = true
		print("🔥 Enemy entered light")

func _on_body_exited(body):
	if not is_lit:
		return
	if body.is_in_group("enemy"):
		body.is_in_light = false
		print("🌑 Enemy left light")

func extinguish():
	is_lit = false
	visible = false  # หรือปิด animation/light2d ด้วยก็ได้
	print("🔥 ไฟดับแล้ว")
