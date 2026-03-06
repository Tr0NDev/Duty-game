extends Control

@export var game_scene: String = "res://monde/monde.tscn"
@export var editor_scene: String = "res://editor/editor.tscn"
@export var editor_menu: String = "res://editor/editormenu.tscn"
const MAP_FOLDER := "user://maps/"


@onready var map_list := $ScrollContainer/VBoxContainer


func _ready():
	load_map_buttons()


func load_map_buttons() -> void:
	var dir := DirAccess.open(MAP_FOLDER)
	if dir == null:
		print("Dossier maps introuvable, création…")
		DirAccess.make_dir_recursive_absolute(MAP_FOLDER)
		return

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			create_map_button(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()


func create_map_button(file_name: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 200)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var play_btn := Button.new()
	play_btn.text = file_name.get_basename()
	play_btn.custom_minimum_size = Vector2(400, 200)
	play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_btn.add_theme_font_size_override("font_size", 40)
	play_btn.pressed.connect(on_map_selected.bind(file_name))

	var edit_btn := Button.new()
	edit_btn.text = "✏"
	edit_btn.custom_minimum_size = Vector2(120, 200)
	edit_btn.add_theme_font_size_override("font_size", 40)
	edit_btn.pressed.connect(on_map_edit.bind(file_name))

	var delete_btn := Button.new()
	delete_btn.text = "🗑"
	delete_btn.custom_minimum_size = Vector2(120, 200)
	delete_btn.add_theme_font_size_override("font_size", 40)
	delete_btn.pressed.connect(on_map_delete.bind(file_name, row))

	row.add_child(play_btn)
	row.add_child(edit_btn)
	row.add_child(delete_btn)

	map_list.add_child(row)


func on_map_delete(file_name: String, row: Control) -> void:
	var path := MAP_FOLDER + file_name

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Map supprimée :", file_name)

	row.queue_free()
	
func on_map_edit(file_name: String) -> void:
	print("Édition de la map :", file_name)

	Global.current_map_path = MAP_FOLDER + file_name

	var editor_packed := load(editor_scene)
	get_tree().change_scene_to_packed(editor_packed)



func on_map_selected(file_name: String):
	print("Map sélectionnée :", file_name)
	Global.current_map_path = MAP_FOLDER + file_name
	var game_scene_packed := load(game_scene)
	get_tree().change_scene_to_packed(game_scene_packed)


func _on_button_pressed() -> void:
	var editor_menu_scene := load(editor_menu)
	get_tree().change_scene_to_packed(editor_menu_scene)
