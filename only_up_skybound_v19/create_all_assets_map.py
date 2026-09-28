from pathlib import Path

root = Path('/home/ubuntu/only_up_skybound_v18')
assets = sorted(p.stem for p in (root / 'assets').glob('*.glb'))
idx = {a: i for i, a in enumerate(assets)}
lines = [f'[gd_scene load_steps={len(assets)+4} format=3]']
for i, a in enumerate(assets):
    lines.append(f'[ext_resource type="PackedScene" path="res://props/{a}.tscn" id="p{i}"]')
lines += [
    '[ext_resource type="PackedScene" path="res://all_assets_route_pad.tscn" id="pad"]',
    '[ext_resource type="PackedScene" path="res://checkpoint.tscn" id="checkpoint"]',
    '[ext_resource type="PackedScene" path="res://star.tscn" id="star"]',
    '',
    '[node name="AllAssetsSkyway" type="Node3D"]',
]

# Interleave the old Skybound props, farm, furniture, laboratory and school groups.
groups = []
for prefix in ['', 'Farm_', 'Furniture_', 'Lab_', 'School_']:
    group = [a for a in assets if a.startswith(prefix)] if prefix else [a for a in assets if not any(a.startswith(x) for x in ['Farm_', 'Furniture_', 'Lab_', 'School_'])]
    groups.append(group)
sequence = []
while any(groups):
    for group in groups:
        if group:
            sequence.append(group.pop(0))

pattern = [0.0, 3.0, 5.2, 2.4, -0.5, -3.3, -5.0, -2.2, 1.0, 3.8]
checkpoints = []
used = set()

for i, name in enumerate(sequence):
    x = pattern[i % len(pattern)]
    y = 7.0 + i * 0.54
    z = -4.25 * i
    # Every twelfth step becomes a wider rest island; landmark scenes stay centered.
    is_landmark = any(k in name.lower() for k in ['demoscene', 'pondscene', 'barnlvl3', 'towerlv3', 'smelter_lv3', 'complane', 'eagleplane', 'helicopter', 'boat'])
    pad_scale = 1.65 if i % 12 == 0 or is_landmark else 1.0
    if is_landmark:
        x *= 0.55
    rx = [0, 1, -1, 2, -2][i % 5] if not is_landmark else 0
    rz = [1, -1, 0, 2, -2][i % 5] if not is_landmark else 0
    ry = (i * 37) % 360
    p = idx[name]
    used.add(name)
    lines += [
        f'[node name="Pad_{i:03d}" parent="." instance=ExtResource("pad")]',
        f'position = Vector3({x:.2f}, {y:.2f}, {z:.2f})',
        f'scale = Vector3({pad_scale:.2f}, 1, {pad_scale:.2f})',
        f'[node name="Asset_{i:03d}_{name}" parent="." instance=ExtResource("p{p}")]',
        f'position = Vector3({x:.2f}, {y + 0.45:.2f}, {z:.2f})',
        f'rotation_degrees = Vector3({rx}, {ry}, {rz})',
    ]
    if i % 12 == 0 or i == len(sequence) - 1:
        checkpoint_no = len(checkpoints)
        lines += [
            f'[node name="Checkpoint_{checkpoint_no:02d}" parent="." instance=ExtResource("checkpoint")]',
            f'position = Vector3({x:.2f}, {y + 0.7:.2f}, {z:.2f})',
            f'[node name="Star_{checkpoint_no:02d}" parent="." instance=ExtResource("star")]',
            f'position = Vector3({x + 2.2:.2f}, {y + 2.4:.2f}, {z + 0.5:.2f})',
        ]
        checkpoints.append((x, y, z))

(root / 'all_assets_level.tscn').write_text('\n'.join(lines) + '\n')
(root / 'ALL_ASSETS_MAP_TR.md').write_text(f'''# Only Up Skybound — All Assets Skyway\n\nBu ayrı harita mevcut Bölüm 1 ve Bölüm 2 sahnelerine dokunmadan oluşturuldu. Oyuncu menüdeki **TÜM VARLIKLAR: SKYWAY** seçeneğiyle bu haritayı başlatır.\n\n- Kullanılan GLB sayısı: **{len(used)}**\n- Rota basamağı: **{len(sequence)}**\n- Checkpoint: **{len(checkpoints)}**\n- Yaklaşık parkur uzunluğu: **{abs(4.25 * (len(sequence)-1)):.0f} metre yatay derinlik**\n- Her basamağın altında güvenli yürünebilir route pad bulunur.\n- Asset’ler eski Skybound, çiftlik, mobilya, laboratuvar ve okul/kafeterya kaynakları olarak dönüşümlü harmanlanır.\n- SlavicWorldFree paketi texture eksikleri nedeniyle bu oynanabilir haritaya dahil edilmedi; kaynak repo içinde ayrı tutuluyor.\n\n## Tasarım\n\nRota, tek bir temaya kapanmak yerine her birkaç adımda görsel dili değiştirir: beyaz eşya ve araçlar, çiftlik objeleri, mobilyalar, laboratuvar ekipmanları, sınıf ve kafeterya varlıkları. Büyük demo sahneleri ve araçlar geniş dinlenme adaları olarak kullanılır; küçük objeler güvenli pad üzerinde dekoratif ama çarpışılabilir basamaklar olarak yer alır.\n''')
print('assets', len(assets), 'used', len(used), 'steps', len(sequence), 'checkpoints', len(checkpoints))
