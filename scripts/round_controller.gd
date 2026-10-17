extends Node
class_name RoundController

## 一局规则管理（权威数值：docs/bible/03_rules.md「一局规则（v2）」）
## 起始 50 球 / 倒计时 90s / 阈值 ≥60 进下一局 / 失败重置 50
## 发射扣 fire_cost / 袋洞 +reward_balls / 普通区 0

@export var round_seconds: float = 90.0   # 一局倒计时（秒）
@export var start_balls: int = 50         # 起始球数
@export var target_balls: int = 60        # 进入下一局阈值
@export var reward_balls: int = 3         # 球落袋洞的奖励球数
@export var fire_cost: int = 1            # 每次发射扣除的球数

var ball_count: int = 0          # 当前库存球数
var time_left: float = 0.0       # 本局剩余时间
var live_balls: int = 0          # 场上活动球数
var round_active: bool = false   # 局是否进行中（含 WAIT_EMPTY 阶段）
var can_fire: bool = false       # 当前是否允许发射（球数>0 && round_active）
var settled: bool = false        # 本局是否已结算（结算面板显示中）
var last_round_passed: bool = false  # 上局是否达标


func _ready() -> void:
	add_to_group("round_controller")
	start_round()


func _process(delta: float) -> void:
	if round_active and not settled:
		time_left = max(time_left - delta, 0.0)
		_update_live_balls()
		_update_fire_gate()
		_check_settle()


## 开始一局：重置库存、倒计时、清理场上的球
func start_round() -> void:
	ball_count = start_balls
	time_left = round_seconds
	settled = false
	round_active = true
	_clear_field_balls()
	_update_fire_gate()


## 玩家点「结算」按钮：立即结算（不清理场上剩余球）
func end_early() -> void:
	settle()


## 局末确认：成功显示「进入下一局」、失败显示「重试」
## 按 v2 范围声明（user scope #2），成功也不实现下一局内容，
## 与失败「重试」一样只是重启本局
func continue_to_next_round() -> void:
	if not settled:
		return
	start_round()


## 结算：计算达标状态、锁定发射、清状态机
func settle() -> void:
	if not round_active or settled:
		return
	settled = true
	round_active = false
	can_fire = false
	last_round_passed = ball_count >= target_balls


## 球落入奖励袋洞：+reward_balls
func register_pocket_drop() -> void:
	if round_active and not settled:
		ball_count += reward_balls
		_update_fire_gate()
		_check_settle()


## 发射扣球：仅在可发射时生效（launcher._fire 成功后调用）
func spend_ball() -> void:
	if can_fire and not settled:
		ball_count -= fire_cost
		_update_fire_gate()


## 计算当前是否允许发射
func _update_fire_gate() -> void:
	can_fire = round_active and not settled and ball_count > 0


## 场上活动球数（每帧更新一次）
func _update_live_balls() -> void:
	live_balls = get_tree().get_nodes_in_group("balls").size()


## 检查结算条件（v2 修正，2026-10-13 用户答复）：
##   - 倒计时归零时**不立即** settle，等所有在飞球落地后再结算
##     （保证落地入袋洞的 +3 仍能计入最终球数）
##   - 球数=0 + 场上无球：立即 settle
##   - 倒计时=0 + 场上无球：立即 settle
##   - 还有在飞球：无论 timer 状态都不 settle（等落地）
## 手动点「结算」按钮（end_early → settle）走直通，行为不变。
func _check_settle() -> void:
	if live_balls > 0:
		return  # 还有在飞球，等落地
	if time_left <= 0.0 or ball_count <= 0:
		settle()


## 清场：移除场上所有活动球
func _clear_field_balls() -> void:
	for b in get_tree().get_nodes_in_group("balls"):
		b.queue_free()
	live_balls = 0
