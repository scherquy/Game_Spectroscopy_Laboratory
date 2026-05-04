extends Node

class_name Action

@export var nome_da_acao:String
@export var objeto_alvo:GameObject
@export var animador:AnimationPlayer
@export var nome_da_animacao:String
@export var acao_em_cadeia:Action
@export var mudar_acao_do_objeto_para:Action
@export var apagar_nos:Array[Node3D]
@export var one_shot:bool = false
@export var usar_com:String #nome do objeto a ser usado aqui

func _ready():
	if animador is AnimationPlayer:
		animador.animation_finished.connect(_resolver_objeto)

func executar_acao():
	if usar_com.length()>0:
		pass
	else:
		_resolver_animacao()

func _resolver_animacao():
	if animador is AnimationPlayer:
		if !animador.is_playing():
			animador.play(nome_da_animacao)

func _resolver_objeto(animacao:String):
	if !one_shot:
		if mudar_acao_do_objeto_para is Action && animacao==nome_da_animacao:
			objeto_alvo.acao=mudar_acao_do_objeto_para
#			print("acao mudada para",mudar_acao_do_objeto_para.nome_da_acao)
