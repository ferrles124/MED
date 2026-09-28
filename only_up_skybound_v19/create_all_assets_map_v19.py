from pathlib import Path

root = Path('/home/ubuntu/only_up_skybound_v19')
assets = sorted(p.stem for p in (root / 'assets').glob('*.glb'))
idx = {a: i for i, a in enumerate(assets)}
lines = [f'[gd_scene load_steps={len(assets)+3} format=3]']
for i, a in enumerate(assets):
    lines.append(f'[ext_resource type="PackedScene" path="res://props/{a}.tscn" id="p{i}"]')
lines += [
    '[ext_resource type="PackedScene" path="res://checkpoint.tscn" id="checkpoint"]',
    '[ext_resource type="PackedScene" path="res://star.tscn" id="star"]',
    '',
    '[node name="AllAssetsSkywayV19" type="Node3D"]',
]

# Interleave the original Skybound, farm, furniture, laboratory and school assets.
groups = []
for prefix in ['', 'Farm_', 'Furniture_', 'Lab_', 'School_']:
    group = [a for a in assets if a.startswith(prefix)] if prefix else [a for a in assets if not any(a.startswith(x) for x in ['Farm_', 'Furniture_', 'Lab_', 'School_'])]
    groups.append(group)
sequence = []
while any(groups):
    for group in groups:
        if group:
            sequence.append(group.pop(0))

# Narrow zig-zag: neighboring objects remain jump-connected without blue helper platforms.
pattern = [0.0, 2.2, 3.4, 1.4, -0.8, -2.6, -3.4, -1.6, 0.8, 2.6]
checkpoints = []
used = set()

for i, name in enumerate(sequence):
    x = pattern[i % len(pattern)]
    # A slightly stronger upward slope than v18, with a shorter forward gap.
    y = 7.0 + i * 0.72
    z = -3.35 * i
    is_landmark = any(k in name.lower() for k in ['demoscene', 'pondscene', 'barnlvl3', 'towerlv3', 'smelter_lv3', 'complane', 'eagleplane', 'helicopter', 'boat'])
    if is_landmark:
        x *= 0.55
    rx = [0, 1, -1, 2, -2][i % 5] if not is_landmark else 0
    rz = [1, -1, 0, 2, -2][i % 5] if not is_landmark else 0
    ry = (i * 37) % 360
    p = idx[name]
    used.add(name)
    lines += [
        f'[node name="Asset_{i:03d}_{name}" parent="." instance=ExtResource("p{p}")]',
        f'position = Vector3({x:.2f}, {y:.2f}, {z:.2f})',
        f'rotation_degrees = Vector3({rx}, {ry}, {rz})',
    ]
    if i % 10 == 0 or i == len(sequence) - 1:
        checkpoint_no = len(checkpoints)
        lines += [
            f'[node name="Checkpoint_{checkpoint_no:02d}" parent="." instance=ExtResource("checkpoint")]',
            f'position = Vector3({x:.2f}, {y + 1.0:.2f}, {z:.2f})',
            f'[node name="Star_{checkpoint_no:02d}" parent="." instance=ExtResource("star")]',
            f'position = Vector3({x + 1.8:.2f}, {y + 2.5:.2f}, {z + 0.4:.2f})',
        ]
        checkpoints.append((x, y, z))

(root / 'all_assets_level.tscn').write_text('\n'.join(lines) + '\n')
(root / 'ALL_ASSETS_MAP_TR.md').write_text(f'''# Only Up Skybound — All Assets Skyway v19\n\nBu sürüm yalnızca yeni All Assets haritasını değiştirir; mevcut Bölüm 1 ve Bölüm 2 sahneleri korunmuştur. Menüdeki **TÜM VARLIKLAR: SKYWAY** seçeneği bu sürümü başlatır.\n\n- Kullanılan GLB sayısı: **{len(used)}**\n- Asset basamağı: **{len(sequence)}**\n- Checkpoint: **{len(checkpoints)}**\n- Yaklaşık rota uzunluğu: **{abs(3.35 * (len(sequence)-1)):.0f} metre**\n- Lacivert yardımcı platformlar kaldırıldı; rota doğrudan asset’lerin baked mesh collision yüzeyleriyle oynanır.\n- v18’e göre basamaklar birbirine daha yakın, x zigzagı daha dar ve dikey yükseliş biraz daha fazladır.\n- Ayrıntılı sınıf/ofis/tuvalet sahneleri 1.35x, diğer yeni okul/laboratuvar objeleri 1.25x büyütüldü.\n- Lowpoly Furniture asset’leri v18’deki **1.35x** ölçeğinde bırakıldı.\n- Çiftlik saman balyaları 2.0x’e çıkarıldı.\n- SlavicWorldFree texture eksikleri nedeniyle oynanabilir GLB rotasına dahil edilmedi.\n\n## Oynanış kararı\n\nHer asset artık kendi mesh collision’ı üzerinde gerçek basamak görevi görür. Yardımcı mavi yüzeyler kullanılmadığı için objelerin şekli ve yerleşimi önemlidir; rota aralığı, oyuncunun zıplama menziline göre sıklaştırılmıştır.\n''')
print('assets', len(assets), 'used', len(used), 'steps', len(sequence), 'checkpoints', len(checkpoints))
