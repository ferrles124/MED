# Fight Arena Prototype

Kılıçsız, yumruk odaklı Godot 4.7.2 mobil dövüş prototipi.

Bu sürümde mobil arayüzün görsel düğümleri tamamen `arena.tscn` içinde bulunur. Joystick kodla oluşturulmaz; sahnede duran `Panel` düğümleri yalnızca dokunma konumunu okuyup knob konumunu günceller.

## Kontroller

Sol taraftaki analog joystick oyuncuyu hareket ettirir. Sağdaki boş dokunmatik alanı sürüklemek kamera pivotunun yatay ve dikey dönüşünü kontrol eder. Sağdaki `JAB` ve `CROSS` düğmeleri hazır yumruk animasyonlarını başlatır.

## Dövüş davranışı

Rakip artık oyuncuya yürümez, saldırmaz ve olduğu yerde `Idle` animasyonunda durur. Oyuncunun yumruk alanı rakibin iki ayrı Godot `Area3D` bölgesini algılar:

- `HeadHitZone`: `Hit_Head` animasyonu.
- `ChestHitZone`: `Hit_Chest` animasyonu.

Bu bölgeler `Enemy` sahnesinde düğüm olarak tanımlıdır; saldırı sistemi yalnızca bu düğümlere temas ettiğinde hasar verir. Rakip canı sıfıra inerse `Death01` oynar.

## Sahne özeti

```text
Arena
├── Player
│   ├── Character / AnimationPlayer
│   ├── PunchHitArea
│   └── CameraPivot / Camera3D
├── Enemy
│   ├── Character / AnimationPlayer
│   ├── HeadHitZone
│   └── ChestHitZone
└── HUD
    └── MobileControls
        ├── Joystick / Base / Knob
        ├── LookPanel
        └── Actions / Jab / Cross
```
