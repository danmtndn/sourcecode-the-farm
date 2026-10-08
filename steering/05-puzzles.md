# Puzzles: Drawer / Paper / Key / Doors

Flow: key doors first, code unlocks final door.

- `obj_drawer`: Create `contains="paper"|"key"|"nothing"; opened=false`. Step:
  E within 64px -> `opened=true`, spawn `obj_key|obj_paper` at `(x,y-32)`
  with a throw (`hsp` toward player 1.5-2.5, `vsp=-6`); items run
  gravity/collide/friction physics in their own Steps until picked up.
  EDIT `contains` per instance via Creation Code.
- `obj_paper`: Create reads `paper_code = global.level_code` (fresh random
  code generated on room entry, so spawned notes always carry it).
  Step: E within 56px -> `global.code_found=paper_code; global.note_open=true;
  instance_destroy()`. Note re-viewable anytime with N.
- `obj_key`: Step: E within 48px -> `global.has_key+=1; instance_destroy()`.
- `obj_door_key`: Create `keys_needed=1; opened=false` (+ `door_anim_rate=0.2`,
  frame 0 held, speed 0). Step: E within 64px and keys -> spend keys,
  `opened=true`, then animate once (~1s, pause-safe, still solid).
- `obj_door_final`: Create `opened=false; typing=false` (+ same anim setup).
  Step: near 80px + E + `global.code_found!=""` toggles `typing`, clears
  `keyboard_string`. Digits only, capped to code length. ENTER compares to
  `global.level_code` -> `opened=true` (wrong = clear, retry). ESC/walk-away
  cancels. Draw shows `FINAL DOOR [E]` / `CODE: xxx_`; Draw GUI keypad box.
- Opening finish (both doors): clamp to `image_number-1`, then
  `instance_change(obj_door_open, false)` — persists as a passable open
  door holding its last frame. NEVER `instance_destroy`, NEVER loop.
  `obj_door_open` has no events; movers collide only with the closed-door
  objects, so no other code changes are needed. Prompts draw only pre-open.
- Locked doors use the 12-frame `spr_door` (36px, bottom-center origin);
  collision footprint follows the art. Walk every doorway after art swaps.
- Codes are randomized per run by `gen_level_code()` (lengths L1 4, L2 6,
  L3 8, first digit never zero). `reset_level_items()` wipes keys and clue on
  every new level and on death; dead retries and room entries never carry items.
