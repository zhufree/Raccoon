extends AnimalBase

func _ready():
	# 设置动画节点引用
	default_anim_node = $PandaSit
	active_anim_node = $PandaMoney
	sleep_anim_node = $PandaSleep
	
	# 调用父类的_ready
	super._ready()
