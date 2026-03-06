extends Panel

@onready var info_label: Label = $Info


func _ready():
	hide_panel()

func show_unit(unit):
	var texte = "HP: " + str(unit.hp) + "/" + str(unit.max_hp) + "\nTeam : " + str(unit.team) + "\nAttack: " + str(unit.atk) + "\nAttack Range: " + str(unit.attack_range) + "\nMovement Range: " + str(unit.movement_range)
	if unit.team == GameSettings.playerturn:
		texte += "\nAmmo: " + str(unit.ammo)
	info_label.text = texte
	visible = true

func hide_panel():
	visible = false
