extends Node3D
@onready var blink_player: AnimationPlayer = $BlinkAnim

var blink_timer: float = 0.0
var next_blink_time: float = 0.0


func _ready():
	next_blink_time = randf_range(4.0, 7.0)
	
	
func _process(delta: float) -> void:
	blink_timer += delta
	if blink_timer >= next_blink_time:
		blink_player.play("Blink")
		
		blink_timer = 0.0
		# 设置下次眨眼时间（4-7秒之间随机）
		next_blink_time = randf_range(4.0, 7.0)
