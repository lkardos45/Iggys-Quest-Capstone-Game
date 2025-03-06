extends Block_Base

class_name Block_Item

enum itemType {
	coin,
	berry,
	fire
}

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var item_type: itemType = itemType.coin
@export var invisible: bool = false
var is_empty = false

@onready var game_manager = %GameManager
@onready var sfx_block_item = $sfx_block_item

# Item References
const COIN_FROM_BOX = preload("res://Scenes/coin_from_box.tscn")
const BERRY = preload("res://Scenes/Berry.tscn")
const FIRE_POWER = preload("res://Scenes/fire_power.tscn")

func _ready():
	animated_sprite_2d.visible = !invisible

func bump(power: Player.playerMode):
	if is_empty:
		return
	if invisible:
		animated_sprite_2d.visible = true
		invisible = !invisible
	
	super.bump(power)
	make_empty()
	
	match item_type:
		itemType.coin:
			spawn_coin()
		itemType.berry:
			spawn_berry()
		itemType.fire:
			spawn_fire()
	

func make_empty():
	is_empty = true
	animated_sprite_2d.play("empty")
	
func spawn_coin():
	print("Block spawned coin!")
	var coin = COIN_FROM_BOX.instantiate()
	coin.global_position = global_position + Vector2(0, -16)
	get_tree().current_scene.add_child(coin)
	game_manager.add_coin()
	
func spawn_berry():
	sfx_block_item.play()
	print("Block spawned a berry!")
	var berry = BERRY.instantiate()
	berry.global_position = global_position + Vector2(0, -27)
	get_tree().current_scene.add_child(berry)
	
func spawn_fire():
	sfx_block_item.play()
	print("Block spawned fire!")
	var fire = FIRE_POWER.instantiate()
	fire.global_position = global_position + Vector2(0, -27)
	get_tree().current_scene.add_child(fire)
