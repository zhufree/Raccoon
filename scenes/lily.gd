extends AnimalBase

func _ready():
	# 设置动画节点引用
	default_anim_node = $LilyLoaf
	active_anim_node = $LilyDraw
	sleep_anim_node = $LilySleep
	
	# 调用父类的_ready
	super._ready()
