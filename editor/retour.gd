extends Button

@export var main_menu: String = "res://menu/choosemap.tscn"

func _on_pressed() -> void:
	var menu_scene := load(main_menu)
	get_tree().change_scene_to_packed(menu_scene)
