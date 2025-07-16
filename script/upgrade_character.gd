extends Control

@onready var level_label := $VBoxContainer/LevelLabel
@onready var score_label := $VBoxContainer/ScoreLabel
@onready var upgrade_button := $Upgrade
@onready var qte_range_label := $QTERangeLabel
@onready var tween := $Tween

func _ready():
	$BGSong.play()
	
	update_ui()
	upgrade_button.pressed.connect(_on_upgrade_pressed)

func update_ui():
	level_label.text = "Current Level: Lv.%d" % PlayerStat.upgrade_level
	score_label.text = "Score: %d" % PlayerStat.score
	upgrade_button.disabled = not PlayerStat.can_upgrade()
	
	#QTE Range
	var qte_range = PlayerStat.get_qte_range()
	qte_range_label.text = "QTE ต้องกด : %d - %d คำ ในการสังหารศัตรู" % [qte_range.x, qte_range.y]

	#QTE Color
	match PlayerStat.upgrade_level >= 3:
		1: qte_range_label.add_theme_color_override("font_color", Color.WHITE)
		2: qte_range_label.add_theme_color_override("font_color", Color.YELLOW)
		3: qte_range_label.add_theme_color_override("font_color", Color.GREEN)
	
	#Upgrade Button
	if PlayerStat.upgrade_level >= 3:
		upgrade_button.text = "MAXED UPGRADE!!"
		upgrade_button.disabled = true
	else:
		upgrade_button.text = "Upgrade"
		upgrade_button.disabled = not PlayerStat.can_upgrade()
	
func _on_upgrade_pressed():
	$Click.play()
	PlayerStat.upgrade()
	_play_upgrade_effect()
	update_ui()

func _play_upgrade_effect():
	tween.kill_all()  # ลบ Tween เดิมก่อน
	upgrade_button.scale = Vector2.ONE  # รีเซ็ตขนาด
	
	tween.tween_property(upgrade_button, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(upgrade_button, "scale", Vector2.ONE, 0.1).set_delay(0.1)

func _on_back_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
