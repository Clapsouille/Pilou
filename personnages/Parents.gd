extends RigidBody2D

signal gagne


func _on_Arrivee_body_entered(body):
	if body.name == "Pilou":
		emit_signal("gagne")		
		$Roberte/AnimationPlayer.play("feter_pilou")
		$Jeanfrancois/AnimationPlayer.play("feter_pilou")

func _ready():
	$Roberte/AnimationPlayer.play("repos")
	$Jeanfrancois/AnimationPlayer.play("repos")
