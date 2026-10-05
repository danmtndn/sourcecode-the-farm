# Enemy (Patrol + Chase)

`obj_enemy/Create_0.gml`: `patrol_speed=1.5; chase_speed=2.8; grav=0.6; hsp_enemy=0; vsp=0; move_dir=1; chase_range=320; patrol_left=x-160; patrol_right=x+160; touch_cd=0;`
Tune per level: L1 240, L2 320, L3 400. Set `patrol_left/right` in room Creation Code for corridor length.

`obj_enemy/Step_0.gml`:
- `vsp+=grav`. If `point_distance(player) < chase_range` and state==play -> chase.
- Chase: `move_dir=sign(player.x-x); hsp_enemy=move_dir*chase_speed`.
- Patrol: `hsp_enemy=move_dir*patrol_speed`, flip at `patrol_left/right` or wall hit.
- Horizontal vs `obj_solid` step-to-contact. `x+=hsp_enemy`. Vertical vs `obj_solid`. `y+=vsp`.
- Touch `place_meeting(enemy,player)` with `touch_cd<=0` -> `obj_game.take_damage(1)`, `touch_cd=60`, knock player `vsp=-8`, push 24px away so escape is possible (enemy 2.8 < player 4).
