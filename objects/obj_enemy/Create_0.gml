// obj_enemy - Create: Patrol + chase (slower than player so player can escape)
// Player walks at 3. Enemy chases at 3 (stalk stalemate on foot),
// patrols at 1.5, and the player outruns it sprinting at 4.5.
// Custom instance vars only (no hspeed/vspeed/direction).
patrol_speed = 1.5;
chase_speed = 3;
arrive_range = 10; // this close horizontally while chasing: hold + idle
face_deadzone = 2; // ignore smaller dx when facing: kills flicker at ~0
grav = 0.6;
jump_speed = -10; // slightly weaker than the player (-11): clears boxes, not tall walls
slope_max = 6; // max pixels to step up/down slopes per frame
hsp_enemy = 0;
vsp = 0;
move_dir = 1;
chase_range = 320;   // EDIT per level: L1 240, L2 320, L3 400 for difficulty
patrol_left = x - 160;  // EDIT or set per instance in room editor via Creation Code
patrol_right = x + 160;
touch_cd = 0;
jump_cd = 0; // hops are spaced out so failed jumps hold instead of pogoing
// Telegraphed attack (see Step): windup, then damage only if still touching.
attacking = false;   // mid-swing: frozen, playing the strip below
attack_t = 0;         // steps since the windup started
attack_hit_done = false; // strike landed once per swing
attack_windup = 18;   // telegraph steps before the hit (dodge window)
attack_recover = 12;  // steps after the hit before AI resumes
land_timer = 0; // landing-beat countdown after a real jump/fall
air_timer = 0; // consecutive airborne steps (filters out step-downs)
grounded_prev = true; // grounded state last step (takeoff/landing edges)
// Pin the collision mask: run/jump sprites differ in height, so without
// this the hitbox would grow/shrink on every sprite swap and snag.
// (Same approach as the player's idle mask pin.) Visuals use sprite_index.
mask_index = spr_enemy_run;
// Spawned-life cycle (driven by obj_spawner; direct placements ignore it).
spawning = false;    // fading in: frozen and harmless
despawning = false;  // fading out: frozen and harmless, then destroyed
aggro = false;       // set by spawner: chase from activation, never patrol
aggro_grace = 180;   // out-of-sight steps before aggro expires (~3s)
aggro_timer = 0;     // counts down while aggroed and unseen
spawn_fade_in = 30;  // steps to fade in (keep above 0)
spawn_fade_out = 24; // steps to fade out (keep above 0)

image_blend = make_color_rgb(247, 151, 121);
