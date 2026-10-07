// obj_enemy - Draw: red tint placeholder so you can tell it apart.
// Wrapped in image_alpha so the spawn/despawn fades cover the label too.
if (!variable_instance_exists(id, "aggro")) aggro = false;
draw_set_alpha(image_alpha);
draw_self();
draw_set_color(c_red);
draw_text(x - 24, y - 48, aggro || (instance_exists(obj_player) && abs(obj_player.x - x) < chase_range && abs(obj_player.y - y) < chase_range / 2) ? "CHASE!" : "ENEMY");
draw_set_color(c_white);
draw_set_alpha(1);
