extends Area2D

@export var tutorial_step_index := 0 
var triggered := false

func _on_body_entered(body):
	if triggered:
		return

	if body.name == "Player":
		print("🟣 ผู้เล่นเข้า Step %d" % tutorial_step_index)
		triggered = true

		if TutorialManager.current_step == tutorial_step_index:
			TutorialManager.next_step()

		await get_tree().create_timer(0.5).timeout
		queue_free() # หรือ self.visible = false
