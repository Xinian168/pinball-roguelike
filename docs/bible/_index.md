# _index.md — 项目宪法索引

> 本文件是 `docs/bible/` 的入口。改动任何模块前先读本表；
> 改动若违反下方「不变量清单」，一律拒绝。

## 资料来源（内容以这些为准，不得凭空编造）

| 来源 | 内容 |
|---|---|
| `docs/MVP_Scope.md` | MVP 做/不做范围、验收标准 |
| `docs/Core_Loop.md` | 核心循环描述、循环图、动词→功能映射 |
| `docs/Priority_Backlog.md` | P0–P3 优先级定义与完整功能清单 |
| 现有工程代码 | `scenes/{Main,FloatingText}.tscn`、`scripts/{launcher,peg_board,ball,round_controller,pocket,normal_zone,hud,floating_text}.gd`、`project.godot` |

**规则**：文档与代码都没规定的数值/规则，一律标注「待定」，任何人不得擅自定值。

---

## 不变量清单（Inv）

以下条目为硬约束，违反即拒绝改动：

- **Inv-1 视口**：游戏视口固定 1920×1080（`project.godot`），stretch 模式 `canvas_items` / `expand`。
- **Inv-2 引擎**：Godot 4.7，渲染 GL Compatibility；主场景为 `res://scenes/Main.tscn`。
- **Inv-3 核心循环**：瞄准 → 蓄力 → 发射 → 看球弹 → 看进袋洞 → 看球数变化 → 想再来一发。任何玩法改动不得砍掉或绕过其中任何一环。
- **Inv-4 回合制发射**：MVP 必须是「逐颗 + 蓄力」发射（P0）。原连喷/悬停开火已于 2026-10-12 改造移除，**禁止回退**为按住连喷等自动发射行为。
- **Inv-5 物理本体**：球 = `RigidBody2D`；墙/图钉/地板 = `StaticBody2D`；反弹由物理引擎自然产生，禁用脚本位移球。
- **Inv-6 球模板**：球必须从 `BallTemplate`（freeze + 不可见）复制生成，模板本身不得参与游戏。
- **Inv-7 自动清理**：球离开可玩区（现值 `y > 1100`）必须自动 `queue_free`，禁止无限堆积。
- **Inv-8 参数暴露**：所有可调参数用 `@export` 暴露在 Inspector；命名遵循 `08_naming.md`。
- **Inv-9 MVP 范围**：MVP 不做局外解锁、商店、特殊球种、多球连锁、音效主题、每日挑战（见 `MVP_Scope.md`）。
- **Inv-10 白盒风格**：黑底、白色图钉、蓝色发光球；视觉不承载玩法语义，玩法验证先于美术。

---

## 模块速查表（改哪块看哪个文件）

| 文件 | 主题 | 什么时候读 |
|---|---|---|
| `01_core_loop.md` | 核心循环五环节与动词映射 | 改发射、袋洞、结算、重开等循环相关功能 |
| `02_entities.md` | 场景实体（球/发射器/图钉/墙/袋洞）结构与职责 | 新增或改动任何节点/实体 |
| `03_rules.md` | 计分、球数、祝福三选一等规则数值 | 改玩法规则、数值、经济 |
| `04_physics.md` | 物理参数、材质合并、清理阈值等 | 改弹跳手感、物理材质、碰撞 |
| `05_ui_hud.md` | HUD 与界面（分数、球数显示） | 做界面、提示、结算画面 |
| `06_audio.md` | 音效（当前全部待定） | 引入声音时 |
| `07_file_layout.md` | 目录与文件组织规范 | 新建任何文件/目录 |
| `08_naming.md` | 节点、脚本、文件、@export 命名约定 | 写任何代码、起任何名字 |
| `99_decisions.md` | 已拍板的设计决策记录（ADR） | 想知道「为什么这么定」时 |

---

## 当前已知事实（来自代码，供各模块引用）

- 视口 1920×1080；背景纯黑（ColorRect）。
- 墙体（左/右/顶）与地板：物理可见性已移除（隐形反弹），尺寸见 `02_entities.md`。
- 图钉：运行时生成，5 行 × 11 列交错，碰撞半径 12 / 视觉半径 10，纯白。
- 发射器：位于 (1600, 900)；蓄力发射（按住左键蓄力、松开发射），`min_impulse=200.0`、`max_impulse=800.0`、`charge_duration=1.0`（**待定**）。**瞄准方向 = 鼠标光标相对发射器的向量**（光标贴发射器上时默认向上），原 `launch_angle_jitter_deg=15.0` 已在 A 阶段（2026-10-13）随鼠标瞄准改造一起移除。详见 `03_rules.md` / `04_physics.md`。
- 球：碰撞半径 15，物理材质 friction 0.2 / bounce 0.6；蓝色发光渐变 40px。
- 球清理阈值：`y > 1100.0`。
- 一局规则（2026-10-12 拍板 / 2026-10-13 A 阶段 + 决策 #3 v2 修订）：起始 50 / 倒计时 90s（**timer 归零延迟结算**，等所有在飞球落地）/ 阈值 ≥60 / 失败重置 50 / 袋洞 +3 + 飘字反馈 / 每次发射扣 `fire_cost=1` / **普通区当前实现为 0**（v2 保留 -1 数值，A 阶段决定不扣球）。实现见 `scripts/round_controller.gd` + `scripts/pocket.gd` + `scripts/floating_text.gd` + `Pockets`（3 个 Area2D）+ `NormalZone`（4 段 Area2D）+ `FloatingText`（运行时 spawn）+ `SettlePanel`；数值与状态详见 `03_rules.md` 各项规则实现状态表。
- 祝福池：尚未实现，数值待定（P1）。
- 袋洞布局随机化 / 多局变体：当前固定 3 个（x=480/960/1440, y=1035），尚未随机化（P1「图钉阵多样化」）。
- 蓄力条 / 力度指示 UI：P0 附属项，**尚未实现**（盲蓄力）。
- 袋洞"+N"飘字反馈 UI：✅ 已实现（决策 #3）—— `pocket.gd` 在球入袋时 spawn `scenes/FloatingText.tscn` 到 `current_scene`，绿色 `+N` 文字向上漂 50px + 淡出 1 秒后释放。详见 `05_ui_hud.md`。
