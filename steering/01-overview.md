# The Farm — Steering Overview

2D horror puzzle platformer in GameMaker Studio 2 (2024.13.1.193), GML.
Desktop-focused. Pixel art (user-owned). This AI edits `.yy` + `.gml` only.

## Objects
- `obj_game` (persistent): state machine `menu/intro/play/pause/dead/outro`, HP, inventory, achievements, popups, audio settings
- `obj_menu`: title screen (Start / Settings / Achievements / Quit), achievements menu + x/4 footer
- `obj_player`: walk/run, wind-up jump, push, damage intake
- `obj_enemy`: patrol / chase / attack, spawner-driven (see 07-spawners)
- `obj_spawner`: invisible proximity trigger that spawns one enemy
- `obj_camera`: follow + parallax backdrop offsets
- `obj_glow` (persistent): night lighting, glow holes, vignette, readability pass
- `obj_solid`: ground/wall, frame 0 block / frame 1 diagonal (precise mask)
- `obj_pushable`: gravity boxes, moved by player
- `obj_key`, `obj_drawer`, `obj_paper`: key/notes chain, thrown pop-out physics
- `obj_door_key`: needs key count. `obj_door_final`: needs typed code.
  Both animate open once, then `instance_change` to `obj_door_open` (persists, passable, holds last frame)
- `obj_exit`: level unlock + next room/outro. `obj_hidden_item`: per-level secret (hidden1/2/3 by room)

## Global state (`obj_game/Create_0.gml`)
- `global.hp / max_hp = 3`, `global.has_key`, `global.code_found`, `global.final_code="4821"`
- `global.note_open / note_sprite`, `global.damage_flash`, `global.ach_*`
- `global.music_on / sfx_on` (+ `play_music()/play_sfx()` gates, no audio assets yet)
- `global.lighting_enabled / bloom_enabled`, `global.glow_enabled`, `global.darkness_enabled`
- `global.vignette_enabled / vignette_alpha`
- `take_damage(dmg)`, `unlock_achievement(id,label)`, ini `thefarm_save.ini` (ach + settings)

## Rooms (menu first, then linear, increasing difficulty)
- `rm_menu` -> `rm_level_1` -> `rm_level_2` -> `rm_level_3` (outro returns to menu)
- Parallax: `BG_Far` trails camera (L1/L2 0.25, L3 0.45), `BG_Mid` world-locked; per-level foreground art (`bg_foreground1/2/3`), shared `bg_background`
- L1: drawer-paper, key-door, chase_range 240. L2: pushables + hidden item, 320. L3: key + code doors, spawner encounters, 400.
