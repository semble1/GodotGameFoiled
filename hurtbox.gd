extends Area2D

signal character_hit(damage: int)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("hitboxes"):
		emit_signal("character_hit", area.damage)
