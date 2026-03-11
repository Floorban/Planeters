class_name StatChange
extends Resource

@export var stat : Stat
@export var amount := 0.0

func to_rich_text(value: float, is_cost := false, has_name := true, is_required := false) -> String:
	var color_hex = stat.stat_color.to_html()
	var _icon = stat.stat_icon.resource_path
	var _sign = "-" if is_cost else "+"
	_sign = "" if is_required else _sign
	var _name = stat.stat_name if has_name else ""
	return "[color=#%s][img=32]%s[/img] %s%s %s[/color]" % [
		color_hex, 
		_icon, 
		_sign, 
		value,
		_name
	]
