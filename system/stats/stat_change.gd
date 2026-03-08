class_name StatChange
extends Resource

@export var stat : Stat
@export var amount := 0.0

func to_rich_text(is_cost := false, has_name := true) -> String:
	var _icon = stat.stat_icon.resource_path
	var _sign = "-" if is_cost else "+"
	var _name = stat.stat_name if has_name else ""
	return "[img=24]" + _icon + "[/img] " + _sign + str(amount) + " " + _name
