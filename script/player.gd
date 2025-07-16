extends CharacterBody2D

signal  sound_alert_triggered(enemy: Node)

@export var speed := 250
@export var run_speed := 400
@export var jump_velocity := -650
@export var gravity := 1200
@export var attack_damage := 1

@onready var qte_popup = QteManager.QTEPopup
@onready var anim := $AnimatedSprite2D
@onready var attack_area := $AttackArea
@onready var takedown_label := $TakedownLabel
@onready var collision_shape := $CollisionShape2D
@onready var sound_area := $SoundArea
@onready var sound_shape := $SoundArea/CollisionShape2D
@onready var footstep_walk := $FootstepWalk
@onready var footstep_run := $FootstepRun

const FALL_DEATH_Y = 1000.0

#Run
var is_running := false

#Health
var max_hp := 3
var current_hp := 3
var is_hurt := false

var is_dead = false
var is_attacking = false
var is_control_locked := false
var is_hidden := false
var is_landing := false
var is_locked_in_bush := false
var original_attack_x: float
var takedown_enemy = null
var current_takedown_target = null
var is_executing := false
var correct_qte_answer: String = ""

#Invertory
var pickup_target: Area2D = null

#Knockback
var is_knockback := false
var knockback_velocity := Vector2.ZERO
var knockback_timer := 0.0

#Hostage
var hostage_target : Area2D = null

func _ready():
	original_attack_x = attack_area.position.x
	
	sound_area.body_entered.connect(_on_sound_area_entered)
	sound_alert_triggered.connect(func(enemy): enemy.hear_sound_from(global_position))
	
	if QteManager.QTEPopup:
		QteManager.QTEPopup.submitted.connect(_on_qte_result)
	else:
		print("❌ QTEPopup ไม่พบใน _ready()")
		
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _physics_process(delta):
	var was_on_floor = is_on_floor()
	
	if is_dead or is_executing:
		return

	if is_executing:
		velocity = Vector2.ZERO
		move_and_slide()
		return  # ✅ หยุดไม่ให้อนิเมชั่นอื่นเล่นทับ

	if is_knockback:
		velocity = knockback_velocity
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knockback = false

	# ด้านล่างจะรันเฉพาะเมื่อไม่ dead, not executing, not knockback
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get input
	var direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	is_running = Input.is_action_pressed("run")
	var move_speed = run_speed if is_running else speed
	
	if not is_knockback:
		velocity.x = direction * move_speed
	
	# ปรับระยะตรวจจับเสียงตามสถานะวิ่ง
	if direction != 0:
		sound_area.monitoring = true
		sound_shape.shape.radius = 400.0 if is_running else 120.0
		
		if is_running:
			if not footstep_run.playing:
				footstep_walk.stop()
				footstep_run.play()
		else:
			if not footstep_walk.playing:
				footstep_run.stop()
				footstep_walk.play()
		
	else:
		sound_area.monitoring = false
		footstep_walk.stop()
		footstep_run.stop()
	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# Animation logic
	if is_hurt:
		anim.play("damaged")
		move_and_slide()
		return
	
	if is_attacking:
		move_and_slide()
		return  # อย่าเล่น animation อื่นระหว่างโจมตี
	else:
		if is_landing:
			return  # 🔒 ล็อกไว้ไม่ให้อนิเมชันอื่นเล่นทับ
		
		#Lock Hostage_Help
		if anim.animation == "hostage_help" and anim.is_playing():
			print("⛔ กำลังช่วยตัวประกันอยู่ → หยุดควบคุม")
			return
		
		if not is_on_floor():
			if velocity.y < 0:
				if anim.animation != "jump":
					$jump.play()
					anim.play("jump")
			else:
				if anim.animation != "fall":
					anim.play("fall")
		elif not was_on_floor and is_on_floor():
			is_landing = true
			anim.play("contact_floor")
		elif direction != 0:
			if is_running:
				anim.play("run")
			else:
				anim.play("walk")
		else:
			anim.play("idle")

	# Flip sprite
	if direction != 0:
		anim.flip_h = direction < 0
		attack_area.position.x = original_attack_x * (-1 if direction < 0 else 1)

	if is_locked_in_bush:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	move_and_slide()

	if global_position.y > FALL_DEATH_Y:
		die()
	
