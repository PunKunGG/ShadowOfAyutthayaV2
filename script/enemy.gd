extends CharacterBody2D

signal takedown_success

@export var speed := 30
@export var max_hp := 3
@export var knockback_strength := 300.0
@export var knockback_duration := 0.2
@export var gravity := 1200.0
@export var enemy_type := "Soldier"
@export var attack_cooldown := 1.0

@export var is_patrolling := true
@export var patrol_left := -100
@export var patrol_right := 100
var origin_x := 0.0

@onready var sprite := $AnimatedSprite2D
@onready var dead_sound := $Dead
@onready var wall_ray := $WallRay
@onready var floor_ray := $FloorRay
@onready var back_stab_area := $BackStabArea
@onready var vision_area := $VisionArea
@onready var alert_sound := $AlertSound
@onready var attack_area := $AttackArea
@onready var idle_timer := Timer.new()

var current_hp := max_hp
var knockback_velocity := Vector2.ZERO
var knockback_timer := 0.0
var is_knockback := false
var can_attack := false
var direction := -1
var is_idle := false
var is_pointing := false
var is_anim_locked := false
var alerted := false
var can_be_takedown = false
var takedown_player = null
var remaining_qte := 0
var is_attacking_player := false
var is_dead = false
var is_chasing = false
var has_played_alert := false
var player_ref : Node = null
var player_in_range : Node = null

# ✅ ระบบ QTE
var qte_popup : Node = null
var qte_answer : String = ""

# คำถาม-คำตอบ QTE
var qte_questions = [
	{"question": "___หลวง", "answer": "ใน"},
	{"question": "___โคขุน", "answer": "เข้ม"},
	{"question": "___สังหาร", "answer": "ลอบ"},
	{"question": "___ดาบ", "answer": "ฟัน"},
	{"question": "___กระเฟียด", "answer": "กระฟัด"},
	{"question": "___มืด", "answer": "เงา"},
	{"question": "___ริมสระ", "answer": "โอ"},
	{"question": "___มาแล้วน้อง", "answer": "พี่"},
]

func _ready():
	origin_x = global_position.x
	
	# ตั้งทิศเริ่มต้น
	if is_patrolling:
		direction = -1        # เริ่มหันซ้ายตามเดิม (หรือ 1 ถ้าจะเริ่มขวา)
	else:
		direction = 1         # พวกยืนนิ่งหันขวาเท่านั้น

	_apply_direction_offsets()
	
	qte_popup = QteManager.QTEPopup
	if not qte_popup:
		push_error("❌ QTEPopup ไม่พร้อมใช้งาน!")
	
	can_attack = true
	
	add_child(idle_timer)
	idle_timer.wait_time = 3.0
	idle_timer.one_shot = true
	idle_timer.connect("timeout", Callable(self, "_on_idle_timeout"))
	back_stab_area.body_entered.connect(_on_backstab_entered)
	back_stab_area.body_exited.connect(_on_backstab_exited)
	
	vision_area.body_entered.connect(_on_vision_entered)
	vision_area.body_exited.connect(_on_vision_exited)
	
	attack_area.body_entered.connect(_on_attack_area_entered)
	attack_area.body_exited.connect(_on_attack_area_exited)

func _physics_process(delta):
	if is_dead or is_pointing:
		return
	
	if player_in_range and player_in_range.is_hidden:
		player_in_range = null  # ✅ ไม่ควรเก็บ player ที่ซ่อนอยู่เป็น target
	
	if is_knockback:
		velocity = knockback_velocity
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knockback = false
	else:
		if is_chasing and player_ref:
			var direction_to_player = sign(player_ref.global_position.x - global_position.x)
			direction = direction_to_player
			velocity.x = direction * speed * 5.0
			
			if player_ref.is_hidden:
				print("🧟 ศัตรูเลิกไล่ เพราะผู้เล่นหายตัว")
				is_chasing = false
				player_ref = null
				alerted = false  # ✅ สำคัญมาก
				return
			
		else:
			if is_idle or not is_patrolling:
				velocity.x = 0
			else:
				if is_attacking_player:
					velocity.x = 0
					return

				if randi() % 500 == 0 and is_on_floor() and idle_timer.is_stopped():
					is_idle = true
					idle_timer.start()
					return

				if wall_ray.is_colliding() and not wall_ray.get_collider().is_in_group("player"):
					_turn_around()

				if not floor_ray.is_colliding():
					_turn_around()

				if global_position.x < origin_x + patrol_left:
					direction = 1
					_apply_direction_offsets()
				elif global_position.x > origin_x + patrol_right:
					direction = -1
					_apply_direction_offsets()

				velocity.x = direction * speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if can_attack and player_in_range and not is_dead:
		_attack_player_direct(player_in_range)
	
	move_and_slide()
	_update_animation()

func _turn_around():
	if is_chasing or not is_patrolling:
		return
	direction *= -1
	_apply_direction_offsets()

func _update_animation():
	if is_anim_locked:
		return  # ❌ ห้ามเปลี่ยนอนิเมชัน ถ้าล็อกไว้
	
	sprite.flip_h = direction > 0
	
	if velocity.x != 0:
		sprite.play("walk")  # หรือ "walk" ถ้ามี
	else:
		sprite.play("idle")

func take_damage(amount: int, attacker_position: Vector2):
	if is_dead:
		return
	
	current_hp -= amount
	print("โดนมั้ย!! - HP:", current_hp)
	
	if current_hp <= 0:
		die()
	else:
		apply_knockback(attacker_position)

func die():
	is_dead = true
	print(">>> DIE CALLED")
	sprite.play("dead")
	print(">>> PLAYED ANIM: ", sprite.animation)
	dead_sound.play()
	await get_tree().create_timer(3.0).timeout
	queue_free()

