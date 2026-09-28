from pathlib import Path
root = Path('/home/ubuntu/only_up_skybound_v12')
props = [
 'KA-F600_Washer_V1','KA-F600_Dryer_V1','KA-F600_Stove_V1','KA_Micro_V2','KA-F600_Fridge_V1','KA-F1000_FridgeSBS_V1','KA-F600_Fan_V1','KA-F800_Fan_V1',
 'KAC-F600_Fridge_V1_Shelf','KAC-F600_Fridge_V1_Drawer','KAC-F600_Fridge_V1_DrawerHolder','KAC-F1000_FridgeSBS_V1_FreezerShelf','KAC-F1000_FridgeSBS_V1_FreezerDrawer','KAC-F1000_FridgeSBS_V1_FreezerDrawerHolder','KAC-F600_OvenTray_V2','KAC-F600_OvenTray_V3','KAC-F600_TrayGuide_V2','KAC_Micro_Tray_V2','KAC_Oven_Fan_V2','KAC_Oven_HeatingTop_V2']
lines = ['[gd_scene load_steps=%d format=3]\n' % (len(props)+3)]
for i,p in enumerate(props):
    lines.append('[ext_resource type="PackedScene" path="res://props/%s.tscn" id="p%d"]' % (p,i))
lines += ['[ext_resource type="PackedScene" path="res://checkpoint.tscn" id="checkpoint"]','[ext_resource type="PackedScene" path="res://star.tscn" id="star"]','', '[node name="ManualAssetClimb" type="Node3D"]']

# 10 yatay etap, her etapta 12 yakın basamak. Yükseliş kademeli; rota uzun ve okunabilir.
patterns = [
 [5,0,8,2,14,4,9,1,15,3,6,10],
 [4,6,10,2,16,7,12,0,17,5,8,14],
 [1,11,3,13,2,18,4,15,6,9,0,12],
 [5,14,0,19,7,10,2,16,1,12,8,3],
 [4,8,3,17,6,11,5,15,0,13,2,18],
 [2,16,1,9,7,14,4,18,5,10,0,15],
 [0,12,3,15,6,19,1,8,5,17,4,13],
 [4,10,2,13,7,16,0,11,5,14,3,18],
 [5,15,1,8,4,17,2,12,6,19,0,10],
 [3,14,5,9,1,16,7,13,4,18,2,15],
]
# Merdiven gibi: her adım yakın, X yönünde belirgin ilerleme, Y az artıyor.
step_x = 2.65
step_z = -1.35
step_y = 1.35
object_no = 0
checkpoint_no = 0
for stage, pattern in enumerate(patterns):
    for step, prop_index in enumerate(pattern):
        global_step = stage * len(pattern) + step
        direction = 1 if stage % 2 == 0 else -1
        # Zikzak merdiven: etaplar bir sağ uçtan bir sol uçtan başlar, bağlantı kopmaz.
        start_x = 0.0 if direction == 1 else 11 * step_x
        lane_x = start_x + direction * (step * step_x) + (stage % 3 - 1) * 1.1
        lane_z = stage * -16.0 + (step * step_z)
        y = 1.8 + global_step * step_y
        # Küçük görsel düzensizlik, fakat basamak hattı korunur.
        x = lane_x + ((step % 3) - 1) * 0.35
        z = lane_z + ((stage + step) % 2) * 0.35
        rx = [-3, 2, -2, 3, -2, 2, -3, 2, -2, 3, -2, 2][step]
        ry = (stage * 41 + step * 47) % 360
        rz = [2, -3, 3, -2, 2, -3, 2, -2, 3, -2, 2, -3][step]
        lines.append('[node name="Step_%03d_%s" parent="." instance=ExtResource("p%d")]' % (object_no, props[prop_index], prop_index))
        lines.append('position = Vector3(%.2f, %.2f, %.2f)' % (x,y,z))
        lines.append('rotation_degrees = Vector3(%d, %d, %d)' % (rx,ry,rz))
        object_no += 1
    # Checkpoint after each 12-step horizontal flight.
    start_x = 0.0 if direction == 1 else 11 * step_x
    last_x = start_x + direction * (11 * step_x) + (stage % 3 - 1) * 1.1
    last_z = stage * -16.0 + 11 * step_z
    last_y = 1.8 + (stage * 12 + 11) * step_y
    lines.append('[node name="Checkpoint_%02d" parent="." instance=ExtResource("checkpoint")]' % checkpoint_no)
    lines.append('position = Vector3(%.2f, %.2f, %.2f)' % (last_x, last_y + 2.2, last_z))
    lines.append('[node name="Star_%02d" parent="." instance=ExtResource("star")]' % stage)
    lines.append('position = Vector3(%.2f, %.2f, %.2f)' % (last_x - direction * 5.0, last_y + 2.0, last_z + 1.0))
    checkpoint_no += 1
(root / 'manual_asset_level.tscn').write_text('\n'.join(lines) + '\n')
print('objects', object_no, 'checkpoints', checkpoint_no)
