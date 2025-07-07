extends CanvasLayer

var QTEPopup: Control
var popup: Control

func _ready():
	var popup_scene = load("res://qte_popup.tscn")
	popup = popup_scene.instantiate()
	add_child(popup)
	popup.visible = false
	
	QTEPopup = popup
