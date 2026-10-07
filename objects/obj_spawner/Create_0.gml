// obj_spawner - Create: triggers one enemy when the player comes close.
// Place in the room editor where you want an encounter, on solid ground
// (the enemy materializes frozen, so floating spawns look wrong).
// Invisible in game (no sprite). Per-instance tuning via Creation Code,
// same pattern as the old enemy patrol ranges, e.g.: patrol_halfwidth = 100;
spawn_range = 5;     // player this close (px) -> start the trigger countdown
trigger_delay = 45;    // countdown steps, then the enemy fades in (~0.75s)
despawn_range = 720;   // enemy farther than this from home -> fade out (leash)
respawn_delay = 300;   // steps before it can trigger again after a despawn
patrol_halfwidth = 160; // enemy patrols spawn_x +/- this (old x±160 default)
chase_range = -1;      // -1 = keep the enemy default; else override it
repeatable = true;     // false = spawn once per room visit
spawn_variant = 0;     // enemy look: 0 = spr_enemy_* set, 1 = spr_enemy2_* set
// Keep a hysteresis gap so the enemy can't flicker in/out at the boundary.
if (despawn_range < spawn_range + 100) despawn_range = spawn_range + 100;
// Live state (guarded again in Step so a stale Create can't break it).
child = noone;    // the enemy instance we spawned, if still alive
cooldown = 0;     // counts down after each despawn before retriggering
spent = false;    // true once a non-repeatable spawner has fired
triggered = false; // latched on trip: countdown commits even if player walks past
arm_timer = 0;    // countdown itself; enemy spawns at 0