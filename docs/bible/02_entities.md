# 02_entities.md — 场景实体结构与职责

> 来源：`scenes/Main.tscn`（2026-10-12 版）+ `scripts/*.gd`。
> 新增或改动任何节点/实体前必读；参数数值详见 `04_physics.md`。

## 场景树总览（Main.tscn，2026-10-13 A 阶段后）

```
Main (Node2D)
├── Background (ColorRect, 1920×1080, 纯黑)
├── Floor (StaticBody2D)
│   └── Shape (CollisionShape2D, 1920×40)
├── BallTemplate (RigidBody2D, freeze + 不可见)
│   ├── Shape (CollisionShape2D, CircleShape2D 半径 15)
│   └── Visual (Sprite2D, 蓝色发光渐变 40px)
├── LeftWall (StaticBody2D)
│   └── Shape (CollisionShape2D, 20×1080)
├── RightWall (StaticBody2D)
│   └── Shape (CollisionShape2D, 20×1080)
├── Ceiling (StaticBody2D)
│   └── Shape (CollisionShape2D, 1920×20)
├── PegBoard (Node2D, 挂 peg_board.gd)
│   └── [运行时] Peg_<x>_<y> × 55 (StaticBody2D)
├── Launcher (Node2D, 挂 launcher.gd)
│   └── Visual (Sprite2D, 灰色圆点 40px)
├── RoundController (Node, 挂 round_controller.gd, 加到组 "round_controller")
├── Pockets (Node2D)
│   ├── Pocket1 (Area2D, 挂 pocket.gd, 位置 (480, 1035))
│   │   ├── Shape (CollisionShape2D, CircleShape2D 半径 50)
│   │   └── Visual (Sprite2D, 青色发光渐变 100px)
│   ├── Pocket2 (Area2D, 位置 (960, 1035), 同上结构)
│   └── Pocket3 (Area2D, 位置 (1440, 1035), 同上结构)
├── NormalZone (Area2D, 挂 normal_zone.gd)
│   ├── Shape1 (CollisionShape2D, 430×30, 位置 (215, 1055))
│   ├── Shape2 (CollisionShape2D, 380×30, 位置 (720, 1055))
│   ├── Shape3 (CollisionShape2D, 380×30, 位置 (1200, 1055))
│   └── Shape4 (CollisionShape2D, 430×30, 位置 (1705, 1055))
├── Hud (CanvasLayer, 挂 hud.gd)
    ├── BallCountLabel (Label, 左上 20,20, text "球数: 50 / 60")
    ├── TimerLabel (Label, 右上 1620,20, text "90.0 s")
    ├── SettleButton (Button, 左下 20,990, text "结算")
    └── SettlePanel (Control, 默认 visible=false, 居中 560~1360 × 440~640)
        ├── SettleResultLabel (Label, text "进入下一局" / "本局失败")
        └── SettleActionButton (Button, text "进入下一局" / "重试")
└── [运行时] FloatingText (Node2D, 挂 floating_text.gd, 袋洞入袋时 spawn 0~N 个并发，1 秒后自释放)
```

## 实体职责表

