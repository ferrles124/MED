extends Control

signal action_pressed
signal jump_pressed

var move_vector := Vector2.ZERO
var action_requested := false
var jump_requested := false
var joystick_active := false
var joystick_pointer := -1
var joystick_center := Vector2(120, 590)
var joystick_radius := 76.0

@onready var action_button: Button = $ActionButton
@onready var jump_button: Button = $JumpButton

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    action_button.pressed.connect(_on_action)
    jump_button.pressed.connect(_on_jump)
    queue_redraw()

func set_mode(mode: String) -> void:
    action_button.text = "SAKLAN" if mode == "player" else "VUR"

func _on_action() -> void:
    action_requested = true
    action_pressed.emit()

func _on_jump() -> void:
    jump_requested = true
    jump_pressed.emit()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.position.x < 300.0 and event.position.y > size.y - 270.0:
            if event.pressed:
                joystick_active = true
                joystick_pointer = event.index
                _update_joystick(event.position)
            elif event.index == joystick_pointer:
                joystick_active = false
                joystick_pointer = -1
                move_vector = Vector2.ZERO
                queue_redraw()
    elif event is InputEventScreenDrag and joystick_active and event.index == joystick_pointer:
        _update_joystick(event.position)

func _update_joystick(position: Vector2) -> void:
    var delta := position - joystick_center
    move_vector = delta.limit_length(joystick_radius) / joystick_radius
    queue_redraw()

func _draw() -> void:
    var center := joystick_center
    var knob := center + move_vector * joystick_radius
    draw_circle(center, joystick_radius, Color(0.05, 0.12, 0.2, 0.58))
    draw_arc(center, joystick_radius, 0, TAU, 48, Color(0.45, 0.8, 1, 0.72), 3.0)
    draw_circle(knob, 29.0, Color(0.25, 0.7, 0.9, 0.84))