func _input(event):
	if event.is_action_pressed("attack") and !is_attacking and is_on_floor() and !is_hurt:
		is_attacking = true
		anim.play("attack")
		await get_tree().create_timer(0.15).timeout
		_attack()
		await get_tree().create_timer(0.2).timeout

	if event.is_action_pressed("takedown") and not is_control_locked and takedown_enemy:
		is_control_locked = true
		is_executing = true
		
		current_takedown_target = takedown_enemy
		velocity = Vector2.ZERO
		hide_takedown_prompt()

		# ✅ แค่สั่งศัตรูให้เริ่ม QTE
		takedown_enemy.try_start_qte()
	
	if event.is_action_pressed("pickup") and pickup_target:
		print("🎒 กำลังเก็บ: ", pickup_target.item_name)
		Inventory.add_item(pickup_target.item_name)
		pickup_target.queue_free()
		pickup_target = null
	
func _attack():
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(attack_damage, global_position)
		
		elif body.is_in_group("cage"):  # ✅ ตีกรงได้
			if body.has_method("take_hit"):
				body.take_hit()

func _on_sound_area_entered(body):
	if body.is_in_group("enemy") and not body.is_alerted():
		emit_signal("sound_alert_triggered", body)

func die():
	is_dead = true
	anim.play("dead")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "damaged":
		is_hurt = false
	
	if anim.animation == "attack":
		is_attacking = false

		# กลับไป idle หลังจบการโจมตี
		if is_on_floor():
			if velocity.x == 0:
				anim.play("idle")
			else:
				anim.play("walk")
		else:
			anim.play("fall")
	
	if anim.animation == "execute_hand" or anim.animation == "prepare" or anim.animation == "tree_takedown":
		if not is_on_floor():
			anim.play("fall")
		elif velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")
	
	if anim.animation == "contact_floor":
		is_landing = false
		if velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")

func _on_qte_result(success: bool):
	if not success:
		print("❌ ล้มเหลว")
		if current_takedown_target:
			current_takedown_target.alert_from_behind()
		is_control_locked = false
		is_executing = false
		current_takedown_target = null
		return
	else:
		# ✅ ถ้าตอบถูก ให้รอ Enemy ส่ง signal takedown_success มา
		if current_takedown_target:
			current_takedown_target.takedown_success.connect(_on_takedown_complete, CONNECT_ONE_SHOT)

func _on_takedown_complete():
	if current_takedown_target:
		current_takedown_target.insta_kill()  # ⚡ ตายทันที
	
	if not is_on_floor():
		anim.play("tree_takedown")
		await  wait_for_animation("tree_takedown")
	else:
		anim.play("execute_hand")
		await wait_for_animation("execute_hand")

	is_control_locked = false
	is_executing = false
	current_takedown_target = null

	# ✅ กลับ animation ปกติ
	if is_on_floor():
		if velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")
	else:
		anim.play("fall")

func set_takedown_target(enemy):
	takedown_enemy = enemy

func _get_takedown_enemy():
	return takedown_enemy

func toggle_hide():
	is_hidden = !is_hidden
	visible = not is_hidden
	print("🌿 ซ่อนตัว:", is_hidden)
	
	if is_hidden:
		is_locked_in_bush = true
		set_collision_mask_value(2, false)
		set_collision_layer_value(1, false)
		collision_shape.disabled = true
		
		# ✅ ส่งสัญญาณให้ศัตรู reset
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if enemy.player_ref == self:
				print("🧹 รีเซ็ตศัตรู: ", enemy.name)
				enemy.player_ref = null
				enemy.is_chasing = false
				enemy.player_in_range = null
				enemy.alerted = false
			else:
				print("❌ ไม่ตรง: ", enemy.name, " / player_ref = ", enemy.player_ref)

	else:
		is_locked_in_bush = false
		set_collision_mask_value(2, true)
		set_collision_layer_value(1, true)
		collision_shape.disabled = false

