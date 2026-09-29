extends Control
class_name FightMobileControls

var move_vector := Vector2.ZERO
var look_delta := Vector2.ZERO
var jab_requested := false
var cross_requested := false
var _move_touch_id := -1
var _look_touch_id := -1
var _mouse_moving := false
var _mouse_looking := false
var _center := Vector2.ZERO
@onready var base: Panel = $Joystick/Base
@onready var knob: Panel = $Joystick/Knob
@onready var look_panel: Control = $LookPanel
@onready var jab: Button = $Actions/Jab
@onready var cross: Button = $Actions/Cross

func _ready() -> void:
    base.gui_input.connect(_on_joystick_input)
    look_panel.gui_input.connect(_on_look_input)
    jab.pressed.connect(func() -> void: jab_requested = true)
    cross.pressed.connect(func() -> void: cross_requested = true)
    _reset_joystick()

func _process(_delta: float) -> void:
    _center = base.size * 0.5
    if _move_touch_id == -1: _reset_joystick()

func _on_joystick_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _move_touch_id == -1:
            _move_touch_id = event.index
            _move_knob(event.position)
        elif not event.pressed and event.index == _move_touch_id:
            _move_touch_id = -1
            move_vector = Vector2.ZERO
    elif event is InputEventScreenDrag and event.index == _move_touch_id:
        _move_knob(event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        _mouse_moving = event.pressed
        if _mouse_moving:
            _move_knob(event.position)
        else:
            move_vector = Vector2.ZERO
    elif event is InputEventMouseMotion and _mouse_moving:
        _move_knob(event.position)

func _on_look_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _look_touch_id == -1:
            _look_touch_id = event.index
        elif not event.pressed and event.index == _look_touch_id:
            _look_touch_id = -1
    elif event is InputEventScreenDrag and event.index == _look_touch_id:
        look_delta += event.relative
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        _mouse_looking = event.pressed
    elif event is InputEventMouseMotion and _mouse_looking:
        look_delta += event.relative

func consume_look_delta() -> Vector2:
    var result := look_delta
    look_delta = Vector2.ZERO
    return result

func _move_knob(pos: Vector2) -> void:
    var local := pos
    var radius: float = min(base.size.x, base.size.y) * 0.34
    var delta := local - _center
    if delta.length() > radius: delta = delta.normalized() * radius
    knob.position = _center + delta - knob.size * 0.5
    move_vector = Vector2(delta.x / radius, delta.y / radius)

func _reset_joystick() -> void:
    _center = base.size * 0.5
    knob.position = _center - knob.size * 0.5
    if _move_touch_id == -1: move_vector = Vector2.ZERO
