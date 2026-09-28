# Only Up: Skybound — Manuel Sahne Sürümü

Bu sürümde bölüm artık çalışma anında rastgele platform üretmiyor. Platformlar, yıldızlar ve checkpoint’ler gerçek Godot sahneleri olarak `level_01.tscn` içinde elle yerleştirildi. Böylece Godot editöründe herhangi bir platformu seçip konumunu, yüksekliğini, rengini veya davranışını değiştirebilirsin.

## Açılış

`project.godot` dosyasını Godot Project Manager ile içe aktar. Oyun önce `menu.tscn` sahnesini açar. **OYUNA BAŞLA** düğmesi `game.tscn` sahnesine geçer.

## Elle bölüm düzenleme

Bölüm dosyası:

```text
res://level_01.tscn
```

Bir platform eklemek için FileSystem panelinden `platform.tscn` dosyasını 3D sahneye sürükle. Platformu seçip Inspector’da `Behavior` alanını değiştirebilirsin:

```text
static     normal platform
moving     yatay veya ileri-geri hareket
bounce     oyuncuyu yukarı fırlatır
breakable  kısa süre sonra kaybolur ve geri gelir
vanishing  basınca görünmez olur, sonra yeniden gelir
```

`Movement Axis`, `Movement Distance`, `Movement Speed` ve `Bounce Force` değerleri doğrudan Inspector’dan ayarlanabilir. Bu davranışların tamamı tek küçük `platform_behaviors.gd` betiğiyle çalışır.

Yıldız için `star.tscn`, checkpoint için `checkpoint.tscn` dosyasını bölüme sürükleyebilirsin. Checkpoint’ler `checkpoint` grubuna kendileri eklenir; dünya yöneticisi bağlantıyı otomatik kurar.

## Oyun özellikleri

Manuel sahne 1’in üstüne ikinci bir şehir çatısı bölümü eklenmiştir. Toplamda yeni checkpoint’ler, rüzgâr alanları, kaybolan basamaklar, hareketli platformlar, zıplatıcı platformlar, kırılabilir platformlar, dönen platformlar ve ince boru/denge geçişleri bulunur. Platformlar davranışlarına göre koyu ve sakin bir renk paletiyle ayrılır; üstlerindeki trim çizgileri türü uzaktan okunabilir kılar. Oyuncu düşerse son checkpoint’e gönderilir. En yüksek değer ve skor `user://only_up_save.cfg` dosyasına kaydedilir. Menüde **KAYDI SIFIRLA** düğmesi bulunur.

Oyuncuda zıplama yüksekliği kontrolü, havada kontrol, coyote-time, iniş kamera sarsıntısı, karaktere daha yakın üçüncü şahıs kamera ve kenara tutunma vardır. Ucu ucuna atlayışlarda önünde duvar ve üstünde erişilebilir yüzey varsa oyuncu otomatik tutunur; GLB içinde `Roll_RM` varsa onu, yoksa `Roll` animasyonunu oynatır. Zirvedeki portal sonuç ekranını açar; yükseklik, skor ve süre gösterilir. Ana menü daha sade, koyu ve odaklı bir kart düzenine sahiptir.

## Kontroller

Bilgisayarda `WASD` veya ok tuşları hareket, `Space` zıplama, fare kamera ve `R` son checkpoint’e dönme içindir. Mobilde sol joystick hareket, sağ ekran bölgesi kamera ve `ZIPLA` düğmesi zıplama içindir. Mobil joystick boyutu ve kamera hassasiyeti `game.tscn` içindeki `MobileControls` düğümünün Inspector’ından ayarlanabilir.

## Ana dosyalar

- `menu.tscn`: başlangıç menüsü
- `game.tscn`: atmosfer, oyuncu, HUD ve bölüm bağlantısı
- `level_01.tscn`: elle yerleştirilmiş parkur
- `platform.tscn`: düzenlenebilir temel platform
- `pipe.tscn`: ince denge/boru geçişi
- `level_02.tscn`: şehir çatıları bölümü
- `wind_zone.tscn`: yana iten rüzgâr alanı
- `finish.tscn`: zirve portalı ve kazanma alanı
- `checkpoint.tscn`: checkpoint sahnesi
- `star.tscn`: toplanabilir yıldız sahnesi
- `player.tscn`: oyuncu ve kamera
- `world_manual.gd`: skor, süre, kayıt ve checkpoint yönetimi
- `platform_behaviors.gd`: dört platform davranışı
- `Character.glb`: karakter ve gömülü animasyonlar
