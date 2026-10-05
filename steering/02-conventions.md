# GML Conventions — MUST FOLLOW

- NEVER use built-ins: `hspeed`, `vspeed`, `direction`, `speed`, `gravity`, `friction`.
- Use custom instance vars: player `hsp/vsp`, enemy `hsp_enemy/vsp/move_dir`, box `vsp`.
- Always init motion in Create: `hsp=0; vsp=0;`
- Defensive guard at top of every Step that reads motion:
  `if (!variable_instance_exists(id,"hsp")) hsp=0;`
- `x/y` built-ins are allowed (position only).
- `move_speed/patrol_speed/chase_speed/jump_speed/grav` are custom instance vars — allowed despite containing "speed".
- Masks: all objects currently share `spr_player` (64x64, origin bottom-center). Player-scope `place_meeting` checks are valid until custom sprites land.
- Pause pattern: `if (obj_game.state != "play")` apply gravity with custom vars, then `exit`.
