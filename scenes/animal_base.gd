extends Node3D
class_name AnimalBase

# 动画状态枚举
enum AnimState {
	DEFAULT,
	ACTIVE,
	SLEEP
}

# 子类需要重写这些变量来指定具体的动画节点
@export var default_anim_node: Node3D
@export var active_anim_node: Node3D
@export var sleep_anim_node: Node3D

# 内部状态管理
var current_state: AnimState = AnimState.DEFAULT
var sleep_timer: Timer
var action_timer: Timer
var is_sleep_time: bool = false

func _ready():
	# 创建睡眠定时器
	sleep_timer = Timer.new()
	add_child(sleep_timer)
	sleep_timer.wait_time = 60.0  # 睡眠持续1分钟
	sleep_timer.one_shot = true
	sleep_timer.timeout.connect(_on_sleep_timer_timeout)
	
		
	# 创建主动动画定时器
	action_timer = Timer.new()
	add_child(action_timer)
	action_timer.wait_time = 10.0 # 主动动画持续3秒
	action_timer.one_shot = true
	action_timer.timeout.connect(_on_action_timer_timeout)


	# 设置初始状态
	set_animation_state(AnimState.DEFAULT)
	
	# 开始检查睡眠时间
	_check_sleep_schedule()

func _on_action_timer_timeout():
	# 主动动画播放完毕，回到默认状态
	if current_state == AnimState.ACTIVE and not is_sleep_time:
		set_animation_state(AnimState.DEFAULT)


func _process(delta):
	# 每秒检查一次是否到了睡眠时间
	if Engine.get_process_frames() % 60 == 0:  # 大约每秒检查一次
		_check_sleep_schedule()

func _check_sleep_schedule():
	var current_time = Time.get_datetime_dict_from_system()
	var hour = current_time.hour
	var minute = current_time.minute
	
	# 检查是否是中午12点或晚上12点的整点
	if (hour == 12 or hour == 0) and minute == 0:
	#if minute == 54:
		if not is_sleep_time:
			is_sleep_time = true
			set_animation_state(AnimState.SLEEP)
			sleep_timer.start()
	else:
		is_sleep_time = false

func _on_sleep_timer_timeout():
	# 睡眠时间结束，回到默认状态
	is_sleep_time = false
	set_animation_state(AnimState.DEFAULT)

# 设置动画状态
func set_animation_state(state: AnimState):
	if not default_anim_node or not active_anim_node or not sleep_anim_node:
		push_error("动画节点未正确设置！请在子类中设置 default_anim_node, active_anim_node, sleep_anim_node")
		return
	
	current_state = state
	
	# 隐藏所有动画
	default_anim_node.visible = false
	active_anim_node.visible = false
	sleep_anim_node.visible = false
	
	# 显示对应的动画
	match state:
		AnimState.DEFAULT:
			default_anim_node.visible = true
		AnimState.ACTIVE:
			active_anim_node.visible = true
		AnimState.SLEEP:
			sleep_anim_node.visible = true

# 播放主动动画（供外部调用）
func play_action():
	if not is_sleep_time:  # 睡眠时间不响应主动调用
		set_animation_state(AnimState.ACTIVE)
		action_timer.start()

# 回到默认状态（供外部调用）
func return_to_default():
	if not is_sleep_time:  # 睡眠时间不响应外部调用
		set_animation_state(AnimState.DEFAULT)

# 获取当前状态
func get_current_state() -> AnimState:
	return current_state

# 检查是否在睡眠时间
func is_in_sleep_time() -> bool:
	return is_sleep_time
