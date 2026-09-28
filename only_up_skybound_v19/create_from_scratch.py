from pathlib import Path

root = Path('/home/ubuntu/only_up_skybound_v15')
assets = sorted(p.stem for p in (root / 'assets').glob('*.glb'))
idx = {a:i for i,a in enumerate(assets)}
lines = [f'[gd_scene load_steps={len(assets)+3} format=3]']
for i,a in enumerate(assets):
    lines.append(f'[ext_resource type="PackedScene" path="res://props/{a}.tscn" id="p{i}"]')
lines += ['[ext_resource type="PackedScene" path="res://checkpoint.tscn" id="checkpoint"]','[ext_resource type="PackedScene" path="res://star.tscn" id="star"]','', '[node name="FreshLongAdventure" type="Node3D"]']

used = set()
obj = 0
checkpoints = []

def prop(name, x, y, z, rx=0, ry=0, rz=0, tag='Route'):
    global obj
    if name not in idx:
        raise ValueError(name)
    used.add(name)
    i=idx[name]
    lines.extend([
        f'[node name="{tag}_{obj:03d}_{name}" parent="." instance=ExtResource("p{i}")]',
        f'position = Vector3({x:.2f}, {y:.2f}, {z:.2f})',
        f'rotation_degrees = Vector3({rx}, {ry}, {rz})'
    ])
    obj += 1

def checkpoint(number, x, y, z):
    lines.extend([f'[node name="Checkpoint_{number:02d}" parent="." instance=ExtResource("checkpoint")]', f'position = Vector3({x:.2f}, {y:.2f}, {z:.2f})'])
    lines.extend([f'[node name="Star_{number:02d}" parent="." instance=ExtResource("star")]', f'position = Vector3({x-3.0:.2f}, {y+1.8:.2f}, {z+1.0:.2f})'])
    checkpoints.append((x,y,z))

def normal_zone(names, base_y, base_z, tag, spacing=4.0):
    # A readable stair line: no tiny object is asked to make an extreme jump.
    start_x = -((len(names)-1)*spacing)/2
    for i,name in enumerate(names):
        prop(name, start_x+i*spacing, base_y+i*0.9, base_z, [-2,1,-1,2][i%4], (i*43)%360, [2,-2,1,-1][i%4], tag)
    checkpoint(len(checkpoints), 0, base_y+len(names)*0.9+1.5, base_z)

# 0–1: the original kitchen route is the warm-up, not a collection of impossible jumps.
normal_zone(['KA-F600_Fridge_V1','KA-F600_Washer_V1','KA-F600_Dryer_V1','KA-F600_Stove_V1','KA_Micro_V2'], 2, 0, 'KitchenWarmup')
normal_zone(['KAC-F600_Fridge_V1_Shelf','KAC-F600_Fridge_V1_DrawerHolder','KAC-F600_Fridge_V1_Drawer','KAC-F600_OvenTray_V2','KAC-F600_TrayGuide_V2','KAC_Oven_HeatingTop_V2'], 13, -22, 'KitchenBridge')

# 2: plane island — five aircraft form one broad landmark/area, never five isolated jump points.
plane_y, plane_z = 27, -48
prop('ComPlaneV1', -14, plane_y, plane_z, 0, 12, 0, 'PlaneIsland')
prop('ComPlaneV2', 0, plane_y+0.8, plane_z-1, 2, 0, -2, 'PlaneIsland')
prop('ComPlaneV3', 14, plane_y, plane_z, 0, -12, 0, 'PlaneIsland')
prop('EaglePlane', 0, plane_y+0.3, plane_z-11, 0, 180, 3, 'PlaneIsland')
prop('LightPlane', 0, plane_y+1.2, plane_z+10, -2, 0, -3, 'PlaneIsland')
for i,x in enumerate([-10,-5,5,10]): prop('Done_Wood_Plank_A' if i%2==0 else 'Done_Wood_Plank_B', x, plane_y+1.0, plane_z-5, 0, 90, 0, 'PlaneWalkway')
checkpoint(2, 0, plane_y+6, plane_z)

# 3: rocks and wood approach, giving the player time before the next vehicle landmark.
normal_zone(['Done_Wood_Trunk','Done_Rock_1','Done_Rock_6','Done_Stone','Done_Rock_10','Done_Chair','Done_Seat'], 39, -72, 'RockApproach', 3.6)

