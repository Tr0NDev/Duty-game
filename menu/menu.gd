extends Control

@export var game_scene_path: String = "res://menu/choosemap.tscn"


func _ready():
	copy_maps_if_maps_folder_empty()


func copy_maps_if_maps_folder_empty():
	var user_maps_path := "user://maps"

	if not DirAccess.dir_exists_absolute(user_maps_path):
		DirAccess.make_dir_recursive_absolute(user_maps_path)

	if not is_directory_empty(user_maps_path):
		return

	copy_directory_recursive("res://map", user_maps_path)


func is_directory_empty(path: String) -> bool:
	var dir := DirAccess.open(path)
	if dir == null:
		return true

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name != "." and file_name != "..":
			dir.list_dir_end()
			return false
		file_name = dir.get_next()

	dir.list_dir_end()
	return true


func copy_directory_recursive(from_path: String, to_path: String):
	var dir := DirAccess.open(from_path)
	if dir == null:
		push_error("Impossible d'ouvrir : " + from_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name != "." and file_name != "..":
			var from_file := from_path + "/" + file_name
			var to_file := to_path + "/" + file_name

			if dir.current_is_dir():
				if not DirAccess.dir_exists_absolute(to_file):
					DirAccess.make_dir_recursive_absolute(to_file)

				copy_directory_recursive(from_file, to_file)

			else:
				if not FileAccess.file_exists(to_file):
					DirAccess.copy_absolute(from_file, to_file)

		file_name = dir.get_next()

	dir.list_dir_end()



func _on_play_button_pressed() -> void:
	var game_scene: PackedScene = load(game_scene_path)
	get_tree().change_scene_to_packed(game_scene)
