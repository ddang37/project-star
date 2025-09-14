class_name RangedWeapon extends Node3D

@export var speed:= 10
@export var weaponLifetime := 3.0

var direction := Vector3.ZERO

@onready var timer: Timer = $Timer
@onready var hitbox: Hitbox = $Hitbox
@onready var impact_detector: Hitbox = $ImpactDetector
