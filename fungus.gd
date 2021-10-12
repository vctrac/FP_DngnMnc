extends StaticBody

var attack_damage = 1
var health = 3
var bubble_res = load("res://bubble_text.tscn")
var bubble_text
var invincibility = false
onready var player = get_tree().get_current_scene().get_node("Player")
onready var anim = $anim
export var attacking = false
# Called when the node enters the scene tree for the first time.
func _ready():
	print(player)

func _process(delta):
	if not anim.is_playing() and player.get_pos().distance_to(transform.origin)<5:
		anim.play("Attack")
	if attacking:
		for body in $Area.get_overlapping_bodies():
			if body.is_in_group("Player"):
				player.get_hit( attack_damage)
func get_hit(dmg):
	if invincibility:
		return
	if !is_instance_valid(bubble_text):
		bubble_text = bubble_res.instance()
		add_child(bubble_text)
	else:
		bubble_text.reset()
	
	if not anim.is_playing():
		anim.play("got_hit")
	health-=dmg
	if health<=0:
#		$anim.play("death")
		queue_free()
		return
	invincibility = true
	yield(get_tree().create_timer(0.5),"timeout")
	invincibility = false
	