| 实体 | 类型 | 职责 | 脚本 |
|---|---|---|---|
| `Main` | Node2D | 场景根，所有实体挂其下；发射出的球也 `add_child` 到这里 | 无 |
| `Background` | ColorRect | 纯黑背景（Inv-10 白盒风格），无任何逻辑 | 无 |
| `Floor` | StaticBody2D | 底部地面，球落上去停留反弹；隐形（无 Visual） | 无 |
| `BallTemplate` | RigidBody2D | 球的出厂模板：`freeze=true` + `visible=false`，**不参与游戏**（Inv-6），仅供复制 | 无（运行时由发射器挂 ball.gd 到副本） |
| `LeftWall` / `RightWall` / `Ceiling` | StaticBody2D | 三面隐形反弹边界（Inv-5） | 无 |
| `PegBoard` | Node2D | 图钉阵容器；`_ready` 时按 5×11 交错布局生成图钉（数值见 04） | `peg_board.gd` |
| `Peg_<x>_<y>` | StaticBody2D（运行时） | 单个图钉：碰撞半径 12 + 白色圆点视觉；无脚本无状态 | 无 |
| `Launcher` | Node2D | 蓄力发射（按住左键蓄力、松开发射一颗球，规则见 03）；门控 `rc.can_fire`；发射后 `rc.spend_ball()` | `launcher.gd` |
| `Ball`（运行时） | RigidBody2D | 场上活动的球：复制自 `BallTemplate`，挂 `ball.gd` 后 `freeze=false`、`visible=true`；`y>1100` 自动 `queue_free`（Inv-7） | `ball.gd` |
| `RoundController` | Node | 一局规则状态机：`ball_count` / `time_left` / `round_active` / `can_fire` / `settled` / `last_round_passed`；加到组 `round_controller` 供 `pocket.gd` / `launcher.gd` / `hud.gd` 查询 | `round_controller.gd`（`class_name RoundController`） |
| `Pockets` | Node2D | 袋洞容器（无脚本） | 无 |
| `Pocket1` / `Pocket2` / `Pocket3` | Area2D | 奖励袋洞：球进入 → 通知 RC `register_pocket_drop()`（+reward_balls，默认 3）+ spawn `FloatingText` 显示 `+N`，球 `queue_free` | `pocket.gd` |
| `NormalZone` | Area2D | 底部普通区：球进入 → 立即 `queue_free`（v2 规则不扣球，见 `03_rules.md` 待定项） | `normal_zone.gd` |
| `Hud` | CanvasLayer | 白盒 UI 容器：球数 + 倒计时 + 结算按钮 + 结算面板 | `hud.gd` |
| `Hud/BallCountLabel` | Label | 左上角实时显示 `球数: X / Y`（Y=target_balls） | 无 |
| `Hud/TimerLabel` | Label | 右上角实时显示 `%.1f s`；settled 时隐藏 | 无 |
| `Hud/SettleButton` | Button | 左下角「结算」按钮，触发 `rc.end_early()` | 无 |
| `Hud/SettlePanel` | Control | 居中结算面板（默认 `visible=false`）；含 `SettleResultLabel`（「进入下一局」/「本局失败」）与 `SettleActionButton`（同 label），触发 `rc.continue_to_next_round()` | 无 |
| `FloatingText`（运行时） | Node2D | 飘字反馈：袋洞入袋时 spawn，向上漂 50px + 淡出 1 秒后自释放；@export `float_distance` / `duration` 调参 | `floating_text.gd` |

## 实体生命周期

- **BallTemplate**：场景加载即存在 → 永不进入游戏 → 仅被 `duplicate()`。
- **Ball**：`launcher.gd._fire()` 复制模板并激活 → 物理弹跳 → 离开可玩区（`y > 1100.0`）→ `queue_free()`。
- **Peg**：`PegBoard._ready()` 时生成 → 存活整局 → 不销毁（当前每局 = 一次进程运行；`RoundController.start_round()` 会清掉所有在场球，但图钉不重建）。
- **RoundController**：场景加载即存在（`Main` 的子节点）→ 整个进程生命周期都在；`start_round()` 在 `_ready` 调一次，之后由 `SettlePanel` 按钮触发。
- **Pockets / NormalZone**：场景内置 → 持久；不进不出。
- **Hud / SettlePanel**：`SettlePanel` 默认 `visible=false`；`RoundController.settled=true` 时由 `hud.gd._refresh()` 切到 `visible=true`，按钮触发 `continue_to_next_round()` 后 `start_round()` 把它切回 `false`。
- **FloatingText**：`pocket.gd._spawn_floating_text()` 时 `instantiate()` → `add_child(current_scene)` → 1 秒动画结束 `queue_free()`。一帧内可并发 0~N 个（如连发 3 颗球同时入袋就有 3 个飘字）。

## 尚不存在的实体（未来扩展用，命名遵循 08）

| 计划实体 | 对应功能（优先级） | 备注 |
|---|---|---|
| 祝福三选一 UI | 肉鸽三选一（P1） | 待定：节点结构 / 按钮布局 / 祝福池数据 |
| 袋洞随机化（多局变体） | 图钉阵多样化（P1） | 待定：每局重洗袋洞位置/数量 |
