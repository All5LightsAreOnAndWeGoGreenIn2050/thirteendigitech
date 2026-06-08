extends CharacterBody2D


@export var move_speed: float = 200.0
@export var arrow_cooldown: float = 1.0
@export var arrow = preload("res://scenes/arrow.tscn")
@export var arrow_speed: float = 900.0

@onready var aim_guide: Node2D = %PlayerAimGuide
@onready var cooldown_timer : Timer = %Timer
@onready var bow_turn: Node2D =  %BowTurn

var can_fire: bool = true
var current_target: Node2D = null
