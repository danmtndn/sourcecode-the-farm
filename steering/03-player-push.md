# Player + Pushable

## Controls
A/D or arrows move (4px/f), W/Up/Space jump (-11, grav 0.6), E interact, ENTER intro advance, R retry, ESC cancel typing.

## `obj_player/Step_0.gml`
1. Read keys, tick `interact_cd/invuln`.
2. If `obj_game.state != "play"`: `hsp=0; vsp+=grav;` collide vertical vs `obj_solid`, apply, `exit`.
3. `hsp = move * move_speed; vsp += grav;`
4. Horizontal vs `obj_solid`: step-to-contact, `hsp=0` on hit.
5. Push: `instance_place(x+hsp,y,obj_pushable)` -> check `_box.x+hsp` free of `obj_solid` and other `obj_pushable`. If free `_box.x += hsp` (same speed). Else snap to edge, `hsp=0`.
6. `x+=hsp`. Vertical vs `obj_solid` OR `obj_pushable` (boxes are platforms). `y+=vsp`.
7. Jump if grounded on solid or box. Pit `y > room_height+200` -> `take_damage(1)` + respawn at `obj_game.spawn_x/y`.

## `obj_pushable`
Create: `grav=0.6; vsp=0;`. Step: gravity + vertical vs `obj_solid` only. Horizontal owned by player. Player must share Y level and floor; destination must be clear.
