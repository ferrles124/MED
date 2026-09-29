extends Node3D
class_name FractureMap

@onready var site_marker: Node3D = $ObjectiveSite/Marker
@onready var site_ring: MeshInstance3D = $ObjectiveSite/Marker/Ring
@onready var bomb_device: Node3D = $ObjectiveSite/BombDevice

func _ready() -> void:
    set_bomb_state(false)

func is_player_in_site(player: Node3D) -> bool:
    return player.global_position.distance_to(site_marker.global_position) < 3.4

func set_bomb_state(active: bool) -> void:
    bomb_device.visible = active
    var material := site_ring.material_override as StandardMaterial3D
    if material != null:
        material.albedo_color = Color(1.0, 0.24, 0.18) if active else Color(0.98, 0.62, 0.16)
        material.emission = material.albedo_color
        material.emission_energy_multiplier = 2.8 if active else 1.4
