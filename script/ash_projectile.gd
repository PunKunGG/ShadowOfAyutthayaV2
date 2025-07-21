extends Area2D

@export var speed := 600
var target_position: Vector2
var torch_node: Node = null

func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	var dir = (target_position - global_position).normalized()
	position += dir * speed * delta
	
	# ลบ projectile ถ้าใกล้ถึงเป้าหมาย
	if global_position.distance_to(target_position) < 10:
		if torch_node and torch_node.has_method("try_extinguish"):
			torch_node.try_extinguish()
		queue_free()

func _on_body_entered(body):
	if body == torch_node:
		if torch_node.has_method("try_extinguish"):
			torch_node.try_extinguish()
		queue_free()
