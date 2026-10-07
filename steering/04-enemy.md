# Enemy (Patrol / Chase / Attack)

`obj_enemy/Create_0.gml`: `patrol_speed=1.5; chase_speed=3; jump_speed=-10`
(clears boxes, not tall walls); `arrive_range=10; face_deadzone=2`;
`touch_cd=0`; `slope_max=6`; anim timers + `grounded_prev`. Mask pinned to
the active run sprite. Per-level `chase_range` (L1 240, L2 320, L3 400), patrol
bounds via spawner `patrol_halfwidth` (was room Creation Code).
Look variants: `variant` 0 = `spr_enemy_*` set (`chase 3`, `patrol 1.5`),
1 = `spr_enemy2_*` set (`chase 3.5`, `patrol 1.75`, same windup/recover/damage),
picked in `apply_variant()` and applied lazily in Step
(Creation Code and spawner assignment run after Create). Both attack strips
are 5 frames, so the windup/strike mapping holds for both sets.
Placement (2 spawners per level, one variant each): L1 ground-mid (v0) +
right (v1); L2 ground (v0) + ground-left (v1); L3 left (v1) + exit (v0).
Spawner `spawn_variant` (Creation Code) picks the look per encounter.

## Senses
- Rectangular vision, NOT a circle: `|dx| < chase_range` AND
  `|dy| < chase_range/2`. Label and player-sprint sense use the same rule.
- `aggro` (spawner-set): chase from activation regardless of vision; expires
  after `aggro_grace` (180) consecutive unseen steps -> back to patrol/vision.
- Facing: `move_dir` updates past `face_deadzone` only (never flickers at ~0);
  `image_xscale = move_dir`. On arrival (`|dx| <= arrive_range`): hold still,
  idle sprite, touch damage still live.

## `obj_enemy/Step_0.gml`
- Guards, pause freeze, spawn fade in/out (frozen + harmless, then active/destroyed).
- Chase: beeline at `chase_speed`; patrol: `patrol_speed`, flip at
  `patrol_left/right` or wall hit — unless boxed both sides (hold, no jitter).
- Horizontal is pixel-stepped (whole + fractional remainder, no tunneling)
  with slope-up assist (terrain-only) and step-up onto lone boxes while
  chasing (stacked pairs still barricade). Boxes/doors stop patrols.
- Stuck while chasing + grounded: jump if box ahead or player above 40px
  (`jump_cd = 40` spacing, no pogo).
- Vertical lands on ground/boxes/door tops; slope-down snap; depenetration
  out of boxes/walls/doors (up, then sideways, else cancel velocity).
- Damage on touch (`touch_cd<=0`): `take_damage(1)`, `touch_cd=60`, knock
  player `vsp=-8` + up to 24px shove with collision-safe placement.

## Attack (telegraphed, dodgeable)
Trigger (touch + cooldown ready + `play`) starts `attack_windup` (18 steps),
frozen in place; the hit lands only if contact still holds at the end
(move away to dodge), then `attack_recover` (12) and AI resumes. Frames
0-2 windup, 3-4 strike/recover on the 5-frame `spr_enemy_attack` strip.

## Animation
Phased jump (0-1 rise, air to `image_number-3`, last 2 land after 6+ airborne
steps), then land beat, idle, run — same manual-frame system as the player.
