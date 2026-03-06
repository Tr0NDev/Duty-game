extends Panel

@onready var debug_label: Label = $Label

func _ready():
	hide_panel()

func show_flag():
	debug_label.text = "Round: " + str(GameSettings.flaground) + "/5"
	visible = true

func hide_panel():
	visible = false
