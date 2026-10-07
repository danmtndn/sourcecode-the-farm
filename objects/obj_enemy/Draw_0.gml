// obj_enemy - Draw: sprite only, no debug label. Alpha preserved for spawn fade.
if (!variable_instance_exists(id, "aggro")) aggro = false;
draw_set_alpha(image_alpha);
draw_self();
draw_set_alpha(1);
