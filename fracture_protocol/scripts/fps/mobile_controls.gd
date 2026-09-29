extends Control
class_name FractureMobileControls

## FPS için dokunmatik katman:
## sol başparmak sanal joystick, sağ yüzey kamera bakışı, sağ alt eylem düğmeleri.

var move_touch_id := -1
var look_touch_id := -1
var fire_touch_id := -1
var move_origin := Vector2.ZERO
var move_position := Vector2.ZERO
var move_vector := Vector2.ZERO
var look_delta := Vector2.ZERO
var fire_pressed := false
var reload_requested := false
var interact_requested := false
var weapon_switch_requested := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process_input(true)
    visible = DisplayServer.is_touchscreen_available()
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            visible = true
            _begin_touch(event.index, event.position)
        else:
            _end_touch(event.index)
        queue_redraw()
    elif event is InputEventScreenDrag:
        visible = true
        _update_touch(event.index, event.position, event.relative)
        queue_redraw()

func _begin_touch(index: int, position: Vector2) -> void:
    var size := get_viewport_rect().size
    if _move_zone(size).has_point(position) and move_touch_id == -1:
        move_touch_id = index
        move_origin = position
        move_position = position
        return
    if _fire_zone(size).has_point(position) and fire_touch_id == -1:
        fire_touch_id = index
        fire_pressed = true
        return
    if _reload_zone(size).has_point(position):
        reload_requested = true
        return
    if _weapon_zone(size).has_point(position):
        weapon_switch_requested = true
        return
    if _interact_zone(size).has_point(position):
        interact_requested = true
        return
    if look_touch_id == -1:
        look_touch_id = index

func _update_touch(index: int, position: Vector2, relative: Vector2) -> void:
    var size := get_viewport_rect().size
    if index == move_touch_id:
        move_position = position
        var radius := minf(size.x, size.y) * 0.13
        move_vector = (move_position - move_origin).limit_length(radius) / radius
    elif index == look_touch_id:
        look_delta += relative
    elif index == fire_touch_id:
        fire_pressed = _fire_zone(size).has_point(position)

func _end_touch(index: int) -> void:
    if index == move_touch_id:
        move_touch_id = -1
        move_vector = Vector2.ZERO
    if index == look_touch_id:
        look_touch_id = -1
    if index == fire_touch_id:
        fire_touch_id = -1
        fire_pressed = false

func get_move_vector() -> Vector2:
    return move_vector

func consume_look_delta() -> Vector2:
    var delta := look_delta
    look_delta = Vector2.ZERO
    return delta

func consume_reload() -> bool:
    var requested := reload_requested
    reload_requested = false
    return requested

func consume_interact() -> bool:
    var requested := interact_requested
    interact_requested = false
    return requested

func consume_weapon_switch() -> bool:
    var requested := weapon_switch_requested
    weapon_switch_requested = false
    return requested

func _move_zone(size: Vector2) -> Rect2:
    var unit := minf(size.x, size.y)
    return Rect2(0, size.y - unit * 0.42, unit * 0.42, unit * 0.42)

func _fire_zone(size: Vector2) -> Rect2:
    var unit := minf(size.x, size.y)
    return Rect2(size.x - unit * 0.34, size.y - unit * 0.38, unit * 0.34, unit * 0.38)

func _reload_zone(size: Vector2) -> Rect2:
    var unit := minf(size.x, size.y)
    return Rect2(size.x - unit * 0.31, size.y - unit * 0.17, unit * 0.12, unit * 0.12)

func _weapon_zone(size: Vector2) -> Rect2:
    var unit := minf(size.x, size.y)
    return Rect2(size.x - unit * 0.45, size.y - unit * 0.17, unit * 0.12, unit * 0.12)

func _interact_zone(size: Vector2) -> Rect2:
    var unit := minf(size.x, size.y)
    return Rect2(size.x * 0.5 + unit * 0.18, size.y - unit * 0.17, unit * 0.14, unit * 0.12)

func _draw() -> void:
    if not visible:
        return
    var size := get_viewport_rect().size
    var unit := minf(size.x, size.y)
    var radius := unit * 0.13
    var base := Vector2(unit * 0.2, size.y - unit * 0.19)
    var knob := move_position if move_touch_id != -1 else base
    if move_touch_id == -1:
        knob = base
    draw_circle(base, radius, Color(0.04, 0.12, 0.16, 0.46))
    draw_arc(base, radius, 0.0, TAU, 32, Color(0.32, 0.82, 0.88, 0.75), 3.0)
    draw_circle(knob, radius * 0.46, Color(0.16, 0.67, 0.74, 0.72))
    _draw_button(_fire_center(size), unit * 0.105, "ATEŞ", Color(0.92, 0.28, 0.16, 0.72), fire_pressed)
    _draw_button(_reload_center(size), unit * 0.055, "R", Color(0.15, 0.52, 0.62, 0.72), false)
    _draw_button(_weapon_center(size), unit * 0.055, "1/2", Color(0.78, 0.52, 0.2, 0.72), false)
    _draw_button(_interact_center(size), unit * 0.06, "E", Color(0.2, 0.68, 0.5, 0.72), false)

func _draw_button(center: Vector2, radius: float, label: String, color: Color, active: bool) -> void:
    draw_circle(center, radius, color if active else Color(color.r, color.g, color.b, 0.42))
    draw_arc(center, radius, 0.0, TAU, 24, Color(0.88, 0.96, 0.96, 0.8), 2.0)
    draw_string(ThemeDB.fallback_font, center + Vector2(-radius * 0.48, 6.0), label, HORIZONTAL_ALIGNMENT_CENTER, radius * 0.96, maxf(13.0, radius * 0.34), Color(0.96, 0.98, 0.98, 0.95))

func _fire_center(size: Vector2) -> Vector2:
    var unit := minf(size.x, size.y)
    return Vector2(size.x - unit * 0.17, size.y - unit * 0.2)

func _reload_center(size: Vector2) -> Vector2:
    var unit := minf(size.x, size.y)
    return Vector2(size.x - unit * 0.25, size.y - unit * 0.105)

func _weapon_center(size: Vector2) -> Vector2:
    var unit := minf(size.x, size.y)
    return Vector2(size.x - unit * 0.39, size.y - unit * 0.105)

func _interact_center(size: Vector2) -> Vector2:
    var unit := minf(size.x, size.y)
    return Vector2(size.x * 0.5 + unit * 0.25, size.y - unit * 0.105)
