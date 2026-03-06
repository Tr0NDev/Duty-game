extends Panel

@onready var debug_label: Label = $Label

func _ready():
	hide_panel()

func show_debug():
	debug_label.text = "Case: " + str(GameSettings.debugcase)
	visible = true

func hide_panel():
	visible = false
