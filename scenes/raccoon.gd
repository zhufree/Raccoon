extends AnimalBase

func _ready():
	# 设置动画节点引用
	default_anim_node = $RaccoonSit
	active_anim_node = $RaccoonRun
	sleep_anim_node = $RaccoonSleep
	
	# 调用父类的_ready
	super._ready()
