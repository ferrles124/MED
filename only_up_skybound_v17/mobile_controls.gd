extends Control

@export var joystick_scale: float = 1.0
@export var look_sensitivity: float = 1.0

var move_vector := Vector2.ZERO
var jump_requested := false
var _move_touch := -1
var _look_touch := -1
var _look_delta := Vector2.ZERO
var _last_look := Vector2.ZERO
var _center := Vector2.ZERO
var _knob := Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    var s := get_viewport_rect().size
    var r: float = min(s.x, s.y) * 0.13 * joystick_scale
    _center = Vector2(r * 1.35, s.y - r * 1.35)
    if _move_touch == -1:
        _knob = _center
    draw_circle(_center, r, Color(0.02, 0.04, 0.08, 0.42))
    draw_circle(_knob, r * 0.42, Color(0.45, 0.78, 1.0, 0.75))
    var jump_rect := Rect2(s.x - 165, s.y - 150, 125, 85)
    _draw_button(jump_rect, "ZIPLA", jump_requested)
    draw_string(ThemeDB.fallback_font, Vector2(22, 36), "SOL: hareket    SAĞ: kamera", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 1, 1, 0.72))

func _draw_button(rect: Rect2, text: String, active: bool) -> void:
    var box := StyleBoxFlat.new()
    box.bg_color = Color(0.1, 0.68, 1.0, 0.82) if active else Color(0.03, 0.06, 0.11, 0.62)
    box.corner_radius_top_left = 18
    box.corner_radius_top_right = 18
    box.corner_radius_bottom_left = 18
    box.corner_radius_bottom_right = 18
    box.border_width_left = 2
    box.border_width_top = 2
    box.border_width_right = 2
    box.border_width_bottom = 2
    box.border_color = Color(1, 1, 1, 0.4)
    draw_style_box(box, rect)
    draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, rect.size.y * 0.63), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 16, 18, Color.WHITE)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _touch(event.index, event.position, event.pressed)
    elif event is InputEventScreenDrag:
        _drag(event.index, event.position)

func _touch(index: int, pos: Vector2, pressed: bool) -> void:
    var s := get_viewport_rect().size
    var jump_rect := Rect2(s.x - 165, s.y - 150, 125, 85)
    if pressed:
        if pos.distance_to(_center) < min(s.x, s.y) * 0.2 * joystick_scale and _move_touch == -1:
            _move_touch = index
            _update_joystick(pos)
        elif jump_rect.has_point(pos):
            jump_requested = true
        elif pos.x > s.x * 0.42 and _look_touch == -1:
            _look_touch = index
            _last_look = pos
    else:
        if index == _move_touch:
            _move_touch = -1
            move_vector = Vector2.ZERO
            _knob = _center
        elif index == _look_touch:
            _look_touch = -1
    queue_redraw()

func _drag(index: int, pos: Vector2) -> void:
    if index == _move_touch:
        _update_joystick(pos)
    elif index == _look_touch:
        _look_delta += pos - _last_look
        _last_look = pos

func _update_joystick(pos: Vector2) -> void:
    var max_radius: float = min(size.x, size.y) * 0.13 * joystick_scale
    var offset := pos - _center
    if offset.length() > max_radius:
        offset = offset.normalized() * max_radius
    _knob = _center + offset
    move_vector = offset / max_radius

func consume_look_delta() -> Vector2:
    var result := _look_delta
    _look_delta = Vector2.ZERO
    return result * look_sensitivity
