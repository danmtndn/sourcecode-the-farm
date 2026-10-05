// obj_enemy - Draw: red tint placeholder so you can tell it apart
draw_self();
draw_set_color(c_red);
draw_text(x - 24, y - 48, instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < chase_range ? "CHASE!" : "ENEMY");
draw_set_color(c_white);
