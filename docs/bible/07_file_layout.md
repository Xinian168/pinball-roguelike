# 07_file_layout.md — 目录与文件组织

> 来源：工程实况盘点（2026-10-12）。新建任何文件/目录前必读；命名风格见 08。

## 目录结构（现状 + 约定）

```
res://
├── project.godot          # 工程配置（视口 1920×1080 等，勿手改已由编辑器管理的段）
├── icon.svg / icon.svg.import   # 引擎自带图标，勿动
├── scenes/                # 【约定】所有场景 .tscn 放这里（现有：Main.tscn / FloatingText.tscn）
├── scripts/               # 【约定】所有 GDScript 放这里（现有：launcher.gd / peg_board.gd / ball.gd / round_controller.gd / pocket.gd / normal_zone.gd / hud.gd / floating_text.gd）
│   └── *.gd.uid           # Godot 4 自动生成的脚本 UID 文件，勿手动编辑、勿提交删除逻辑
├── docs/                  # 设计文档（不进游戏包）
│   ├── MVP_Scope.md / Core_Loop.md / Priority_Backlog.md   # 三大设计文档
│   └── bible/             # 本 Bible（10 个模块文件）
├── .godot/                # 引擎缓存（自动生成，勿提交、勿手改）
├── node_2d.tscn           # ⚠️ 残留：无任何引用（默认场景遗留），建议删除
└── $null                  # ⚠️ 残留：命令行误生成的垃圾文件，建议删除
```

## 新建文件的归属规则

| 要新建的东西 | 放哪 | 例外 |
|---|---|---|
| 场景 | `res://scenes/<PascalCase>.tscn` | 无 |
| 脚本 | `res://scripts/<snake_case>.gd` | 无 |
| 音频/图片等资源 | **待定**（尚无资源；首个资源落地时在此定下 `assets/` 结构，并同步 06） | — |
| 临时测试脚本 | `res://test_*.gd`（项目根），**验证通过后必须删除** | 历史上所有 test_*.gd 均已即用即删 |
| 设计文档 | `res://docs/`；Bible 模块 | 无 |

## 残留清理清单（待用户确认后删除）

1. `res://node_2d.tscn` —— 全工程无引用（已搜索确认），Godot 默认场景遗留。
2. `res://$null` —— PowerShell 输出重定向误创建的空文件。

> 按 Bible 流程，删除属于代码层改动，需另行确认，不在本次文档任务内执行。

## 禁止事项

- 不得在 `scenes/`、`scripts/` 之外散放场景/脚本（残留文件除外）。
- 不得提交 `.godot/`、`*.uid` 的手改内容。
- 临时测试脚本不得长存（08_naming 亦有此约定）。
