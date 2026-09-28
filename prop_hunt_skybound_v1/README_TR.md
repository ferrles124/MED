# Prop Hunt Skybound v2

Bu, Only Up projesinden bağımsız ilk Prop Hunt prototipidir.

## Modlar

### Oyuncu Modu

- Oyuncu karakteriyle haritada dolaş.
- Yakınındaki eşyaya `E` veya mobilde **SAKLAN** butonuyla dönüş.
- Aynı etkileşimle tekrar karakter formuna dön.
- Şimdilik avcı yapay zekâsı yok; serbestçe eşya dönüşümünü test et.

### Avcı Modu

- Oyuncu karakteriyle haritada dolaş.
- Kameranın önündeki eşyayı `E` veya mobilde **VUR** butonuyla hedefle.
- Eşya kısa bir vurulma animasyonuyla tepki verir.
- Şimdilik amaç, eşya vurma etkileşimini test etmektir; yapay zekâ avcı daha sonra eklenecek.

## Kontroller

| Platform | İşlev |
|---|---|
| WASD / sol sanal joystick | Hareket |
| Mouse | Kamera |
| Space / ZIPLA | Zıplama |
| E / SAKLAN veya VUR | Moda göre etkileşim |
| Esc | Mouse imlecini serbest bırak |

## Mobil destek

Ekranın sol altındaki sanal joystick ile hareket edilir. Sağ tarafta moda göre değişen etkileşim butonu ve zıplama butonu bulunur. Mobil arayüz tüm temel test akışını destekleyecek şekilde sahneye eklendi.

## Karakter animasyonları

`Character.glb` içindeki gerçek klip adları kullanılır:

- `Idle_Loop`
- `Walk_Loop`
- `Sprint_Loop`
- `Jump_Start`
- `Jump_Loop`
- `Jump_Land`
- `Roll` / `Roll_RM` hazır durumda

Ayrıca modelde 46 toplam animasyon klibi bulunur; etkileşim, oturma, konuşma, itme, dövüş ve yüzme animasyonları sonraki mekaniklerde kullanılabilir.

## Kullanılan kaynaklar

Toplam 24 asset, baked mesh collision ile kullanılmıştır: mobilya, sınıf, ofis, kafeterya, laboratuvar, tuvalet ve çiftlik objeleri.

## Sonraki geliştirme sırası

1. Eşya vurulma efektleri ve sesleri
2. Gerçek avcı karakteri ve yapay zekâ
3. Daha büyük harita ve rastgele prop yerleşimi
4. Multiplayer mod