# 4: three boats together as a harbor area; the player crosses the connected cluster, not one tiny boat.
boat_y, boat_z = 49, -96
prop('Fisher_Boat', -15, boat_y, boat_z, 0, 10, 0, 'BoatHarborA')
prop('Scout_Boat', 0, boat_y+0.5, boat_z-1.5, 2, 180, -2, 'BoatHarborA')
prop('Speed_Boat', 15, boat_y, boat_z, 0, -10, 0, 'BoatHarborA')
prop('Done_Wood_Plank_A', -7, boat_y+1.2, boat_z-4, 0, 90, 3, 'BoatConnector')
prop('Done_Wood_Plank_B', 7, boat_y+1.2, boat_z-4, 0, 90, -3, 'BoatConnector')
prop('Done_Table', 0, boat_y+2.0, boat_z-7, 0, 0, 0, 'BoatConnector')
checkpoint(4, 0, boat_y+5, boat_z)

# 5: second boat shelf, followed by old appliance pieces as the transition out of the harbor.
normal_zone(['Wood_BoatV1','KAC-F1000_FridgeSBS_V1_FreezerShelf','Wood_BoatV2','KAC-F1000_FridgeSBS_V1_FreezerDrawerHolder','KAC-F1000_FridgeSBS_V1_FreezerDrawer'], 62, -122, 'BoatShelf', 4.2)

# 6: helicopter deck — three helicopters occupy one large, memorable landing area.
heli_y, heli_z = 75, -150
prop('HelicopterV1', -13, heli_y, heli_z, 0, 15, 0, 'HeliDeck')
prop('HelicopterV2', 0, heli_y+0.7, heli_z-2, 2, 180, -2, 'HeliDeck')
prop('HelicopterV1', 13, heli_y, heli_z, 0, -15, 0, 'HeliDeck')
prop('Done_Panel', -6, heli_y+1.5, heli_z-7, 0, 90, 0, 'HeliConnector')
prop('Done_Pole', 6, heli_y+1.5, heli_z-7, 0, 0, 0, 'HeliConnector')
prop('Done_Signal', 0, heli_y+2.0, heli_z+7, 0, 180, 0, 'HeliConnector')
checkpoint(6, 0, heli_y+5, heli_z)

# 7: a watercraft shelf, again as a cluster with room to land.
normal_zone(['JetskiV1','KayakV1','KayakV2','KayakPaddle','Paddle','Fishing_Rod'], 88, -176, 'WatercraftShelf', 3.8)

# 8–14: every remaining new prop gets a deliberate, close-spaced route through a mixed junkyard.
remaining = [a for a in assets if a not in used]
zone_no = 8
while remaining:
    batch = remaining[:8]; remaining = remaining[8:]
    normal_zone(batch, 101 + (zone_no-8)*12, -202 - (zone_no-8)*24, f'Junkyard{zone_no}', 3.5)
    zone_no += 1

# 15: return to familiar large appliances, now as a wide safe rest area.
normal_zone(['KA-F1000_FridgeSBS_V1','KA-F600_Fan_V1','KA-F800_Fan_V1','KA-F600_Fridge_V1','KA-F600_Washer_V1'], 190, -370, 'ApplianceRest', 4.2)

# 16–17: final vehicle reprises are areas, not single stepping stones.
prop('ComPlaneV1', -12, 204, -404, 0, 10, 0, 'FinalPlaneArea')
prop('ComPlaneV2', 0, 205, -405, 1, 180, -1, 'FinalPlaneArea')
prop('ComPlaneV3', 12, 204, -404, 0, -10, 0, 'FinalPlaneArea')
prop('Fisher_Boat', -12, 220, -438, 0, 15, 0, 'FinalBoatArea')
prop('Scout_Boat', 0, 221, -439, 1, 180, -1, 'FinalBoatArea')
prop('Speed_Boat', 12, 220, -438, 0, -15, 0, 'FinalBoatArea')
checkpoint(16, 0, 226, -438)

# 18–19: final mixed ascent and summit platform.
normal_zone(['KA-F600_Stove_V1','KA_Micro_V2','KAC-F600_OvenTray_V3','KAC_Micro_Tray_V2','KAC_Oven_Fan_V2','Done_Shield','Done_Sword','Done_Wood_Axe'], 238, -472, 'SummitApproach', 3.5)
normal_zone(['Done_Barril','Done_Lamp','Done_Table','Done_Chope_A','Done_Chope_B','Done_Cup','KA-F600_Fridge_V1'], 251, -498, 'Summit', 3.5)

