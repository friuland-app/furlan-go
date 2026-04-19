extends Node3D

var animation_player: AnimationPlayer

func _ready():
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	play_idle()

func play_idle():
	animation_player.play("idle")

func play_attack():
	animation_player.play("attack")

func play_capture():
	animation_player.play("capture")

func play_escape():
	animation_player.play("escape")
