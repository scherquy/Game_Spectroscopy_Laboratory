extends StaticBody3D

class_name GameObject

@export var nome:String
@export_multiline var descricao:String
@export var figura:Texture2D
@export var acao:Action
@export var pegavel:bool = false

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
