extends Control

signal submitted(is_success: bool)

@onready var question_label := $QuestionLabel
@onready var timer_label := $TimerLabel
@onready var buttons := [
	$OptionContainer/Button1,
	$OptionContainer/Button2,
	$OptionContainer/Button3
]
@onready var warning_sound := $WarningSound
@onready var failed_sound := $FailedSound

var correct_word := ""
var time_left := 10.0
var counting := false

func _ready():
	visible = false
	for btn in buttons:
		btn.pressed.connect(_on_button_pressed.bind(btn))

func start(question: String, choices: Array, answer: String, target_position: Vector2):
	visible = true
	time_left = 10.0
	counting = true
	timer_label.text = "Time Left: %.2f" % time_left
	correct_word = answer
	question_label.text = question

	for i in range(3):
		var btn: Button = buttons[i]
		btn.text = str(i + 1) + ". " + choices[i]
		btn.disabled = false
		btn.modulate = Color.WHITE
		btn.show()

	# เปลี่ยนจาก global_position เป็น position เฉย ๆ
	print("📍 QTE Position:", target_position)
	position = get_viewport_rect().size / 2  # ✅ วางกลางจอแน่นอน

	get_tree().paused = true
	timer_label.modulate = Color.WHITE

func _process(delta):
	if not counting:
		return
	time_left -= delta
	timer_label.text = "Time Left: %.2f" % time_left
	if time_left <= 5.0:
		timer_label.modulate = Color.RED
		if not warning_sound.playing:
			warning_sound.play()
	if time_left <= 0:
		counting = false
		visible = false
		failed_sound.play()
		submitted.emit(false)
		get_tree().paused = false

func _on_button_pressed(btn: Button):
	if not counting:
		return

	counting = false
	for b in buttons:
		b.disabled = true

	var selected := btn.text.split(". ", false)[1]
	var is_correct := selected == correct_word

	btn.modulate = (Color.GREEN if is_correct else Color.RED)
	if not is_correct:
		failed_sound.play()

	await get_tree().create_timer(0.3).timeout  # ✅ รอแสดงสีให้เห็นก่อน

	visible = false
	get_tree().paused = false
	submitted.emit(is_correct)

func _input(event):
	if not visible or not counting:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_button_pressed(buttons[0])
			KEY_2:
				_on_button_pressed(buttons[1])
			KEY_3:
				_on_button_pressed(buttons[2])
