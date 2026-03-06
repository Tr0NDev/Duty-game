extends Control

@export var editor_scene: String = "res://editor/editor.tscn"

@onready var longeur: SpinBox = $Longeur
@onready var largeur: SpinBox = $Largeur
@onready var name_edit: TextEdit = $TextEdit

const SAVE_FOLDER := "user://maps/"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)
	
	var line_edit := longeur.get_line_edit()
	line_edit.add_theme_font_size_override("font_size", 50)
	line_edit = largeur.get_line_edit()
	line_edit.add_theme_font_size_override("font_size", 50)

	name_edit.text = get_unique_filename("Map", false)


func _on_button_pressed() -> void:
	var w = int(longeur.value)
	var h = int(largeur.value)
	var name = name_edit.text.strip_edges()

	if name == "":
		push_error("Nom de fichier vide.")
		return

	var file_path = get_unique_filename(name, true)

	var json_data = _generate_json_map(w, h)

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(json_data, "\t"))
	file.close()

	print("Map sauvegardée :", file_path)

	Global.current_map_path = file_path
	var editor: PackedScene = load(editor_scene)
	get_tree().change_scene_to_packed(editor)
	
	

func get_unique_filename(base: String, retour: bool) -> String:
	var path = SAVE_FOLDER + base + ".json"
	var nom = base
	var i := 1

	while FileAccess.file_exists(path):
		path = SAVE_FOLDER + base + "_" + str(i) + ".json"
		nom = base + "_" + str(i)
		i += 1
		
	if retour:
		return path
	else:
		return nom


func _generate_json_map(width: int, height: int) -> Dictionary:
	var tiles := []

	for y in range(height):
		var row := []
		for x in range(width):
			row.append(2)
		tiles.append(row)

	return {
		"width": width,
		"height": height,
		"tiles": tiles,
		"buildings": {}
	}
