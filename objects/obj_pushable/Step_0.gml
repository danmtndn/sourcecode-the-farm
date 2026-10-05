// obj_pushable - Step: gravity only (player pushes it horizontally in obj_player)
vsp += grav;
if (place_meeting(x, y + vsp, obj_solid)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;
