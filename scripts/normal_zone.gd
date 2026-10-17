extends Area2D

## 底部普通区域：v2 规则下仅清理球，不再扣库存。
## 碰撞形状避开袋洞位置，与袋洞不重叠。

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("balls"):
		body.queue_free()
