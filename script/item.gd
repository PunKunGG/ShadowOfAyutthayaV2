extends Area2D

@export var item_name: String = "axe"
@export var item_icon: Texture2D

@onready var sprite := $Sprite2D
@onready var pickup_label := $PickupLabel

func _ready():
	pickup_label.visible = false
	sprite.texture = item_icon
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		pickup_label.visible = true
		body.set_pickup_target(self)  # ให้ player จำไอเทมที่อยู่ใกล้

func _on_body_exited(body):
	if body.is_in_group("player"):
		pickup_label.visible = false
		body.set_pickup_target(null)
		
