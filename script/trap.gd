extends Area2D

@export var damage_min := 2
@export var damage_max := 6
@export var tick_damage := 1
@export var tick_interval := 1.0  # วินาทีละ 1 ดาเมจ

var player_in_area := false
var player_ref : Node = null

@onready var damage_timer: Timer = $DamageTimer

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	damage_timer.wait_time = tick_interval
	damage_timer.timeout.connect(_on_damage_tick)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		player_ref = body

		# 🩸 ทำดาเมจทันที 2–6
		var instant_damage := randi_range(damage_min, damage_max)
		body.take_damage(instant_damage)  # ✅ ต้องมีฟังก์ชันนี้ใน player
		damage_timer.start()

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		player_ref = null
		damage_timer.stop()

func _on_damage_tick():
	if player_in_area and player_ref:
		player_ref.take_damage(tick_damage)
