# 99_decisions.md — 设计决策记录（ADR）

> 记录格式：**决策 #N**（N 全项目递增，不按模块分组）。
> 每条包含：日期、决策内容（一句话）、理由、影响。

---

## 决策 #1

- **日期**：2026-10-12
- **决策内容**：发射器改造为回合制蓄力发射——按住鼠标左键蓄力、松开发射一颗球，冲量随蓄力时间从 200 线性增长到 800、蓄满封顶；移除原连喷（`fire_interval` 连发）、空格/触屏/悬停开火等测试遗留行为。
- **理由**：核心循环（`Core_Loop.md`）的「瞄准 → 蓄力 → 发射」要求一次一颗球承载玩家意图；按住连喷是测试期遗留（Priority_Backlog P0「回合制瞄准」），违背 Inv-4，无法承载蓄力与球数决策重量。
- **影响**：
  - `scripts/launcher.gd`：重写（删 `fire_interval`、`hover_to_fire`、`hover_radius`、`hover_exit_radius`、空格/触屏兜底；增 `min_impulse`、`max_impulse`、`charge_duration`，`launch_angle_jitter_deg` 保留）
  - `docs/bible/03_rules.md`：新增发射规则表（`charge_duration` 标「待定」，默认 1.0s）
  - `docs/bible/04_physics.md`：新增发射器冲量参数与实测结论
  - `docs/bible/_index.md`：Inv-4 由「待改造」更新为「禁止回退」；已知事实中发射器条目同步更新
  - `docs/bible/08_naming.md`：**尚为空**，本次新变量名（`min_impulse`、`max_impulse`、`charge_duration`、私有 `_charging`/`_charge_time` 等）暂无约定可比对，沿用现有代码 snake_case 风格

---

## 决策 #2

- **日期**：2026-10-12
- **决策内容**：确定 MVP 一局规则——起始球数 50，一局倒计时 90 秒，球数 ≥60 进入下一局，倒计时归零未达阈值则失败并重置球数 50，玩家可随时点「结算」提前结束；钉子不影响球数；球落底部普通区域球数 -1，落奖励袋洞球数 +3。
- **理由**：核心循环的「看进袋洞」「看球数变化」两环此前数值全部待定，无法开工；由用户拍板全套数值，打通 P0 实现（袋洞 + 球数管理）前的最后阻塞。
- **影响**：
  - `docs/bible/03_rules.md`：新增「一局规则（MVP）」权威数值节；球数/胜负/袋洞奖励由「待定」转为「已定」，袋洞形态与布局仍待定
  - `docs/bible/05_ui_hud.md`：UI 最小集新增倒计时显示、结算按钮；结算画面语义改为「阈值通过 / 归零重置」
  - `docs/bible/_index.md`：已知事实同步
  - 后续代码：袋洞、球数管理、倒计时、结算按钮四个 P0 功能获得实现依据

---

## 决策 #3

- **日期**：2026-10-13
- **决策内容**：弹珠机状态机 v2 修订——(1) 倒计时归零由"立即 settle"改为"等所有在飞球落地（live_balls==0）后再 settle()"；(2) 袋洞 +N 落"+N 飘字反馈"（`FloatingText` 向上漂 50px + 淡出，1 秒自释放）；(3) 倒计时钳到 ≥0（避免负数显示 -0.0s）。
- **理由**：核心循环的"看球弹"环节赌博感来自"球可能在最后一刻入袋"（用户答复 2026-10-13："所有球落地后，再判断球数"）。timer 一到 0 立即锁死会破坏在飞球落袋 +3 的最终累积，违背"看球弹"环节的完整性。+N 飘字补完 P0 附属项，让袋洞反馈"看得见"。
- **影响**：
  - `scripts/round_controller.gd`：`_process` 倒计时钳到 ≥0；`_check_settle` 改延迟结算（live_balls==0 是 settle 的必要条件）
  - `scripts/pocket.gd`：`body_entered` 时 spawn `FloatingText` 实例
  - `scripts/floating_text.gd`（新）：飘字动画
  - `scenes/FloatingText.tscn`（新）：飘字场景（Node2D + Label，z_index=10）
  - `docs/bible/01_core_loop.md`：看进袋洞现状补 +N 飘字
  - `docs/bible/02_entities.md`：场景树 / 实体表 / 生命周期 增 FloatingText
  - `docs/bible/03_rules.md`：实现状态表更新（奖励袋洞 + 飘字；新增结算时机行；删未实现规则表里的飘字行）
  - `docs/bible/05_ui_hud.md`：袋洞"+3"飘字反馈 缺失→已实现
  - `docs/bible/07_file_layout.md`：scripts/ + scenes/ 文件清单 + 数据来源行补齐
  - `docs/bible/_index.md`：已知事实 + 数据来源行更新
