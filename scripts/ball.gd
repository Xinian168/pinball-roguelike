extends RigidBody2D

# 球超出屏幕底部后自动清理，避免无限堆积
func _process(_delta: float) -> void:
	if global_position.y > 1100.0:
		queue_free()