extends Node2D

## 白盒图钉阵生成器
## 运行时在屏幕上半部生成一片白色图钉阵（白盒验收风格）
## 图钉 = StaticBody2D + CircleShape2D(半径12) + 白色圆点 Sprite2D
## 球（layer 1）与图钉（默认 layer 1）自动发生物理碰撞反弹

const PEG_COLLISION_RADIUS := 12.0  # 碰撞半径
const PEG_VISUAL_RADIUS := 10.0     # 视觉半径
const PEG_COLOR := Color(1, 1, 1)   # 纯白


func _ready() -> void:
	_generate_pegs()


func _generate_pegs() -> void:
	var cols := 11                       # 每行 11 个
	var rows := 5                        # 共 5 行
	var x_start := 330.0                 # 第一列 x
	var x_step := 120.0                  # 列间距
	var y_start := 300.0                 # 第一行 y
	var y_step := 80.0                   # 行间距

	for r in rows:
		var y := y_start + r * y_step
		# 奇数行错开半个间距，形成交错阵型
		var x_offset: float = (x_step * 0.5) if r % 2 == 1 else 0.0
		for c in cols:
			var x := x_start + c * x_step + x_offset
			_make_peg(Vector2(x, y))


func _make_peg(pos: Vector2) -> void:
	var peg := StaticBody2D.new()
	peg.name = "Peg_%d_%d" % [int(pos.x), int(pos.y)]
	peg.position = pos

	# 碰撞形状
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = PEG_COLLISION_RADIUS
	col.shape = shape
	peg.add_child(col)

	# 视觉：白色小圆点
	var visual := Sprite2D.new()
	var tex := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.8, 1.0])
	gradient.colors = PackedColorArray([
		PEG_COLOR,
		PEG_COLOR,
		Color(PEG_COLOR.r, PEG_COLOR.g, PEG_COLOR.b, 0.0),
	])
	tex.gradient = gradient
	tex.width = int(PEG_VISUAL_RADIUS * 2.0)
	tex.height = int(PEG_VISUAL_RADIUS * 2.0)
	tex.fill = 1  # RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	visual.texture = tex
	peg.add_child(visual)

	add_child(peg)