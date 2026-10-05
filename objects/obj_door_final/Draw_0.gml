draw_self();
draw_set_color(c_aqua);
if (global.code_found == "") draw_text(x - 48, y - 40, "FINAL DOOR: find NOTE");
else if (!typing) draw_text(x - 40, y - 40, "FINAL DOOR [E]");
else draw_text(x - 40, y - 40, "CODE: " + keyboard_string + "_");
draw_set_color(c_white);
