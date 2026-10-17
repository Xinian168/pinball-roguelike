extends CanvasLayer

## 白盒 HUD：球数、倒计时、结算按钮、结算面板
## 所有数值从 RoundController 读取（一局规则见 docs/bible/03_rules.md「v2」）

var _rc = null  # RoundController

@onready var ball_count_label: Label = $BallCountLabel
@onready var timer_label: Label = $TimerLabel
@onready var settle_button: Button = $SettleButton
@onready var settle_panel: Control = $SettlePanel
@onready var settle_result_label: Label = $SettlePanel/SettleResultLabel
@onready var settle_action_button: Button = $SettlePanel/SettleActionButton


func _ready() -> void:
	_rc = get_tree().get_first_node_in_group("round_controller")
	settle_button.pressed.connect(_on_settle_pressed)
	settle_action_button.pressed.connect(_on_action_pressed)
	_refresh()


func _process(_delta: float) -> void:
	if _rc == null:
		_rc = get_tree().get_first_node_in_group("round_controller")
		if _rc == null:
			return
	_refresh()


func _refresh() -> void:
	if _rc == null:
		return
	ball_count_label.text = "球数: %d / %d" % [_rc.ball_count, _rc.target_balls]
	if _rc.settled:
		# 结算面板：隐藏 play UI
		timer_label.visible = false
		settle_button.visible = false
		settle_panel.visible = true
		if _rc.last_round_passed:
			settle_result_label.text = "进入下一局"
			settle_action_button.text = "进入下一局"
		else:
			settle_result_label.text = "本局失败"
			settle_action_button.text = "重试"
	else:
		# 游戏中：显示 play UI，隐藏结算面板
		timer_label.text = "%.1f s" % _rc.time_left
		timer_label.visible = true
		settle_button.visible = true
		settle_panel.visible = false


## 「结算」按钮：玩家手动提前结束本局
func _on_settle_pressed() -> void:
	if _rc != null:
		_rc.end_early()


## 结算面板上的「进入下一局」或「重试」按钮
func _on_action_pressed() -> void:
	if _rc != null:
		_rc.continue_to_next_round()
