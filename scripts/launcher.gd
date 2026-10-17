extends Node2D

## 弹珠发射器（回合制蓄力版，符合 Bible Inv-4）
## 行为：按住鼠标左键开始蓄力，松开发射一颗弹珠。
## 力度 = min_impulse 按蓄力时间线性增长到 max_impulse，封顶不再增长。
## 方向 = 发射器指向鼠标光标（鼠标瞄准）。
## 门控：仅当 RoundController.can_fire = true 时允许蓄力/发射。
## v2 规则：发射成功后调用 rc.spend_ball() 扣库存。

@export var min_impulse: float = 200.0           # 最小发射冲量（点按即发射）
@export var max_impulse: float = 800.0          # 最大发射冲量（蓄满封顶）
@export var charge_duration: float = 1.0        # 从最小充到最大的时长（秒）【待定：文档未规定，默认 1.0 秒】
@export var ball_template: NodePath             # 球模板节点

var _charging := false
var _charge_time := 0.0
var _ball_script: Script


func _ready() -> void:
	_ball_script = load("res://scripts/ball.gd")


## 事件驱动：按住/松开（保留之前确认能工作的通道）
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_charge()
		else:
			_release_fire()


func _process(delta: float) -> void:
	# 轮询兜底：若事件通道丢失，用全局鼠标状态补齐
	var held := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if held and not _charging:
		_start_charge()
	elif _charging and not held:
		_release_fire()

	if _charging:
		_charge_time = minf(_charge_time + delta, charge_duration)


func _rc():
	return get_tree().get_first_node_in_group("round_controller")


## 开始蓄力：仅当 RoundController 允许发射（球数>0 且未结算）
func _start_charge() -> void:
	var r = _rc()
	if r != null and not r.can_fire:
		_charging = false
		return
	_charging = true
	_charge_time = 0.0


## 松开发射：按当前蓄力比例计算冲量，扣除库存
func _release_fire() -> void:
	if not _charging:
		return
	_charging = false
	var r = _rc()
	if r != null and r.can_fire:
		_fire(_current_impulse())
		r.spend_ball()
	_charge_time = 0.0


## 当前蓄力对应的冲量（线性插值 + 封顶）
func _current_impulse() -> float:
	if charge_duration <= 0.0:
		return max_impulse
	var t := clampf(_charge_time / charge_duration, 0.0, 1.0)
	return lerpf(min_impulse, max_impulse, t)


## 瞄准方向：发射器指向鼠标光标；光标贴在发射器上时默认向上
func _aim_direction() -> Vector2:
	var v: Vector2 = get_global_mouse_position() - global_position
	if v.length() < 1.0:
		return Vector2.UP
	return v.normalized()


## 复制模板球，沿瞄准方向施加冲量
func _fire(impulse: float) -> void:
	if ball_template.is_empty():
		push_warning("Launcher: ball_template 未设置，无法发射")
		return
	var template: Node = get_node_or_null(ball_template)
	if template == null:
		push_warning("Launcher: 找不到 ball_template 节点，请检查 NodePath")
		return

	var ball: RigidBody2D = template.duplicate() as RigidBody2D
	if ball == null:
		return
	ball.set_script(_ball_script)
	ball.add_to_group("balls")
	get_parent().add_child(ball)
	ball.freeze = false
	ball.visible = true
	ball.global_position = global_position
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.apply_central_impulse(_aim_direction() * impulse)
