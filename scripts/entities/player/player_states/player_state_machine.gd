class_name PlayerStateMachine extends StateMachine

'''
PlayerStateMachine Class enforces PlayerStates for all states in the machine.
It also enforces that each state conforms to the valid PlayerStates across all characters.

Some states like attacks are character specific and should be named:
	"[player]_[state].gd"
Others that can be applied to any player like movement should be named:
	"player_[state].gd"
'''

signal idle
signal moving
signal charging
signal attacking
signal attacking_charged
signal charging_special
signal attacking_special
signal attacking_charged_special
signal bursting
signal swap_in
signal swap_out

func _ready() -> void:
	for state_node in find_children("*"):
		assert(state_node is PlayerState)
		assert(state_node.name in PlayerState.VALID_STATES)
	super()
	state_changed.connect(func(_state):
		match (_state):
			"Idle":
				idle.emit()
			"Moving":
				moving.emit()
			"Charging":
				charging.emit()
			"Attacking":
				attacking.emit()
			"AttackingCharged":
				attacking_charged.emit()
			"ChargingSpecial":
				charging_special.emit()
			"AttackingSpecial":
				attacking_special.emit()
			"AttackingChargedSpecial":
				attacking_charged_special.emit()
			"Bursting":
				bursting.emit()
			"SwapIn":
				swap_in.emit()
			"SwapOut":
				swap_out.emit()
		)
