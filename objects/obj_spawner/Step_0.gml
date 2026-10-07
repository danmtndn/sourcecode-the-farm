// obj_spawner - Step: trigger -> countdown -> fade-in aggroed enemy,
// despawn at distance, cooldown. Subtle (no pop, harmless while fading)
// and predictable (same spot, fixed ranges) to stay fair with the player.
if (!variable_instance_exists(id, "child")) child = noone;
if (!variable_instance_exists(id, "cooldown")) cooldown = 0;
if (!variable_instance_exists(id, "spent")) spent = false;
if (!variable_instance_exists(id, "spawn_range")) spawn_range = 10;
if (!variable_instance_exists(id, "despawn_range")) despawn_range = 720;
if (!variable_instance_exists(id, "respawn_delay")) respawn_delay = 300;
if (!variable_instance_exists(id, "patrol_halfwidth")) patrol_halfwidth = 160;
if (!variable_instance_exists(id, "chase_range")) chase_range = -1;
if (!variable_instance_exists(id, "repeatable")) repeatable = true;
if (!variable_instance_exists(id, "trigger_delay")) trigger_delay = 45;
if (!variable_instance_exists(id, "triggered")) triggered = false;
if (!variable_instance_exists(id, "arm_timer")) arm_timer = 0;
if (!variable_instance_exists(id, "spawn_variant")) spawn_variant = 0;

// Freeze while paused; idle unless the run is actually playing.
if (instance_exists(obj_game) && obj_game.state == "pause") exit;
if (!instance_exists(obj_player) || !instance_exists(obj_game)) exit;
if (obj_game.state != "play") exit;
// No countdowns or spawns materialize mid-transition (fade covers the room).
if (variable_global_exists("transition_lock") && global.transition_lock) exit;

// Our enemy died or the room changed under us: forget it.
if (child != noone && !instance_exists(child)) child = noone;
if (cooldown > 0) cooldown -= 1;

if (child == noone) {
    // Not eligible: drop any stale latch and wait.
    if ((!repeatable && spent) || cooldown > 0) { triggered = false; exit; }
    if (!triggered) {
        // Step 1: player touches the trigger -> latch it and start countdown.
        // No need to stay: the latch commits the spawn (pass-by jumpscare).
        if (point_distance(x, y, obj_player.x, obj_player.y) < spawn_range) {
            triggered = true;
            arm_timer = trigger_delay;
        }
    } else {
        // Step 2-3: countdown done -> fade the enemy in, already aggroed.
        arm_timer -= 1;
        if (arm_timer > 0) exit;
        triggered = false;
        child = instance_create_layer(x, y, layer, obj_enemy);
        child.patrol_left = x - patrol_halfwidth;
        child.patrol_right = x + patrol_halfwidth;
        if (chase_range > 0) child.chase_range = chase_range;
        child.variant = spawn_variant; // look only: same stats, enemy2 art if 1
        child.aggro = true; // step 4: chase the player from activation
        child.spawning = true; // fade-in handled by the enemy itself
        child.image_alpha = 0;
        if (!repeatable) spent = true;
    }
} else {
    // Child alive: leash it to home. Once the ENEMY strays past
    // despawn_range from the spawn point, fade it out (even mid-chase).
    if (point_distance(x, y, child.x, child.y) > despawn_range) {
        child.despawning = true; // enemy fades itself out, then destroys
        child = noone;
        cooldown = respawn_delay;
    }
}