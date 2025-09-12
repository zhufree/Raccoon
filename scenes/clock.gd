extends TextureRect
@onready var hour_hand: TextureRect = $HourHand
@onready var minute_hand: TextureRect = $MinuteHand
@onready var timer: Timer = Timer.new()

func _ready():
	# 添加定时器到场景
	add_child(timer)
	timer.wait_time = 60.0  # 每60秒更新一次
	timer.timeout.connect(_update_clock)
	timer.start()
	
	# 立即更新一次时钟
	_update_clock()

func _update_clock():
	# 获取当前系统时间
	var current_time = Time.get_datetime_dict_from_system()
	var hours = current_time.hour
	var minutes = current_time.minute
	
	# 计算分针角度 (每分钟6度)
	var minute_angle = minutes * 6.0
	
	# 计算时针角度 (每小时30度 + 每分钟0.5度)
	var hour_angle = (hours % 12) * 30.0 + minutes * 0.5
	
	# 应用旋转角度
	minute_hand.rotation_degrees = minute_angle
	hour_hand.rotation_degrees = hour_angle
