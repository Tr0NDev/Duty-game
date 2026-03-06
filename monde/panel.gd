extends Panel


@onready var boutonsuivant = $"Suivant"
@onready var passturncontrole = $"../../Passturn"

func _on_button_pressed() -> void:
	passturncontrole.nextturn()

func show_panel():
	visible = true

func hide_panel():
	visible = false
	
