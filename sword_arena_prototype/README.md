# Sword Arena Prototype

Godot 4.7.2 ile hazırlanmış, düz zemin üzerinde karakter + kılıç entegrasyon prototipi.

## Yeni weapon-rig mimarisi

Bu sürüm basit offset yaklaşımı yerine gerçek oyunlardaki ayrıştırılmış yapıyı kullanır:

```text
Skeleton3D
├── WeaponSocket (BoneAttachment3D -> DEF-hand.R)
│   └── Sword
│       ├── GripMarker
│       ├── LeftHandGrip
│       ├── BladeTraceStart
│       ├── BladeTraceEnd
│       └── HitArea
├── LeftElbowPole (Marker3D)
└── LeftHandIK (TwoBoneIK3D)

Player
└── AnimationTree
    ├── Locomotion transition: Sword_Idle / Walk
    └── Attack OneShot: Sword_Attack
```

- `WeaponSocket`, el kemiğinin transformunu takip eder.
- Kılıcın kabza hizası `sword.tscn` içindeki marker ve lokal model transformuyla tutulur.
- `AnimationTree`, animasyonların doğrudan kesilmesini önler; saldırı OneShot olarak tam klip üzerinden oynar.
- `TwoBoneIK3D` sahnede hazırdır ve `use_two_hand_ik` export seçeneğiyle açılabilir. Mevcut `S01_Adventurer` kılıcı tek elli saldırı animasyonuna sahip olduğu için varsayılan olarak kapalıdır. İki elli bir silah ve ona uygun animasyon kullanıldığında Inspector’dan açılmalıdır.
- `BladeTraceStart`, `BladeTraceEnd` ve `HitArea` ileride animasyon event’leriyle gerçek kesme izine bağlanabilecek ayrı düğümlerdir.

## Kontroller

- PC: WASD, fare, F veya sol tık saldırı, Space zıplama.
- Mobil: sol taraftaki yön düğmeleri, sağdaki boş alanda sürükleyerek kamera, `ZIPLA` ve `SALDIR` düğmeleri.

## Asset ve lisans

- `assets/Character.glb`: Skeleton3D ve hazır AnimationPlayer içeren karakter.
- `assets/S01_Adventurer.glb`: Low Poly Fantasy Sword Pack içinden seçilen kılıç.
- Lisans: `assets/SWORD_LICENSE.txt`.
