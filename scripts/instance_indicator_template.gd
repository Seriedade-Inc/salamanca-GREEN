extends Label

func _on_instance_timer_timeout() -> void:
	queue_free()
