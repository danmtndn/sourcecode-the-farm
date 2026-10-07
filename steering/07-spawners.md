# Enemy Spawners

Enemies are never placed directly — `obj_spawner` (invisible, no sprite)
owns each encounter. All three levels use spawners at the old enemy spots.

## `obj_spawner/Create_0.gml` config (override per instance via Creation Code)
- `spawn_range` (tripwire; L-work uses 5 for pass-by jumpscares)
- `trigger_delay = 45` (countdown steps before spawn, ~0.75s)
- `despawn_range = 720` (LEASH: enemy farther than this from home fades out)
- `respawn_delay = 300`, `patrol_halfwidth = 160`, `chase_range = -1`
  (-1 = keep enemy default), `repeatable = true` (false = once per visit)
- Hysteresis enforced: `despawn_range >= spawn_range + 100`.
- Live state: `child/cooldown/spent/triggered/arm_timer` (all Step-guarded).

## Five-step flow (`obj_spawner/Step_0.gml`, play-state only, pause-frozen)
1. Player touches the radius -> latch `triggered` (committed; walking away
   does NOT cancel — this is what makes pass-by jumpscares work).
2. `arm_timer` counts down from `trigger_delay`.
3. Spawn at spawner pos: patrol bounds set from `patrol_halfwidth`,
   optional `chase_range` override, `aggro = true`, `spawning = true`,
   `image_alpha = 0` (30-step fade-in, frozen + harmless throughout).
4. Enemy chases from activation (aggro latched; expires after
   `aggro_grace` = 180 unseen steps back to patrol/vision).
5. Enemy past leash -> `despawning = true` (24-step fade, frozen), destroy,
   `cooldown = respawn_delay`. Re-entering later re-triggers (same spot,
   same ranges: learnable = fair).
- Place spawners on solid ground (spawn is frozen; activation depenetration
  only reaches 64px). Room restart resets everything (fresh instances).
