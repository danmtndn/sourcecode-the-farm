// obj_pushable - Step: gravity only (player pushes it in obj_player)
// Custom vsp only, no built-ins.
if (!variable_instance_exists(id, "vsp")) vsp = 0;
vsp += grav;
if (place_meeting(x, y + vsp, obj_solid)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;
