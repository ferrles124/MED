extends Control
class_name SwordMobileControls

var move_vector := Vector2.ZERO
var jump_requested := false
var attack_requested := false
var _look_delta := Vector2.ZERO
var _look_touch := -1
var _last_look := Vector2.ZERO
var _move_up := false
var _move_down := false
var _move_left := false
var _move_right := false

@onready var look_panel: Control = $LookPanel
@onready var up_button: Button = $MovePad/Up
@onready var down_button: Button = $MovePad/Down
@onready var left_button: Button = $MovePad/Left
@onready var right_button: Button = $MovePad/Right
@onready var jump_button: Button = $Actions/Jump
@onready var attack_button: Button = $Actions/Attack

func _ready() -> void:
    _bind_hold(up_button, "up")
    _bind_hold(down_button, "down")
    _bind_hold(left_button, "left")
    _bind_hold(right_button, "right")
    jump_button.pressed.connect(func() -> void: jump_requested = true)
    attack_button.pressed.connect(func() -> void: attack_requested = true)
    look_panel.gui_input.connect(_on_look_input)
    _refresh_move()

func _process(_delta: float) -> void:
    _refresh_move()

func _bind_hold(button: Button, direction: String) -> void:
    button.button_down.connect(func() -> void: _set_direction(direction, true))
    button.button_up.connect(func() -> void: _set_direction(direction, false))

func _set_direction(direction: String, active: bool) -> void:
    match direction:
        "up": _move_up = active
        "down": _move_down = active
        "left": _move_left = active
        "right": _move_right = active

func _refresh_move() -> void:
    move_vector = Vector2(float(_move_right) - float(_move_left), float(_move_down) - float(_move_up))
    if move_vector.length_squared() > 1.0:
        move_vector = move_vector.normalized()

func _on_look_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _look_touch == -1:
            _look_touch = event.index
            _last_look = event.position
        elif not event.pressed and event.index == _look_touch:
            _look_touch = -1
    elif event is InputEventScreenDrag and event.index == _look_touch:
        _look_delta += event.position - _last_look
        _last_look = event.position

func consume_look_delta() -> Vector2:
    var result := _look_delta
    _look_delta = Vector2.ZERO
    return result
