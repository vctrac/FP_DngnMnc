extends Spatial


# Declare member variables here. Examples:
# var a = 2
const max_life = 0.4
onready var label = $Viewport/Label
var txt = {1:"Ouch!",2:"Hey!",3:"Ow!",4:"Stop!"}
var life = max_life


# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(txt[int(rand_range(1,5))])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if life<=0:
		queue_free()
	else:
		life -= delta
#	pass
func reset():
	life = max_life
	label.set_text(txt[int(rand_range(1,5))])