func apply_knockback(attacker_position: Vector2):
	var _direction = (global_position - attacker_position).normalized()
	_direction.y = 0
	knockback_velocity = _direction.normalized() * knockback_strength
	knockback_timer = knockback_duration
	is_knockback = true

func _on_idle_timeout():
	is_idle = false

func _on_backstab_entered(body):
	if body.is_in_group("player"):
		can_be_takedown = true
		takedown_player = body
		body.set_takedown_target(self)
		body.show_takedown_prompt()

func _on_backstab_exited(body):
	if body == takedown_player:
		can_be_takedown = false
		body.set_takedown_target(null)
		body.hide_takedown_prompt()
		#takedown_player = null

func insta_kill():
	is_dead = true
	print(">>> insta_kill called")

	emit_signal("takedown_success")

	sprite.play("dead")
	await sprite.animation_finished  # ✅ รออนิเมชันจบจริง

	dead_sound.play()
	await get_tree().create_timer(2.0).timeout  # รอให้เสียงพอได้ยิน
	queue_free()

	PlayerStat.score += get_score_reward()

func alert_from_behind():
	if is_attacking_player:
		return
	
	if takedown_player and takedown_player.is_hidden:
		return
	
	is_attacking_player = true
	_turn_around()
	
	await get_tree().create_timer(0.3).timeout
	_attack_player()
	
	await get_tree().create_timer(0.5).timeout
	_turn_around()
	is_attacking_player = false

func is_alerted() -> bool:
	return alerted

func _attack_player():
	if takedown_player and takedown_player.is_inside_tree():
		takedown_player.receive_damage(1, global_position)

func try_start_qte():
	if not qte_popup or not can_be_takedown:
		print("🚫 เรียก QTE ไม่ได้: qte_popup=", qte_popup, " can_be_takedown=", can_be_takedown)
		return
	
	print("✅ เรียก QTE ได้ เริ่มคำถาม")
	
	# กำหนดจำนวนรอบ
	if enemy_type == "Boss":
		remaining_qte = 5
	else:
		var _range = PlayerStat.get_qte_range()
		remaining_qte = randi_range(_range.x, _range.y)

	# ✅ เรียกแค่ _start_next_qte_round() ที่เดียว
	_start_next_qte_round()

func _on_qte_result(success: bool):
	if success:
		remaining_qte -= 1
		if remaining_qte <= 0:
			emit_signal("takedown_success")
		else:
			await get_tree().create_timer(0.1).timeout  # รอ 1 เฟรมเพื่อความปลอดภัย
			_start_next_qte_round()
	else:
		print("❌ QTE พลาด - หันมาโจมตีผู้เล่น")
		alert_from_behind()

func _start_next_qte_round():
	var qte = qte_questions.pick_random()
	qte_answer = qte["answer"]
	var question = qte["question"]

	var wrong_answers = []
	for q in qte_questions:
		if q["answer"] != qte_answer:
			wrong_answers.append(q["answer"])

	wrong_answers.shuffle()
	var options = wrong_answers.slice(0, min(2, wrong_answers.size()))
	options.append(qte_answer)
	options.shuffle()
	
	print("📢 เรียก qte_popup.start()")
	qte_popup.start(question, options, qte_answer, global_position + Vector2(0, -50))
	qte_popup.submitted.connect(_on_qte_result, CONNECT_ONE_SHOT)

func _on_vision_entered(body):
	if body.is_in_group("player") and not is_dead:
		if body.has_method("is_hidden") and body.is_hidden:
			print("🙈 ศัตรูเห็น player แต่ player ซ่อนอยู่ → ไม่ alert")
			return  # ✅ หยุดไม่ให้ชี้หน้า

		if not alerted:
			alerted = true
			player_ref = body
			is_chasing = false
			is_pointing = true
			alert_sound.play()
			sprite.play("point")
			
			await sprite.animation_finished
			is_pointing = false
			is_chasing = true
			
			if not has_played_alert:
				has_played_alert = true

func _on_vision_exited(body):
	if body == player_ref:
		is_chasing = false
		player_ref = null
		has_played_alert = false
		alerted = false

func _on_attack_area_entered(body):
	if body.is_in_group("player"):
		player_in_range = body

func _on_attack_area_exited(body):
	if body == player_in_range:
		player_in_range = null

func _attack_player_direct(target):
	can_attack = false
	sprite.play("attack")
	is_anim_locked = true

	await get_tree().create_timer(0.3).timeout
	if target and target.is_inside_tree() and target.has_method("receive_damage"):
		if not target.is_hurt and not target.is_hidden:  # ✅ ป้องกันไม่ให้ตีซ้ำตอน player ยัง hurt อยู่
			target.receive_damage(1, global_position)

	await sprite.animation_finished
	is_anim_locked = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _apply_direction_offsets():
	vision_area.position.x   = abs(vision_area.position.x)   * direction
	attack_area.position.x   = abs(attack_area.position.x)   * direction
	wall_ray.target_position.x  = abs(wall_ray.target_position.x)  * direction
	floor_ray.target_position.x = abs(floor_ray.target_position.x) * direction
	back_stab_area.position.x   = -abs(back_stab_area.position.x) * direction
	sprite.flip_h = direction > 0   # ซิงก์ทิศ sprite


func get_score_reward() -> int:
	match enemy_type:
		"Soldier":
			return randi_range(5, 10)
		"Archer":
			return randi_range(10, 15)
		"Mage":
			return randi_range(15, 20)
		"Juggernaut":
			return randi_range(25, 40)
		"Boss":
			return 100
	return 0
