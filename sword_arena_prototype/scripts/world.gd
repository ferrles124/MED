extends Node3D
class_name SwordPrototypeWorld

func _ready() -> void:
    var player := get_node_or_null("Player")
    if player:
        player._set_status("Kılıç hazır — mobilde ok tuşlarıyla hareket et, sağ alanda sürükle, SALDIR'a bas")
