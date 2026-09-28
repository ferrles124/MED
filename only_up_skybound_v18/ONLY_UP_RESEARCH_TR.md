# Only Up araştırması ve bu projeye uygulanan tasarım kararları

## Araştırılan kaynaklar

- [Only Up! — Wikipedia](https://en.wikipedia.org/wiki/Only_Up!)
- [Only Up! — Steam mağaza açıklaması](https://store.steampowered.com/app/2381590/Only_Up/)
- [Only Up! gameplay görsel referansları](https://www.youtube.com/watch?v=BynbwFstVms)

## Only Up'ta görülen ana yapı

1. Tek, uzun ve dikey bir yolculuk: amaç haritanın tepesine çıkmaktır.
2. Yol, tek tip platformlardan değil gerçek dünya nesneleri ve dağınık yüzeylerden oluşur.
3. Bölümler/etaplar farklı ölçekte ve farklı görsel temada okunur.
4. Bazı geçişler yatayda genişler; oyuncu yalnızca dikey bir merdivende ilerlemez.
5. Düşüş, oyunun geriliminin merkezidir. Orijinal oyunda kayıt/checkpoint yoktur; bu projede aynı gerilimi korurken kullanıcı deneyimini daha adil yapmak için etap sonlarına checkpoint konur.
6. Güvenli ve riskli seçenekler aynı bölgede bulunabilir; oyuncu rota seçer.
7. Görsel çeşitlilik, Easter egg ve farklı objelerle sağlanır; tek bir tekrar eden platform tipi kullanılmaz.

## Bu projeye uygulanan kararlar

- Runtime rastgele üretim kaldırıldı; bölüm artık `manual_asset_level.tscn` içindeki gerçek node yerleşimlerinden oluşuyor.
- İki asset paketindeki 20 modelin her biri ayrı `props/*.tscn` prefab sahnesine dönüştürüldü.
- Her prefab model ve baked üçgen collision içeriyor; oyun başlarken collision üretilmiyor.
- 8 etap ve toplam 80 yerleştirilmiş obje kullanıldı.
- Her etap büyük bir cihazla okunabilir bir ankraj başlatıyor; ardından raf, çekmece, tepsi, fan ve küçük parçalarla daha hassas geçiş geliyor.
- Etaplar arasında yatay sapmalar ve çapraz geçişler var; ancak ana rota tamamen rastgele değil.
- Her etap sonunda checkpoint ve alternatif hatta yıldız bulunuyor.
- Objeler hafif eğimli ve farklı yönlere döndürülmüş durumda; oyuncunun basabileceği ana yüzeyler tamamen kontrol edilebilir kalıyor.
- Finish portalı parkurun gerçek son yüksekliğine taşındı.

## Zorluk eğrisi

- Etap 1–2: büyük cihazlar ve daha kısa atlayışlar.
- Etap 3–4: parçalar, dar geçişler ve daha geniş yatay seçimler.
- Etap 5–6: büyük cihaz + parça kümeleri, daha uzun sıralı atlayışlar.
- Etap 7–8: final yaklaşımı, yüksek riskli çapraz geçişler ve son checkpoint.

Bu düzen, Only Up'ın uzunluk ve gerilim hissini korurken mevcut oyunun oyuncu için tamamen imkânsız hale gelmesini önlemek üzere tasarlandı.
