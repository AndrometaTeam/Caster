extends Area2D

# This is an example of an interactable object.

## The _interact() method is required by the player script for
## interactable objects to function! It is the starting method
## for interaction. The player script will throw an error if you
## don't have this method and have a collider on the interaction
## layer.

## Think of the _interact() method as the _ready() method, but
## it's ran every time the player is attempting to interact with
## the object on the interaction layer via the interact key.

## player_body can be thrown away but it's useful for setting
## information about the player.

## Scripts should work as usual, variables, methods, etc.

var is_player_locked: bool = false

func _process(delta):
	if is_player_locked && Input.is_action_just_pressed("exit"):
		is_player_locked = false
		Globals.player_hide(false)

func _interact(player_body):
	player_body.position = self.global_position
	player_body.rotation = self.global_rotation + deg2rad(90)
	is_player_locked = true
	Globals.player_hide()
