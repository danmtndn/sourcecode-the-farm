// obj_pushable - Step: gravity only (player pushes it in obj_player)
// Custom vsp only, no built-ins. Lands on walls, other boxes, closed doors
// AND enemies so boxes stack / rest on heads instead of falling through.
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
