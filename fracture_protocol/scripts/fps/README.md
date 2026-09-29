# Fracture Protocol — FPS vertical slice

Bu klasör, oyunun işlevsel sahipliklerini ayrı tutar:

- `game_root.gd`: tur, ekonomi, bomba hedefi ve round sonucu.
- `player.gd`: birinci şahıs hareketi, kamera, hitscan atış ve oyuncu sağlığı.
- `bot.gd`: basit görüş hattı, strafing, ateş etme ve bot hasarı.
- `weapon.gd`: instanced silah sahnesinin cephane ve cooldown durumu.
- `map.gd`: modüler harita ve hedef alanı.
- `hud.gd`: Godot Control düğümlerinden Türkçe taktik arayüz.

Sahne dosyaları `scenes/fracture_protocol.tscn` üzerinden birbirine bağlanır. 3D görsellerin tamamı
PackedScene içindeki MeshInstance3D/CylinderMesh/CapsuleMesh/SphereMesh/BoxMesh düğümleridir; oyun
mantığı tek bir monolitik script içine gömülmemiştir.
