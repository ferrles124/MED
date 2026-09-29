# Sword Arena Prototype

Godot 4.7.2 ile hazırlanmış, düz zemin üzerinde karakter + kılıç entegrasyon denemesi.

## İçerik

- `Character.glb`: repodaki Skeleton3D ve AnimationPlayer içeren karakter.
- `S01_Adventurer.glb`: Low Poly Fantasy Sword Pack içinden seçilen kılıç.
- `scenes/player.tscn`: CharacterBody3D, kamera, `BoneAttachment3D` ve kılıç sahnesi.
- `scenes/sword.tscn`: kılıç modeli ve ayrı Area3D hit alanı.
- `scenes/prototype.tscn`: ışık, düz zemin ve Godot Control düğümlerinden oluşan mobil HUD.

## Kontroller

- PC: WASD, fare, F veya sol tık saldırı, Space zıplama.
- Mobil: sol taraftaki yön düğmeleri, sağdaki boş alanda sürükleyerek kamera, `ZIPLA` ve `SALDIR` düğmeleri.

## Animasyonlar

Karakterin içindeki hazır `AnimationPlayer` klipleri kullanılır: `Sword_Idle`, `Sword_Attack`, `Walk`, `Jump_Start`.
Kılıç `DEF-hand.R` kemiğine `BoneAttachment3D` ile bağlanır; model kodla çizilmez.

## Lisans

Kılıç asset lisansı `assets/SWORD_LICENSE.txt` içindedir. Ham asset paketi yeniden dağıtılmaz; bu prototipte oyun asset’i olarak kullanılır.
