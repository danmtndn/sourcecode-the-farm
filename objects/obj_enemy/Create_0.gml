// obj_enemy - Create: Patrol + chase (slower than player so player can escape)
// Player move_speed = 4. Enemy chase 2.8, patrol 1.5.
// Custom instance vars only (no hspeed/vspeed/direction).
patrol_speed = 1.5;
chase_speed = 2.8;
grav = 0.6;
hsp_enemy = 0;
vsp = 0;
move_dir = 1;
chase_range = 320;   // EDIT per level: L1 240, L2 320, L3 400 for difficulty
patrol_left = x - 160;  // EDIT or set per instance in room editor via Creation Code
patrol_right = x + 160;
touch_cd = 0;
