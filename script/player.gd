extends CharacterBody2D

@export var speed := 250
@export var jump_velocity := -650
@export var gravity := 1200
@export var attack_damage := 1

@onready var qte_popup = QteManager.QTEPopup
@onready var anim := $AnimatedSprite2D
@onready var attack_area := $AttackArea
@onready var takedown_label := $"TakedownLabel"

const FALL_DEATH_Y = 1000.0

#Health
var max_hp := 3
var current_hp := 3
var is_hurt := false

var is_dead = false
var is_attacking = false
var is_control_locked := false
var is_hidden := false
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

func _ready():
	original_attack_x = attack_area.position.x
	
	if QteManager.QTEPopup:
		QteManager.QTEPopup.submitted.connect(_on_qte_result)
	else:
		print("❌ QTEPopup ไม่พบใน _ready()")

func _physics_process(delta):
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
	
	if not is_knockback:
		velocity.x = direction * speed

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# Animation logic
	if is_attacking:
		move_and_slide()
		return  # อย่าเล่น animation อื่นระหว่างโจมตี
	
	if is_hurt:
		anim.play("damaged")
	else:
		if not is_on_floor():
			if velocity.y < 0:
				$jump.play()
				anim.play("jump")
			else:
				anim.play("fall")
		elif direction != 0:
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
	if event.is_action_pressed("attack") and !is_attacking and is_on_floor():
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

func die():
	is_dead = true
	anim.play("dead")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")

func _on_animated_sprite_2d_animation_finished():
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
	
	if anim.animation == "execute" or anim.animation == "prepare":
		if not is_on_floor():
			anim.play("fall")
		elif velocity.x == 0:
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

	anim.play("execute")
	await wait_for_animation("execute")

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

	if is_hidden:
		is_locked_in_bush = true
		set_collision_mask_value(2, false)  # ไม่ชนศัตรู
	else:
		is_locked_in_bush = false
		set_collision_mask_value(2, true)

func cover_takedown(enemies: Array):
	for enemy in enemies:
		if enemy.has_method("insta_kill") and not enemy.is_alerted():
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

	current_hp -= amount
	is_hurt = true
	print("โดนโจมตี!! - HP:", current_hp)

	anim.play("damaged")

	# ✅ เริ่ม knockback
	var knock_dir = (global_position - from_pos).normalized()
	knock_dir.y = 0
	knockback_velocity = knock_dir * 300
	knockback_timer = 0.5
	is_knockback = true

	# ✅ ตั้ง cooldown ชัดเจน
	await get_tree().create_timer(0.4).timeout
	is_hurt = false

	if current_hp <= 0:
		die()
