// obj_player - Create
// Standard PC platformer tuning. Player faster than enemy by design.
move_speed = 4;
jump_speed = -11;
grav = 0.6;
max_hp = 3;

if (!variable_global_exists("hp") || global.hp <= 0) {
    global.hp = max_hp;
}
invuln = 0;
face = 1;
interact_cd = 0;
