// obj_player - Create
// Custom instance vars only (no hspeed/vspeed/direction/speed built-ins).
move_speed = 3;
jump_speed = -11;
grav = 0.6;
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
// Pin the collision mask: idle/run/jump sprites have different widths
// (23/35/47), so without this the hitbox would grow/shrink every time the
// animation changes and snag on walls. Visuals still use sprite_index.
mask_index = spr_player_idle;
