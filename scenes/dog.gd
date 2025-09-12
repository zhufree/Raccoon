extends AnimalBase

func _ready():
	# 设置动画节点引用
	default_anim_node = $DogGame
	active_anim_node = $DogCloud
	sleep_anim_node = $DogSleep
	
	# 调用父类的_ready
	super._ready()
