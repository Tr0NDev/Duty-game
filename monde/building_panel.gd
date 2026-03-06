extends Panel

@onready var building_label: Label = $Buildinglabel
@onready var production_container: VBoxContainer = $VBoxContainer
@onready var management := $"../../Management"
@onready var unitpanel := $"../Stats"

func _ready():
	hide_panel()


func show_building(building):
	custom_minimum_size.y = 0
	var unit_count := 0

	var texte := "Team : " + str(building.team) \
		+ "\nType: " + str(building.type) \
		+ "\nIncome: " + str(building.income)

	building_label.text = texte

	for child in production_container.get_children():
		child.queue_free()

	if GameSettings.playerturn == building.team and building.production != null:
		for value in building.production:
			unit_count += 1

			var cost : int = GameSettings.unitdata[value][0]
			var btn := Button.new()
			btn.text = "Price: " + str(cost)

			var tex := load("res://sprite/unit/" + value + "/" + value + "_ld.png")
			btn.icon = tex

			var can_buy := false
			for player in GameSettings.playerlist:
				if player.team == GameSettings.playerturn:
					can_buy = player.money >= cost
					break

			btn.disabled = not can_buy
			if btn.disabled:
				btn.tooltip_text = "Not enough money"

			btn.pressed.connect(func():
				for player in GameSettings.playerlist:
					if player.team == GameSettings.playerturn:
						if player.money >= cost:
							player.money -= cost
							var newunit = management.spawn_unit(
								building.tile_pos,
								player.team,
								value,
								true
							)
							visible = false
							unitpanel.show_unit(newunit)
			)

			production_container.add_child(btn)

		custom_minimum_size.y += unit_count * 150

	visible = true


func hide_panel():
	visible = false
