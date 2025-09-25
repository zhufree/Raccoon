extends Node3D
@onready var camera_3d: Camera3D = $Camera3D
@onready var raccoon_button: TextureButton = $UI/HBoxContainer/RaccoonButton
@onready var lily_button: TextureButton = $UI/HBoxContainer/LilyButton
@onready var panda_button: TextureButton = $UI/HBoxContainer/PandaButton
@onready var dog_button: TextureButton = $UI/HBoxContainer/DogButton
@onready var bo_button: TextureButton = $UI/HBoxContainer/BoButton
@onready var close_button: TextureButton = $UI/CloseButton
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var play_button: TextureButton = $UI/HBoxContainer/VBoxContainer/PlayButton
@onready var sleep_button: TextureButton = $UI/HBoxContainer/VBoxContainer/SleepButton

@onready var bo: Node3D = $Bo
@onready var panda: Node3D = $Panda
@onready var dog: Node3D = $Dog
@onready var lily: Node3D = $Lily
@onready var raccoon: Node3D = $Raccoon
# 摄像头环绕移动相关变量
var is_camera_rotating: bool = false
var camera_distance: float = 10.0  # 摄像头距离中心的半径
var camera_yaw: float = 0.0        # 水平角度（弧度），0为正前方
var camera_pitch: float = 0.3      # 垂直角度（弧度），正值向上俯视
var camera_sensitivity: float = 0.005  # 鼠标敏感度
var last_mouse_position: Vector2

var scenes_containers = []
var current_animal: AnimalBase = raccoon
var touch_points = {}  # 存储触摸点信息
var initial_distance = 0.0  # 初始双指距离
var is_pinching = false  # 是否正在进行双指缩放
var base_fov = 70.0  # 基础 fov 值
var fov_sensitivity = 0.2  # 缩放灵敏度

func _ready():
	base_fov = camera_3d.fov  # 初始化基础 fov
	scenes_containers = [bo, panda, dog, raccoon, lily]
	current_animal = raccoon
	update_button_sizes(raccoon_button)
	
	# 初始化摄像头位置
	update_camera_position()

	#scenes_containers = [raccoon, lily, panda, dog, bo]
	
	# 绑定按钮点击回调
	raccoon_button.connect("pressed", Callable(self, "on_raccoon_button_pressed"))
	lily_button.connect("pressed", Callable(self, "on_lily_button_pressed"))
	panda_button.connect("pressed", Callable(self, "on_panda_button_pressed"))
	dog_button.connect("pressed", Callable(self, "on_dog_button_pressed"))
	bo_button.connect("pressed", Callable(self, "on_bo_button_pressed"))

# 更新摄像头位置（球面坐标系环绕移动）
func update_camera_position():
	# 球面坐标转换为笛卡尔坐标
	var x = camera_distance * cos(camera_pitch) * sin(camera_yaw)
	var y = camera_distance * sin(camera_pitch)
	var z = camera_distance * cos(camera_pitch) * cos(camera_yaw)
	
	# 设置摄像头位置
	camera_3d.global_position = Vector3(x, y, z)
	
	# 让摄像头始终看向中心点(0,0,0)
	camera_3d.look_at(Vector3.ZERO, Vector3.UP)


# 按钮大小常量
const BUTTON_SIZE_NORMAL = Vector2(110, 110)
const BUTTON_SIZE_SELECTED = Vector2(140, 140)
# 重置所有按钮大小为正常状态，然后设置选中按钮为大尺寸
func update_button_sizes(selected_button: TextureButton):
	var all_buttons = [raccoon_button, lily_button, panda_button, dog_button, bo_button]
	
	for button in all_buttons:
		if button == selected_button:
			button.custom_minimum_size = BUTTON_SIZE_SELECTED
		else:
			button.custom_minimum_size = BUTTON_SIZE_NORMAL

func on_raccoon_button_pressed():
	hide_all_scenes()
	raccoon.visible = true
	current_animal = raccoon
	update_button_sizes(raccoon_button)

func on_lily_button_pressed():
	hide_all_scenes()
	lily.visible = true
	current_animal = lily
	update_button_sizes(lily_button)

func on_panda_button_pressed():
	hide_all_scenes()
	panda.visible = true
	current_animal = panda
	update_button_sizes(panda_button)

func on_dog_button_pressed():
	hide_all_scenes()
	dog.visible = true
	current_animal = dog
	update_button_sizes(dog_button)

func on_bo_button_pressed():
	hide_all_scenes()
	bo.visible = true
	current_animal = bo
	update_button_sizes(bo_button)

func hide_all_scenes():
	for scene in scenes_containers:
		scene.visible = false


func _on_play_button_pressed() -> void:
	current_animal.play_action()


func _on_close_button_pressed() -> void:
	pass # Replace with function body.

func _input(event):
	# 处理触摸事件
	if event is InputEventScreenTouch:
		if event.pressed:
			# 记录触摸点
			touch_points[event.index] = event.position
			if touch_points.size() == 2:
				# 开始双指缩放，计算初始距离
				is_pinching = true
				var positions = touch_points.values()
				initial_distance = positions[0].distance_to(positions[1])
			elif touch_points.size() == 1:
				is_camera_rotating = true
				last_mouse_position = event.position
			else:
				is_camera_rotating = false
		else:
			# 释放触摸点
			touch_points.erase(event.index)
			if touch_points.size() < 2:
				is_pinching = false

	# 处理拖动事件（双指移动）
	if event is InputEventScreenDrag and is_pinching and touch_points.size() == 2:
		touch_points[event.index] = event.position
		var positions = touch_points.values()
		var current_distance = positions[0].distance_to(positions[1])
		
		# 计算缩放比例（而不是绝对差值）
		if initial_distance > 0:
			var scale_factor = current_distance / initial_distance
			var fov_change = (1.0 - scale_factor) * camera_3d.fov * fov_sensitivity
			
			# 更新相机 fov（基于当前 fov 而不是 base_fov）
			camera_3d.fov = clamp(camera_3d.fov + fov_change, 30.0, 120.0)
			
			# 更新初始距离以实现平滑缩放
			initial_distance = current_distance
		return

	# 鼠标滚轮缩放（桌面端）
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_3d.fov = clamp(camera_3d.fov - 2.0, 30.0, 120.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_3d.fov = clamp(camera_3d.fov + 2.0, 30.0, 120.0)
	
	# 处理鼠标拖动窗口和摄像头旋转
	# elif event is InputEventMouseButton:
	# 	if event.button_index == MOUSE_BUTTON_LEFT:
	# 		if event.pressed:
	# 			is_camera_rotating = true
	# 			last_mouse_position = event.position
	# 		else:
	# 			is_camera_rotating = false
	
	elif event is InputEventScreenDrag and is_camera_rotating:
		var mouse_delta = event.position - last_mouse_position
		last_mouse_position = event.position
		
		camera_yaw -= mouse_delta.x * camera_sensitivity
		camera_pitch += mouse_delta.y * camera_sensitivity
			
		camera_pitch = clamp(camera_pitch, -PI/2 + 0.5, PI/2 - 0.5)
		
		update_camera_position()
	


func _on_sleep_button_pressed() -> void:
	current_animal.play_sleep()
