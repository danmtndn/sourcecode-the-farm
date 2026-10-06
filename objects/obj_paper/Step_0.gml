// obj_paper - Step: throw physics (set by obj_drawer) + E to read
// Custom hsp/vsp only, no built-ins. Frozen while paused.
if (instance_exists(obj_game) && obj_game.state == "pause") exit;
if (!variable_instance_exists(id, "hsp")) hsp = 0;
if (!variable_instance_exists(id, "vsp")) vsp = 0;
if (!variable_instance_exists(id, "grav")) grav = 0.6;
vsp += grav;
// Horizontal: stop at walls/boxes/closed doors (no bounce, just settle).
if (place_meeting(x + hsp, y, obj_solid)
|| place_meeting(x + hsp, y, obj_pushable)
|| place_meeting(x + hsp, y, obj_door_key)
|| place_meeting(x + hsp, y, obj_door_final)) {
    while (!place_meeting(x + sign(hsp), y, obj_solid)
    && !place_meeting(x + sign(hsp), y, obj_pushable)
    && !place_meeting(x + sign(hsp), y, obj_door_key)
    && !place_meeting(x + sign(hsp), y, obj_door_final)) x += sign(hsp);
    hsp = 0;
}
x += hsp;
// Vertical: land on ground/boxes/door tops.
if (place_meeting(x, y + vsp, obj_solid)
|| place_meeting(x, y + vsp, obj_pushable)
|| place_meeting(x, y + vsp, obj_door_key)
|| place_meeting(x, y + vsp, obj_door_final)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)
    && !place_meeting(x, y + sign(vsp), obj_pushable)
    && !place_meeting(x, y + sign(vsp), obj_door_key)
    && !place_meeting(x, y + sign(vsp), obj_door_final)) y += sign(vsp);
    vsp = 0;
    // Ground friction so the throw settles instead of sliding.
    hsp *= 0.8;
    if (abs(hsp) < 0.1) hsp = 0;
}
y += vsp;
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 56
    && keyboard_check_pressed(ord("E"))) {
        global.code_found = paper_code;
        global.note_open = true; // show zoomed paper immediately
        instance_destroy();
    }
}
