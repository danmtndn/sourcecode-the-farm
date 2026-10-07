# GML Conventions — MUST FOLLOW

- NEVER use built-ins: `hspeed`, `vspeed`, `direction`, `speed`, `gravity`, `friction`.
- Use custom instance vars: player `hsp/vsp`, enemy `hsp_enemy/vsp/move_dir`, box `vsp`.
- Always init motion in Create: `hsp=0; vsp=0;`
- Defensive guard at top of every Step that reads motion/state, so a stale
  Create can never crash the step (copy the existing `variable_instance_exists` blocks):
  `if (!variable_instance_exists(id,"hsp")) hsp = 0;`
- `x/y` built-ins are allowed (position only).
- `move_speed/walk_speed/run_speed/patrol_speed/chase_speed/jump_speed/grav` are custom instance vars — allowed despite containing "speed".
- Masks: collision follows `mask_index`, NOT the drawn sprite. Player pins
  `spr_player_idle`, enemy pins `spr_enemy_run`, so art swaps never move hitboxes.
  Box-destination tests must run under the box mask (`mask_index = spr_pushable`,
  restore on every exit path). Art `.yy` uses rectangle masks (kind 1) except
  `spr_solid`/doors (precise-per-frame kind 4, needed for diagonal tiles).
- Slopes: `slope_max = 6` in player/enemy Create. Climb = step up terrain-only
  contact within reach; snap = stay glued descending (grounded-before +
  falling + moving only). Boxes never auto-slide; they rest and stack.
- GML pitfalls (learned the hard way, all caused real compile/runtime errors):
  - NEVER declare `var` inside a `with` block.
  - NEVER do arithmetic on instance ids (`inst * 37`, `_box.id` in math).
  - `instance_place()` returns a single match: for "any OTHER box" tests, loop
    `instance_number/instance_find` with explicit `!=` exclusion instead.
- Pause pattern: hard `exit` at the top of Step when `obj_game.state == "pause"`
  (no gravity, motion, timers, or animation). Intro/outro/dead use a separate
  settle-only branch. Animation/timers freeze automatically when Step exits.
- Workflow: this project is also edited live in the IDE. My external edits only
  reach the build after the IDE reloads them — always verify via shell reads
  (the `read` tool has returned stale content), and tell the user to reload +
  Build > Clean if the running game disagrees with disk.
