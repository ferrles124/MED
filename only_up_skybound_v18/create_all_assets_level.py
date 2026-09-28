from pathlib import Path
root = Path('/home/ubuntu/only_up_skybound_v14')
assets = sorted(p.stem for p in (root / 'assets').glob('*.glb'))
props = [f'Prop_{name.replace("-", "_").replace(" ", "_")}' for name in assets]
def is_anchor(n):
    low=n.lower()
    return (low.startswith(('ka-f600_', 'ka-f1000_', 'ka_micro')) and not low.startswith('kac-')) or any(x in low for x in ('boat','plane','helicopter','jetski','kayak')) or 'table' in low
anchors=[i for i,n in enumerate(assets) if is_anchor(n)]
fillers=[i for i in range(len(assets)) if i not in anchors]
lines=[f'[gd_scene load_steps={len(props)+3} format=3]']
for i,name in enumerate(props): lines.append(f'[ext_resource type="PackedScene" path="res://props/{assets[i]}.tscn" id="p{i}"]')
lines += ['[ext_resource type="PackedScene" path="res://checkpoint.tscn" id="checkpoint"]','[ext_resource type="PackedScene" path="res://star.tscn" id="star"]','', '[node name="AllAssetsLongClimb" type="Node3D"]']
steps_per_stage, stages = 20, 20
step_x, step_z, step_y = 3.6, -0.9, 0.86
obj=cp=0; ai=fi=0
for stage in range(stages):
    direction=1 if stage%2==0 else -1
    start_x=0.0 if direction==1 else (steps_per_stage-1)*step_x
    for step in range(steps_per_stage):
        # Four intentional anchor positions per flight; small items bridge them.
        if step in (0,5,10,15):
            idx=anchors[ai%len(anchors)]; ai+=1
        else:
            idx=fillers[fi%len(fillers)]; fi+=1
        x=start_x+direction*step*step_x+(((stage+step)%3)-1)*0.38
        y=2.0+(stage*steps_per_stage+step)*step_y
        z=stage*-30.0+step*step_z+((stage+step)%2)*0.24
        rx=[-2,1,-1,2,-2,1,-2,2,-1,1][step%10]
        ry=(stage*29+step*41)%360
        rz=[2,-2,1,-2,2,-1,2,-1,2,-2][step%10]
        lines += [f'[node name="Step_{obj:03d}_{assets[idx]}" parent="." instance=ExtResource("p{idx}")]',f'position = Vector3({x:.2f}, {y:.2f}, {z:.2f})',f'rotation_degrees = Vector3({rx}, {ry}, {rz})']
        obj+=1
    last_x=start_x+direction*(steps_per_stage-1)*step_x
    last_y=2.0+(stage*steps_per_stage+steps_per_stage-1)*step_y
    last_z=stage*-30.0+(steps_per_stage-1)*step_z
    lines += [f'[node name="Checkpoint_{cp:02d}" parent="." instance=ExtResource("checkpoint")]',f'position = Vector3({last_x:.2f}, {last_y+2.2:.2f}, {last_z:.2f})',f'[node name="Star_{stage:02d}" parent="." instance=ExtResource("star")]',f'position = Vector3({last_x-direction*7.0:.2f}, {last_y+2.0:.2f}, {last_z+1.0:.2f})']
    cp+=1
(root/'manual_asset_level.tscn').write_text('\n'.join(lines)+'\n')
(root/'ASSET_CATALOG_TR.md').write_text(f'''# Only Up Skybound v14 — Büyük Araç Ankrajlı Parkur\n\nBu sürümde toplam {len(assets)} GLB korunmuştur. Uçak, helikopter, bot ve diğer büyük araçlar v13'e göre büyütülmüş ana ankrajlar olarak kullanılır; küçük modeller bunların arasında geçiş ve detay oluşturur.\n\n## Oynanış yerleşimi\n\nParkur 20 etap ve 400 önceden yerleştirilmiş objeden oluşur. Her yatay uçuşta dört ana ankraj vardır: 0, 5, 10 ve 15. basamaklar büyük araçlar, beyaz eşyalar veya masa gibi taşıyıcı objelerdir; aradaki basamaklar tahta, kaya, sandalye, parça ve dekoratif modellerle bağlanır. Böylece büyük araçlar yalnızca süs olarak değil, gerçekten rota üzerinde basılacak ana platformlar olarak görev yapar.\n\nYeni araç prefabları `StaticBody3D` olarak kaydedildi. Büyük araçların collision'ları convex olarak baked edildi; bu, uçak ve botların büyük görünmesini korurken v13'teki gereksiz üçgen collision yükünü azaltır. Diğer assetlerde ayrıntılı mesh collision korunur.\n\nAraç ölçekleri v13'e göre yükseltildi: botlar 0.14, uçaklar/helikopterler 0.18, kano ve jet ski 0.11 ölçek kullanır.\n''')
print('assets',len(assets),'anchors',len(anchors),'fillers',len(fillers),'objects',obj,'checkpoints',cp)
