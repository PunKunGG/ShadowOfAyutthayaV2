extends Area2D

@export var tutorial_step_index := 0 
@export var message: String = ""  # ✅ เพิ่มข้อความที่จะแสดง

var triggered := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$TutorialLabel.visible = false

func _on_body_entered(body):
	if triggered:
		return

	if body.name == "Player":
		print("🟣 ผู้เล่นเข้า Step %d" % tutorial_step_index)
		triggered = true

		# ✅ แสดงข้อความจาก Label ลูกของ Step เอง
		var label = $TutorialLabel
		if label:
			label.text = message
			label.visible = true

		await get_tree().create_timer(5.0).timeout  # ⏳ รอให้ผู้เล่นอ่าน
		if label:
			label.visible = false

		queue_free()
