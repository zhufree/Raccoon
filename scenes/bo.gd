extends AnimalBase

func _ready():
	# 设置动画节点引用
	default_anim_node = $BoReading
	active_anim_node = $BoWatering
	sleep_anim_node = $BoSleeping
	
	# 调用父类的_ready
	super._ready()
