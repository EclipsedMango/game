extends MeshInstance3D
@onready var area_3d: Area3D = $Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for body in area_3d.get_overlapping_bodies():
		if body.has_method("teleportPad"):
			body.teleportPad()
