// obj_player - Create
// Custom instance vars only (no hspeed/vspeed/direction/speed built-ins).
move_speed = 4;
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
