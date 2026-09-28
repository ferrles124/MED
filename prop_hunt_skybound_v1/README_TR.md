# Prop Hunt Skybound v3

Bu, Only Up projesinden bağımsız, mobil destekli Prop Hunt prototipidir.

## Modlar

### Oyuncu Modu

- Merkezdeki `+` imlecini bir eşyanın üzerine getir.
- Altındaki hedef yazısı doğru eşyayı gösterir.
- `E` veya mobil **SAKLAN** butonuyla seçili eşyaya dönüş.
- Dönüşünce oyuncunun gerçek karakter modeli gizlenir ve seçilen eşyanın görünümü oyuncuya taşınır.
- Tekrar `E` ile karakter formuna dön.

### Avcı Modu

- Yapay zekâ yoktur.
- Merkezdeki `+` imlecini bir eşyanın üzerine getir.
- Hedef yazısı seçilen eşyayı gösterir.
- `E` veya mobil **VUR** butonuyla hedef eşyaya vur.
- Eşya kısa bir tepki hareketi yapar.

## Kontroller

### Bilgisayar

| Tuş | İşlev |
|---|---|
| WASD | Hareket |
| Mouse | Kamerayı döndür |
| Space | Zıpla |
| E | Moda göre dönüş / vurma |
| Esc | Mouse imlecini serbest bırak |

### Mobil

- Sol alt sanal joystick: hareket
- Sağ orta ekranda sürükleme: kamera
- Sağdaki **SAKLAN** veya **VUR**: moda göre etkileşim
- Sağ alttaki **ZIPLA**: zıplama
- Ortadaki `+`: hedef seçim imleci

## Animasyonlar

Karakterin gerçek `Character.glb` animasyon klipleri kullanılır:

- `Idle_Loop`
- `Walk_Loop`
- `Sprint_Loop`
- `Jump_Start`
- `Jump_Loop`
- `Jump_Land`

Modelde toplam 46 animasyon klibi vardır.

## Teknik not

Dönüşüm sırasında seçilen propun orijinal görünümü sahneden geçici olarak gizlenir; aynı prop sahnesi oyuncunun altına görsel olarak eklenir. Böylece kamera boşluğa bakmaz ve oyuncu gerçekten seçtiği eşyaya dönüşmüş gibi görünür. Orijinal propun collision’ı geçici olarak devre dışı bırakılır.
