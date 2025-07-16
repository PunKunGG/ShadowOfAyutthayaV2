extends Area2D

signal start_rescue
signal rescued
signal cancel_rescue

@onready var label := $Label
@onready var rescue_loop_sound := $RescueLoopSound
@onready var rescue_me := $RescueMe
@onready var rizz := $RescueCom

const RESCUE_TIME := 5.0

var player_in_range := false
var rescue_timer := 0.0
var is_rescued := false
var has_started := false  # ✅ ป้องกันไม่ให้ signal ถูกส่งซ้ำ
var has_started_rescue := false 

func _ready():
	label.visible = false
	
	var cage = $PrisonCage
	if cage:
		cage.cage_destroyed.connect(_on_cage_destroyed)
		set_process(false)  # ❌ ปิด _process จนกว่ากรงจะพัง

func _process(delta):
	if is_rescued or not player_in_range:
		return
	
	if Input.is_action_pressed("interact"):
		if not has_started_rescue:
			has_started_rescue = true
			emit_signal("start_rescue")
		
		rescue_me.stop()
		rescue_timer += delta
		label.text = "Helping... (%.1f)" % (RESCUE_TIME - rescue_timer)
		
		if not rescue_loop_sound.playing:
			rescue_loop_sound.play()
		
		if not has_started and rescue_timer >= RESCUE_TIME:
			emit_signal("rescued") # ✅ ส่งแค่ตอนช่วยเสร็จ
			complete_rescue()
	else:
		if has_started_rescue:
			has_started_rescue = false
			emit_signal("cancel_rescue")
		if rescue_loop_sound.playing:
			rescue_loop_sound.stop()
		rescue_timer = 0
		label.text = "Hold E to Rescue"

func complete_rescue():
	is_rescued = true
	emit_signal("rescued")
	label.text = "✅ Rescued!!"
	
	rescue_loop_sound.stop()
	rizz.play()
	#Random Items
	var items = ["Rope", "Axe"]
	var item = items[randi() % items.size()]
	Inventory.add_item(item)
	
	#Add Point
	var reward = randi() % 21 + 10
	Global.add_score(reward)
	print("🎁 ได้ไอเท็ม:", item)
	print("💠 ได้แต้มสะสม:", reward)
	
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_cage_destroyed():
	print("🆓 กรงพัง → ตัวประกันรอการช่วย")
	set_process(true)

func _on_body_entered(body):
	if body.name == "Player":
		rescue_me.play()
		player_in_range = true
		label.visible = true
		body.set_hostage_target(self)
		print("🧍‍♂️ ผู้เล่นเข้ามาใกล้ตัวประกัน")
		
func _on_body_exited(body):
	if body.name == "Player":
		rescue_me.stop()
		player_in_range = false
		label.visible = false
		rescue_timer = 0
		body.set_hostage_target(null)
		print("🚶‍♂️ ผู้เล่นออกห่างตัวประกัน")
