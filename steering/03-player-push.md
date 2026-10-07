# Player + Pushable

## Controls
A/D or arrows move, W/Up/Space jump (wind-up, then -11, grav 0.6), E interact,
N view/close note, P pause, ESC resume/back, ENTER intro advance, R retry.

## Speeds (`obj_player/Create_0.gml`)
- `walk_speed = 3`, `run_speed = 4.5`, `move_speed` picked each step.
- Sprint auto-engages while any enemy hunts (aggro latched, or inside its
  vision rect — read-only scan, never writes enemies), plus a 45-step grace
  after danger passes. Enemy chases at 3: stalk stalemate on foot, escape
  by sprinting.

## `obj_player/Step_0.gml` order
1. Guards, pause hard-`exit` (frozen: no gravity/motion/timers/animation).
2. Keys; non-play settle branch (gravity + vertical only, `exit`).
3. `pushing = false`; `hsp = _move * move_speed; vsp += grav`.
4. Jump wind-up: press (grounded) starts `anticipate_steps` (10); locked
   `hsp = 0` while counting; fires `vsp = jump_speed` at 0 even if you
   drifted off an edge (input-buffer feel). Tune length via `anticipate_steps`.
5. Horizontal vs `obj_solid` + closed doors, with slope-up assist (step onto
   ramps/lips within `slope_max`, never into overhanging boxes).
6. Push: box engaged -> `hsp *= 0.5` (walk 1.5, run ~2.25) then pixel loop of
   whole pixels + one fractional remainder substep (exact speed, no overshoot).
   Box-destination tests run under the box mask; player-path tests under the
   player mask; always restore `mask_index`. Blocked-by-terrain-only + player
   path free -> step the box up ramps (raised cell re-verified vs
   wall/door/box/foe). Else snap to contact edge, `hsp = 0`.
7. Depenetration out of boxes (up, then sideways). Vertical vs solid/boxes/
   closed-door tops. Slope-down snap (was grounded + falling + moving only).
8. Animation (end of step, post-move state): airborne jump phases
   (0-1 rise, 2-air_end fall, last-2 landing beat after 6+ airborne steps;
   indices relative to `image_number` so strip edits can't break mapping),
   push sprite while shoving boxes (`pushing`) or pressing closed doors
   (`_door_push` probe), wind-up crouch by timer progress, run/walk/idle.
   Takeoff frame from physics (`vsp<0` = jumped 0, else walk-off 2).
9. Pit `y > room_height+200` -> `take_damage(1)` + respawn at `obj_game.spawn_x/y`.

## `obj_pushable`
- Create: `grav=0.6; vsp=0;` (visual frames randomized; mask is the full 48px box).
- Step: gravity + vertical vs solid/boxes/doors/enemies (stacks neatly);
  lift-out of player/enemy/box overlaps (up, then away); frozen while paused.
- Horizontal motion owned ONLY by the player push loop. Boxes never slide on
  slopes and never climb each other — they rest and stack (puzzle-stable).
- Box-vs-box is exact: destination/extent checks measure both boxes
  (`24*sx` sides, `48*sy` tall, bottom-center origin), excluding self, so
  scaled boxes (e.g. L2 0.5x) behave. Spawn overlaps self-resolve upward.
