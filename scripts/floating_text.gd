extends Node2D

## 飘字反馈（如袋洞 +3）。从当前位置向上漂移并淡出，duration 后自动释放。
## 文本内容由调用方通过 set_text() 设置（如 `pocket.gd` 传入 "+3"）。
## 节点层级：Node2D + Label 子节点；z_index = 10 保证在场景上方。

@export var float_distance: float = 50.0   # 上升距离（像素）
@export var duration: float = 1.0          # 持续时间（秒）

@onready var _label: Label = $Label
var _elapsed: float = 0.0


func _ready() -> void:
	z_index = 10  # 浮在场景之上，不被其他元素遮挡
	_label.modulate.a = 1.0


## 由调用方设置文本
func set_text(text: String) -> void:
	if _label != null:
		_label.text = text


func _process(delta: float) -> void:
	_elapsed += delta
	var t: float = clampf(_elapsed / duration, 0.0, 1.0)
	position.y -= float_distance * delta / duration
	_label.modulate.a = 1.0 - t
	if t >= 1.0:
		queue_free()
