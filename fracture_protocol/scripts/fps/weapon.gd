extends Node3D
class_name FractureWeapon

@export var weapon_name := "Strider-7"
@export var damage := 34
@export var magazine_size := 24
@export var range := 90.0
@export var fire_rate := 7.5
@export var recoil_amount := 0.035

var ammo := 24
var cooldown := 0.0
var flash_time := 0.0

@onready var muzzle_flash: OmniLight3D = $MuzzleFlash
@onready var ammo_label: Label = $AmmoLabel

func _ready() -> void:
    ammo = magazine_size
    muzzle_flash.visible = false
    ammo_label.visible = false

func _process(delta: float) -> void:
    cooldown = maxf(0.0, cooldown - delta)
    if flash_time > 0.0:
        flash_time -= delta
        if flash_time <= 0.0:
            muzzle_flash.visible = false

func try_fire() -> bool:
    if cooldown > 0.0 or ammo <= 0:
        return false
    ammo -= 1
    cooldown = 1.0 / fire_rate
    flash_time = 0.035
    muzzle_flash.visible = true
    return true

func reload() -> void:
    ammo = magazine_size

func reset_weapon() -> void:
    ammo = magazine_size
    cooldown = 0.0

func impact_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 0.55, 0.18)
    material.emission_enabled = true
    material.emission = Color(1.0, 0.18, 0.04)
    material.emission_energy_multiplier = 2.5
    return material
