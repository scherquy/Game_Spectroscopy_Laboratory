extends GameObject

class_name ContainerMagico

@export var posicao_de_criacao:Marker3D
var objetos:Dictionary = {"silicio":load("res://scene/Objetos/silicio.tscn"),"fotoresist":load("res://scene/Objetos/fotoresist.tscn")}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func criar(nome:String):
	if objetos.has(nome) && posicao_de_criacao.get_children().size()==0:
		var new_object = objetos[nome].instantiate()
		posicao_de_criacao.add_child(new_object)
	else:
		print("não criei")
