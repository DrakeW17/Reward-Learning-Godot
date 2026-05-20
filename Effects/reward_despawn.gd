extends Node2D

# Triggered when the particles finish
func _on_particles_finished() -> void:
	# Deletes itself
	queue_free()
