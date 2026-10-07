// obj_player - Create
// Custom instance vars only (no hspeed/vspeed/direction/speed built-ins).
move_speed = 3;
jump_speed = -9;
grav = 0.6;
slope_max = 6; // max pixels to step up/down slopes per frame (45deg needs ~move_speed)
hsp = 0;
vsp = 0;
max_hp = 3;

if (!variable_global_exists("hp") || global.hp <= 0) {
    global.hp = max_hp;
}
invuln = 0;
face = 1;
interact_cd = 0;
pushing = false; // true while a box is engaged this step (drives push sprite)
land_timer = 0; // counts down the landing-beat frames after a real jump
air_timer = 0; // counts consecutive airborne steps (filters out step-downs)
grounded_prev = true; // grounded state last step (takeoff/landing edges)
rise_rate = 1; // jump anticipation speed: image_index advance per step
// while rising (frames 0-1). Higher = shorter crouch (0.25 clears it in
// ~8 steps); lower = longer (0.06 barely leaves frame 0 during the rise).
anticipate_steps = 5; // wind-up length: grounded crouch steps before launch
anticipate_timer = 0; // counts down once started; fires the jump at 0
// Pin the collision mask: idle/run/jump sprites have different widths
// (23/35/47), so without this the hitbox would grow/shrink every time the
// animation changes and snag on walls. Visuals still use sprite_index.
mask_index = spr_player_idle;
