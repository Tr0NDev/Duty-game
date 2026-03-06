extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 1
@export var max_zoom := 10
@export var limit_cam := 200

var dragging := false
var last_mouse_pos := Vector2.ZERO

var pinch_active := false
var initial_pinch_distance := 0.0
var touch_points := {}


func _input(event):
	if GameSettings.turnover == 1:
		zoom = Vector2(3, 3)
		global_position = Vector2.ZERO
	else:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				zoom_camera(-1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				zoom_camera(1)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				dragging = event.pressed
				last_mouse_pos = event.position

		elif event is InputEventMouseMotion and dragging:
			position -= event.relative / zoom
			_clamp_position()

		elif event is InputEventScreenTouch:
			var index = event.index 
			if event.pressed:
				touch_points[index] = event.position
			else:
				touch_points.erase(index)
			
			_update_pinch_state()

		elif event is InputEventScreenDrag:
			var index = event.index
			if touch_points.has(index):
				touch_points[index] = event.position
			
			if touch_points.size() == 1 and not pinch_active:
				position -= event.relative / zoom
				_clamp_position()
			
			elif pinch_active:
				var current_pinch_distance = _calculate_pinch_distance()
				
				if initial_pinch_distance > 0:
					var factor = current_pinch_distance / initial_pinch_distance
					var new_zoom = zoom * factor
					
					new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
					new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
					zoom = new_zoom
					_clamp_position()

					initial_pinch_distance = current_pinch_distance


func _update_pinch_state():
	if touch_points.size() >= 2:
		if not pinch_active:
			pinch_active = true
			initial_pinch_distance = _calculate_pinch_distance()
	else:
		pinch_active = false
		initial_pinch_distance = 0.0
		
func _calculate_pinch_distance() -> float:
	if touch_points.size() < 2:
		return 0.0
		
	var keys = touch_points.keys()
	var pos1 = touch_points[keys[0]]
	var pos2 = touch_points[keys[1]]
	
	return pos1.distance_to(pos2)
	
func zoom_camera(direction: int):
	var new_zoom = zoom * (1 + direction * zoom_speed)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom

func _clamp_position():
	position.x = clamp(position.x, -limit_cam, limit_cam)
	position.y = clamp(position.y, -limit_cam, limit_cam)
