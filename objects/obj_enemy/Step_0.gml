// obj_enemy - Step: patrol until player in range, then chase. Touch = -1 HP.
// Uses custom hsp_enemy/vsp/move_dir only (no built-in hspeed/vspeed/direction).
if (!variable_instance_exists(id, "vsp")) vsp = 0;
if (!variable_instance_exists(id, "move_dir")) move_dir = 1;
if (!variable_instance_exists(id, "hsp_enemy")) hsp_enemy = 0;

if (touch_cd > 0) touch_cd -= 1;
vsp += grav;

hsp_enemy = 0;
var _chasing = false;

if (instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play") {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist < chase_range) _chasing = true;
}

if (_chasing) {
    move_dir = sign(obj_player.x - x);
    if (move_dir == 0) move_dir = 1;
    hsp_enemy = move_dir * chase_speed;
} else {
    hsp_enemy = move_dir * patrol_speed;
    if (x < patrol_left) move_dir = 1;
    if (x > patrol_right) move_dir = -1;
}

// Horizontal collide
if (place_meeting(x + hsp_enemy, y, obj_solid)) {
    while (!place_meeting(x + sign(hsp_enemy), y, obj_solid)) x += sign(hsp_enemy);
    hsp_enemy = 0;
    if (!_chasing) move_dir *= -1; // turn around on wall while patrolling
}
x += hsp_enemy;

// Vertical collide
if (place_meeting(x, y + vsp, obj_solid)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// Damage player on touch (with per-enemy cooldown + player invuln)
if (touch_cd <= 0 && instance_exists(obj_player) && place_meeting(x, y, obj_player)) {
    if (instance_exists(obj_game)) {
        obj_game.take_damage(1);
        touch_cd = 60;
        // Knock player away so they can flee
        if (!variable_instance_exists(obj_player.id, "vsp")) obj_player.vsp = 0;
        obj_player.vsp = -8;
        obj_player.x += sign(obj_player.x - x) * 24;
    }
}
