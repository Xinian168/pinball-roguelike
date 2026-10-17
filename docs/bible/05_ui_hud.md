# 05_ui_hud.md — HUD 与界面

> 来源：当前工程实况（2026-10-13 A 阶段后）+ `docs/Core_Loop.md`、`docs/MVP_Scope.md` 的 UI 需求推导。
> 改任何 UI 元素前必读；节点结构见 `02_entities.md`，数值来源见 `03_rules.md`。

## 当前状态

- HUD 已实现：`Hud` 节点（`CanvasLayer`）挂 `hud.gd`，含 3 个常驻 UI 元素 + 1 个默认隐藏的 `SettlePanel`。
- 袋洞 +N 飘字反馈已实现：球入袋时 `pocket.gd` spawn `FloatingText` 实例（绿色 `+N` 文字，向上漂 50px + 淡出 1 秒后释放），由 `rc.reward_balls` 驱动数值。
- 蓄力**仍无视觉反馈**：玩家看不到当前力度，只能凭手感估计按住时长（P0 附属项，未实现）。
- 调试打印的 `print("[Launcher] ...")` 已在 2026-10-12 决策 #1 中标记"上线前移除/可开关"，但**当前 launcher 已不打印**（A 阶段改写时删了）——此条历史遗留已自然清空。

## 核心循环要求的 UI（最小集）

| UI 项 | 服务的循环环节 | 优先级归属 | 状态 |
|---|---|---|---|
| 剩余球数显示 | 看球数变化 | P0「球数管理与结算」 | ✅ 已实现 `Hud/BallCountLabel` |
| 倒计时显示（90 秒/局） | 看球数变化 | P0「一局规则」 | ✅ 已实现 `Hud/TimerLabel` |
| 结算按钮（随时提前结束本局） | 看球数变化 → 想再来一发 | P0「一局规则」 | ✅ 已实现 `Hud/SettleButton` |
| 局末结算画面（成功/失败 + 下一局/重开） | 想再来一发 | P0（v2 落地后已升 P0） | ✅ 已实现 `Hud/SettlePanel` |
| 蓄力条/力度指示 | 蓄力 | P0「核心发射」的附属项 | **缺失**（盲蓄力） |
| 袋洞"+N"飘字反馈 | 看进袋洞 | P0「奖励袋洞」附属 | ✅ 已实现（运行时 spawn `FloatingText`，决策 #3） |

## 已定 UI 项

- UI 层结构：✅ 已定 = `CanvasLayer`（白盒阶段所有 UI 挂其下）。
- 球数显示位置：✅ 已定 = 左上角 `offset_left=20, offset_top=20`，字体 32，显示 `球数: X / Y`（Y = `target_balls`）。
- 倒计时显示位置：✅ 已定 = 右上角 `offset_left=1620, offset_top=20`，字体 32，显示 `%.1f s`。
- 结算按钮位置：✅ 已定 = 左下角 `offset_left=20, offset_top=990`，text = "结算"。
- 结算画面形式：✅ 已定 = `SettlePanel`（`Control`，居中 800×200），内含 `SettleResultLabel`（「进入下一局」/「本局失败」）+ `SettleActionButton`（text 同 label）；默认 `visible=false`，settled 时显示。
- 调试打印：✅ 现状 = 发射器已不打印（无须开关）。
- 袋洞"+N"飘字反馈：✅ 已定 = `pocket.gd` 在球入袋时 `instantiate` `scenes/FloatingText.tscn` → `add_child(current_scene)`；实例含 `Label` 子节点，文本 = `"+%d" % rc.reward_balls`，向上漂 50px + 淡出 1 秒后自释放；`z_index = 10` 保证显示在场景之上。

## 待定项

- 蓄力条形态与位置：**待定**（盲蓄力，玩起来后再决定要加条 / 圆环 / 数字）
- 结算画面动效/音效：**待定**（P2 增强项）
- 文字 / 配色 / 字体：**待定**（白盒阶段用默认字体，Inv-10）

## 约束引用

- Inv-10：白盒阶段视觉不承载玩法语义，UI 先求"看得见信息"，不求美术。
- Inv-8：UI 相关可调参数走 `@export`（当前 `Hud` 节点无可调参数；如加蓄力条/飘字，需走 `@export` 暴露）。
- 08_naming：UI 节点用 `PascalCase`，现状：`Hud`、`BallCountLabel`、`TimerLabel`、`SettleButton`、`SettlePanel`、`SettleResultLabel`、`SettleActionButton`。
