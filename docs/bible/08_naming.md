# 08_naming.md — 命名约定

> 来源：现有代码既成风格（`launcher.gd`、`peg_board.gd`、`ball.gd`、`Main.tscn`）+ Godot 官方 GDScript 风格指南。
> 本文件自 2026-10-12 起生效；此前已存在的名字不改名，新代码必须遵守。

## 目录与文件

| 对象 | 约定 | 现有实例 |
|---|---|---|
| 场景文件 | `PascalCase.tscn`，放 `res://scenes/` | `Main.tscn` |
| 脚本文件 | `snake_case.gd`，放 `res://scripts/` | `launcher.gd`、`peg_board.gd`、`ball.gd` |
| 项目根临时测试脚本 | `test_*.gd`，**验证后必须删除** | （每次用完即删） |
| docs 文档 | `PascalCase.md`；bible 模块为 `NN_snake_case.md` | `MVP_Scope.md`、`03_rules.md` |

## 节点命名（场景树）

| 对象 | 约定 | 现有实例 |
|---|---|---|
| 节点 | `PascalCase` | `Main`、`Floor`、`BallTemplate`、`LeftWall`、`PegBoard`、`Launcher` |
| 碰撞形状子节点 | `Shape` | `Floor/Shape`、`Launcher` 的图钉 `col` 除外（见运行时生成） |
| 纯视觉子节点 | `Visual` | `Launcher/Visual` |
| 运行时生成的同类节点 | `类型_坐标` 或含序号 | 图钉：`Peg_<x>_<y>`（坐标取整） |
| 模板节点（不参与游戏） | `XxxTemplate` | `BallTemplate` |

## GDScript 标识符

| 对象 | 约定 | 现有实例 |
|---|---|---|
| `@export` 变量 | `snake_case`，中文注释说明含义与单位 | `min_impulse`、`charge_duration` |
| 脚本内常量 | `SCREAMING_SNAKE_CASE` | `PEG_COLLISION_RADIUS` |
| 私有成员 | `_` 前缀 | `_charging`、`_ball_script` |
| 私有方法 | `_` 前缀 + 动词开头 | `_start_charge()`、`release` 语义用 `_release_fire()` |
| 公开方法（供外部/测试调用） | 无前缀、动词开头 | （暂无实例，待定） |
| 调试打印 | `[节点名]` 前缀 | `print("[Launcher] ...")` |
| 场景内脚本引用的属性名 | 与 `@export` 变量名一致，场景中保存 `NodePath` 等值 | `ball_template = NodePath("../BallTemplate")` |

## 暂无实例、待定的类别

- **信号命名**：项目尚无自定义信号。建议（待定）：Godot 官方惯例——`snake_case`、过去式事件名（如 `ball_fired`、`pocket_entered`）。
- **自动加载单例（Autoload）**：尚无。命名待定。
- **枚举**：尚无。建议（待定）：`PascalCase` 类型名 + `SCREAMING_SNAKE` 成员。
- **物理层名称**：目前只用默认 layer 1；引入多层时需在本文件登记 `project.godot` 的 layer 命名。
