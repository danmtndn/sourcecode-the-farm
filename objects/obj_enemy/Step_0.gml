// obj_enemy - Step: patrol until player in range, then chase. Touch = -1 HP.
if (touch_cd > 0) touch_cd -= 1;
vsp += grav;

var _hsp = 0;
var _chasing = false;

if (instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play") {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist < chase_range) _chasing = true;
}

if (_chasing) {
    dir = sign(obj_player.x - x);
    if (dir == 0) dir = 1;
    _hsp = dir * chase_speed;
} else {
    _hsp = dir * patrol_speed;
    if (x < patrol_left) dir = 1;
    if (x > patrol_right) dir = -1;
}

// Horizontal collide
if (place_meeting(x + _hsp, y, obj_solid)) {
    while (!place_meeting(x + sign(_hsp), y, obj_solid)) x += sign(_hsp);
    _hsp = 0;
    if (!_chasing) dir *= -1; // turn around on wall while patrolling
}
x += _hsp;

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
        obj_player.vsp = -8;
        obj_player.x += sign(obj_player.x - x) * 24;
    }
}
