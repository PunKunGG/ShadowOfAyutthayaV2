extends CanvasLayer

@onready var hp_bar = $VBoxContainer/HPBar
@onready var stamina_bar = $VBoxContainer/StaminaBar

func set_objectives(objective1: String, objective2: String):
	var rope_label = get_node("ObjectiveList/RopeLabel")
	var ladder_label = get_node("ObjectiveList/LadderLabel")
	rope_label.text = "☐ " + objective1
	ladder_label.text = "☐ " + objective2
	rope_label.add_theme_color_override("font_color", Color.WHITE)
	ladder_label.add_theme_color_override("font_color", Color.WHITE)

func mark_rope_collected():
	var rope_label = get_node("ObjectiveList/RopeLabel")
	rope_label.text = "✅ " + rope_label.text.substr(2)
	rope_label.add_theme_color_override("font_color", Color.GREEN)

func mark_ladder_collected():
	var ladder_label = get_node("ObjectiveList/LadderLabel")
	ladder_label.text = "✅ " + ladder_label.text.substr(2)
	ladder_label.add_theme_color_override("font_color", Color.GREEN)

func update_health_bar(current: int, _max: int):
	hp_bar.value = current
	hp_bar.max_value = _max

func update_stamina_bar(current: int, _max: int):
	stamina_bar.value = current
	stamina_bar.max_value = _max
