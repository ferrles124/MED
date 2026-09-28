# Prop Hunt Skybound v1

Bu, Only Up projesinden bağımsız ilk Prop Hunt prototipidir.

## Oynanış

- Oyuncu küçük bir sınıf/laboratuvar alanında başlar.
- Kırmızı avcı devriye gezer ve görünür oyuncuyu kovalar.
- Yakındaki bir asset’in yanına gelip **E** tuşuna basınca oyuncu o eşyaya saklanır.
- Saklanırken tekrar **E** ile insan formuna dönülür.
- 120 saniye boyunca yakalanmadan kalırsan kazanırsın.
- Avcı sana yaklaşırsa yakalanırsın.

## Kontroller

| Tuş | İşlev |
|---|---|
| WASD | Hareket |
| Mouse | Kamera |
| Space | Zıplama |
| E | Eşyaya saklan / saklanmadan çık |
| R | Tur bittikten sonra yeniden başlat |
| Esc | Mouse imlecini serbest bırak |

## Bu prototipte kullanılan asset’ler

- Mobilya: sandalye, masa, koltuk, kitaplık
- Sınıf/ofis: sıra, dolap, lamba, tahta, müdür masası
- Kafeterya: vending machine, ping pong masası
- Laboratuvar: bilgisayar, ekran, mikroskop, laboratuvar masası
- Tuvalet: kapı ve klozet
- Çiftlik: saman balyası, varil, tahta kasa

Toplam 24 asset, baked mesh collision ile kullanılmıştır.

## Sonraki doğal geliştirmeler

1. Birden fazla tur ve rastgele eşya seçimi
2. Avcının yanlış eşyaya vurması ve can kaybetmesi
3. Oyuncunun kısa süreli kaçış yeteneği
4. Daha büyük kampüs haritası
5. Çok oyunculu mod
