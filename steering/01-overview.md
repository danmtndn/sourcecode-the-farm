# The Farm — Steering Overview

2D horror puzzle platformer in GameMaker Studio 2 (2024.13.1.193), GML.
Desktop-focused. Minimalist pixel art (user-owned). This AI edits `.yy` + `.gml` only.

## Objects
- `obj_game` (persistent): state machine `intro/play/dead/outro`, HP, inventory, achievements, popups
- `obj_player`: platformer move, push, damage intake
- `obj_enemy`: patrol + chase, slower than player
- `obj_solid`: ground/wall (placeholder `spr_player`)
- `obj_key`, `obj_drawer`, `obj_paper`: key/notes chain
- `obj_door_key`: needs key count. `obj_door_final`: needs typed code
- `obj_pushable`: gravity only, moved by player
- `obj_exit`: level unlock + next room/outro
- `obj_hidden_item`: hidden achievement

## Global state (`obj_game/Create_0.gml`)
- `global.hp / max_hp = 3`, `global.has_key`, `global.code_found`, `global.final_code="4821"`
- `global.paper_text / paper_timer`, `global.damage_flash`, `global.ach_*`
- `take_damage(dmg)`, `unlock_achievement(id,label)`, ini `thefarm_save.ini`

## Room plan
User builds 3 linear rooms, increasing difficulty.
L1: drawer-paper, key-door, chase_range 240. L2: pushable + hidden item, 320. L3: 2 key doors + final code door, 400.
