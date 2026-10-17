extends Area2D

## 奖励袋洞：球进入 → 库存球数 +reward_balls（由 RoundController 决定数值）
## 同时播放 +N 飘字反馈（数量 = RoundController.reward_balls）
## 球被捕获后立即销毁，不会落入普通区域造成重复结算
## 飘字场景：res://scenes/FloatingText.tscn

const FLOATING_TEXT_SCENE = preload("res://scenes/FloatingText.tscn")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("balls"):
		var r = get_tree().get_first_node_in_group("round_controller")
		if r != null:
			r.register_pocket_drop()
			_spawn_floating_text("+%d" % r.reward_balls)
		body.queue_free()


## 弹出飘字反馈：spawn 在袋洞当前位置，挂在 current_scene（Main）下
func _spawn_floating_text(text: String) -> void:
	var instance: Node2D = FLOATING_TEXT_SCENE.instantiate()
	instance.global_position = global_position
	instance.set_text(text)
	get_tree().current_scene.add_child(instance)