# 20–31: uzun final yolculuğu. Büyük alanlardan sonra oyuncu tekrar uzun, okunabilir
# bağlantı etaplarına girer; böylece araç kümeleri özel landmark olarak kalır.
late_pool = [
    ['Done_Rock_2','Done_Rock_3','Done_Rock_4','Done_Rock_5','Done_Rock_7','Done_Rock_8','Done_Rock_9'],
    ['Done_Battle_Axe','Done_Wood_Axe','Done_Sword','Done_Shield','Done_Pole','Done_Signal','Done_Panel'],
    ['KAC-F1000_FridgeSBS_V1_FreezerShelf','KAC-F1000_FridgeSBS_V1_FreezerDrawer','KAC-F1000_FridgeSBS_V1_FreezerDrawerHolder','KAC-F600_Fridge_V1_Shelf','KAC-F600_Fridge_V1_Drawer','KAC-F600_Fridge_V1_DrawerHolder'],
    ['KAC-F600_OvenTray_V2','KAC-F600_OvenTray_V3','KAC-F600_TrayGuide_V2','KAC_Micro_Tray_V2','KAC_Oven_Fan_V2','KAC_Oven_HeatingTop_V2'],
    ['KA-F600_Fan_V1','KA-F800_Fan_V1','KA-F600_Stove_V1','KA_Micro_V2','KA-F600_Washer_V1','KA-F600_Dryer_V1'],
    ['Done_Wood_Trunk','Done_Table','Done_Chair','Done_Seat','Done_Barril','Done_Lamp','Done_Stone'],
    ['Done_Chope_A','Done_Chope_B','Done_Cup','Done_Rock_10','Done_Rock_6','Done_Rock_1','Done_Panel'],
    ['KA-F600_Fridge_V1','KA-F1000_FridgeSBS_V1','Done_Wood_Plank_A','Done_Wood_Plank_B','Done_Wood_Trunk','Done_Table'],
    ['Done_Rock_2','Done_Rock_4','Done_Wood_Trunk','Done_Chair','Done_Seat','Done_Table'],
    ['KAC-F600_OvenTray_V2','KAC-F600_OvenTray_V3','Done_Wood_Plank_A','Done_Wood_Plank_B','Done_Panel','Done_Pole'],
    ['KA-F600_Washer_V1','KA-F600_Dryer_V1','KA-F600_Stove_V1','KA_Micro_V2','Done_Signal','Done_Lamp'],
    ['Done_Barril','Done_Stone','Done_Rock_6','Done_Rock_8','Done_Rock_10','Done_Shield'],
]
for i, batch in enumerate(late_pool):
    normal_zone(batch, 270 + i*14, -530 - i*26, f'LongFinal{i:02d}', 3.5)

(root/'manual_asset_level.tscn').write_text('\n'.join(lines)+'\n')
(root/'ASSET_CATALOG_TR.md').write_text(f'''# Only Up Skybound v15 — Büyük Araç Alanları\n\nBu sürüm parkur baştan kurulmuştur. Önceki sahne yerleşimi kullanılmadı. Toplam {len(assets)} GLB korunmuş, {obj} obje ve {len(checkpoints)} checkpoint yerleştirilmiştir.\n\n## Önemli alanlar\n\n- **Plane Island:** Beş büyük uçak aynı geniş alanı oluşturur; uçaklar tek tek riskli basamak değildir.\n- **Boat Harbor:** Üç büyük tekne tek bir bağlı liman alanı oluşturur.\n- **Helicopter Deck:** Üç helikopter aynı iniş alanında birleşir.\n- **Watercraft Shelf:** Jet ski, iki kano ve kürekler ayrı bir su aracı bölgesidir.\n- Ara etaplarda mutfak asset’leri, kayalar, tahtalar ve dekoratif objeler oyuncuyu bu büyük alanlara bağlar.\n\nYeni araç GLB’lerinde içe aktarma dönüşümü 0.01 olduğu için prefab ölçekleri düzeltildi: uçak 6.0, bot 3.5, helikopter 5.0, kano/jet ski 2.5. Bu, uçak ve tekneleri oyuncuya göre görünür büyük alanlar yapar.\n\nAraç prefabları StaticBody3D ve convex collision kullanır; diğer modellerin ayrıntılı collision’ı korunur.\n''')
print('assets',len(assets),'used',len(used),'objects',obj,'checkpoints',len(checkpoints),'remaining',len(remaining))
