// obj_pushable - Step: gravity only (player pushes it in obj_player)
// Custom vsp only, no built-ins. Lands on walls, other boxes, closed doors
// AND enemies so boxes stack / rest on heads instead of falling through.
// Frozen while paused.
if (instance_exists(obj_game) && obj_game.state == "pause") exit;
if (!variable_instance_exists(id, "vsp")) vsp = 0;
vsp += grav;
if (place_meeting(x, y + vsp, obj_solid)
|| place_meeting(x, y + vsp, obj_pushable)
|| place_meeting(x, y + vsp, obj_door_key)
|| place_meeting(x, y + vsp, obj_door_final)
|| place_meeting(x, y + vsp, obj_enemy)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)
    && !place_meeting(x, y + sign(vsp), obj_pushable)
    && !place_meeting(x, y + sign(vsp), obj_door_key)
    && !place_meeting(x, y + sign(vsp), obj_door_final)
    && !place_meeting(x, y + sign(vsp), obj_enemy)) y += sign(vsp);
    vsp = 0;
}
y += vsp;
// Never rest inside the player: if we land overlapped, lift out upward.
if (instance_exists(obj_player) && place_meeting(x, y, obj_player)) {
    var _n = 0;
    while (place_meeting(x, y, obj_player) && _n < 64) {
        if (!place_meeting(x, y - 1, obj_solid) && !place_meeting(x, y - 1, obj_pushable)) y -= 1;
        else break;
        _n += 1;
    }
}
// Never rest inside an enemy either: lift out upward the same way.
if (instance_exists(obj_enemy) && place_meeting(x, y, obj_enemy)) {
    var _m = 0;
    while (place_meeting(x, y, obj_enemy) && _m < 64) {
        if (!place_meeting(x, y - 1, obj_solid) && !place_meeting(x, y - 1, obj_pushable)
        && !place_meeting(x, y - 1, obj_enemy)) y -= 1;
        else break;
        _m += 1;
    }
}
// Never overlap another box (e.g. overlapping placements at room start):
// settle upward onto it when headroom allows, else sidestep away from it.
if (place_meeting(x, y, obj_pushable)) {
    var _up2 = 0;
    while (place_meeting(x, y, obj_pushable) && _up2 < 64) {
        if (!place_meeting(x, y - 1, obj_solid) && !place_meeting(x, y - 1, obj_pushable)) y -= 1;
        else break;
        _up2 += 1;
    }
    var _away = 1;
    var _bo2 = instance_place(x, y, obj_pushable);
    if (_bo2 != noone && _bo2 != id) _away = sign(x - _bo2.x);
    if (_away == 0) _away = 1;
    var _side2 = 0;
    while (place_meeting(x, y, obj_pushable) && _side2 < 64) {
        if (!place_meeting(x + _away, y, obj_solid) && !place_meeting(x + _away, y, obj_pushable)
        && !place_meeting(x + _away, y, obj_door_key) && !place_meeting(x + _away, y, obj_door_final)) x += _away;
        else break;
        _side2 += 1;
    }
}
