# Tek GLB'den oynanabilir platform prefabı

Dosyalar:

- `generic_asset_platform.tscn`
- `generic_asset_platform.gd`

## Kullanım

1. `generic_asset_platform.tscn` dosyasını Godot editöründe aç.
2. Kök `GenericAssetPlatform` düğümünü seç.
3. Inspector'da **Model Path** alanına kendi `.glb` dosyanı seç veya FileSystem panelinden bu alana sürükle.
4. `Model Scale` ile boyutu ayarla. Başlangıç değeri `3.3`.
5. Kaydet ve prefabı bölüm sahnesine sürükle.

Script, seçilen GLB'yi çalışma anında sahneye ekler ve içindeki bütün `MeshInstance3D` parçalarından gerçek üçgen collision oluşturur. Böylece tek bir GLB için ayrıca collision sahnesi hazırlamak gerekmez.

## Inspector seçenekleri

- **Model Path:** Kullanıcının seçtiği GLB dosyası. Tek gerekli alan.
- **Model Scale:** Model ve collision aynı model altında ölçeklenir.
- **Generate Full Mesh Collision:** Açıkken bütün mesh yüzeyleri çarpışılabilir olur.
- **Movement Enabled:** Nesneyi yatay/dikey eksende hareket ettirir.
- **Rotating:** Nesneyi kendi Y ekseninde döndürür.

## Not

Tam mesh collision sabit veya yavaş hareket eden objeler için uygundur. Çok karmaşık ve hızlı hareket eden objelerde `Generate Full Mesh Collision` kapatılıp daha basit collision tercih edilebilir.
