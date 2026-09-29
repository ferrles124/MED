extends Control
class_name FightMobileControls

var move_vector := Vector2.ZERO
var jab_requested := false
var cross_requested := false
var _touch_id := -1
var _center := Vector2.ZERO
var _knob := Vector2.ZERO
@onready var base: Panel = $Joystick/Base
@onready var knob: Panel = $Joystick/Knob
@onready var look_panel: Control = $LookPanel
@onready var jab: Button = $Actions/Jab
@onready var cross: Button = $Actions/Cross

func _ready() -> void:
    base.gui_input.connect(_on_joystick_input)
    jab.pressed.connect(func() -> void: jab_requested = true)
    cross.pressed.connect(func() -> void: cross_requested = true)
    _reset_joystick()

func _process(_delta: float) -> void:
    _center = base.size * 0.5
    if _touch_id == -1: _reset_joystick()

func _on_joystick_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _touch_id == -1:
            _touch_id = event.index
            _move_knob(event.position)
        elif not event.pressed and event.index == _touch_id:
            _touch_id = -1
            move_vector = Vector2.ZERO
    elif event is InputEventScreenDrag and event.index == _touch_id:
        _move_knob(event.position)

func _move_knob(pos: Vector2) -> void:
    var local := base.get_global_transform().affine_inverse() * pos
    var radius: float = min(base.size.x, base.size.y) * 0.34
    var delta := local - _center
    if delta.length() > radius: delta = delta.normalized() * radius
    knob.position = _center + delta - knob.size * 0.5
    move_vector = Vector2(delta.x / radius, delta.y / radius)

func _reset_joystick() -> void:
    _center = base.size * 0.5
    knob.position = _center - knob.size * 0.5
    if _touch_id == -1: move_vector = Vector2.ZERO