func cover_takedown(enemies: Array):
	for enemy in enemies:
		print("🧠 ตรวจศัตรู: ", enemy.name)
		if not enemy.is_in_group("enemy"):
			print("⛔ ไม่ใช่ศัตรู")
			continue
		if not enemy.has_method("insta_kill"):
			print("⛔ ไม่มีฟังก์ชัน insta_kill")
			continue
		if enemy.is_alerted():
			print("⚠️ ศัตรู alert อยู่ → ไม่ฆ่า")
			continue

		print("☠️ ลอบสังหารสำเร็จ: ", enemy.name)
		enemy.insta_kill()
		break

func show_takedown_prompt():
	if takedown_label:
		takedown_label.visible = true

func hide_takedown_prompt():
	if takedown_label:
		takedown_label.visible = false

func wait_for_animation(anim_name: String) -> void:
	while anim.animation != anim_name:
		await get_tree().process_frame
	while anim.animation == anim_name and anim.is_playing():
		await anim.animation_finished

func set_pickup_target(item: Area2D):
	pickup_target = item

func receive_damage(amount: int, from_pos: Vector2):
	if is_dead or is_hurt:
		return

	# ✅ ยกเลิกการโจมตีทันทีเมื่อโดนตี
	is_attacking = false
	is_control_locked = false
	is_executing = false

	current_hp -= amount
	is_hurt = true
	print("โดนโจมตี!! - HP:", current_hp)
	
	$hurt.play()
	anim.play("damaged")

	var knock_dir = (global_position - from_pos).normalized()
	knock_dir.y = 0
	knockback_velocity = knock_dir * 300
	knockback_timer = 0.5
	is_knockback = true

	if current_hp <= 0:
		die()

func play_tree_takedown():
	print("🎬 Playing execute_tree")
	is_control_locked = true
	is_executing = true

	anim.play("tree_takedown")
	await wait_for_animation("tree_takedown")

	is_control_locked = false
	is_executing = false

	# กลับ animation ปกติ
	if is_on_floor():
		if velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")
	else:
		anim.play("fall")

func set_hostage_target(hostage: Area2D):
	if hostage_target:
		if hostage_target.is_connected("start_rescue", _on_start_rescue):
			hostage_target.disconnect("start_rescue", _on_start_rescue)
		if hostage_target.is_connected("rescued", _on_rescue_done):
			hostage_target.disconnect("rescued", _on_rescue_done)
		if hostage_target.is_connected("cancel_rescue", _on_rescue_cancelled):
			hostage_target.disconnect("cancel_rescue", _on_rescue_cancelled)

	hostage_target = hostage

	if hostage_target:
		if not hostage_target.is_connected("start_rescue", _on_start_rescue):
			hostage_target.connect("start_rescue", _on_start_rescue)
		if not hostage_target.is_connected("rescued", _on_rescue_done):
			hostage_target.connect("rescued", _on_rescue_done)
		if not hostage_target.is_connected("cancel_rescue", _on_rescue_cancelled):
			hostage_target.connect("cancel_rescue", _on_rescue_cancelled)

func _on_start_rescue():
	if not is_control_locked and anim.animation != "hostage_help":
		is_control_locked = true
		anim.play("hostage_help")

func _on_rescue_done():
	is_control_locked = false
	
	# ✅ กลับไปเล่น animation ปกติ
	if is_on_floor():
		if velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")
	else:
		anim.play("fall")

func _on_rescue_cancelled():
	if is_control_locked:
		is_control_locked = false

		# กลับไปเล่น animation ปกติ
		if is_on_floor():
			if velocity.x == 0:
				anim.play("idle")
			else:
				anim.play("walk")
		else:
			anim.play("fall")
