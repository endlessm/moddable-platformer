extends Node
## Registry of action names for each player
##
## This game has actions preconfigured for two players. The [class Player] scene can be configured
## to respond to inputs for player one or two, or for both players.
## [br][br]
## Use [member lookup] to find the full action name for a given player and action.

const _PLAYER_ACTIONS = {
	Global.Player.ONE:
	{
		"jump": &"player_1_jump",
		"left": &"player_1_left",
		"right": &"player_1_right",
	},
	Global.Player.TWO:
	{
		"jump": &"player_2_jump",
		"left": &"player_2_left",
		"right": &"player_2_right",
	},
	Global.Player.BOTH:
	{
		"jump": &"player_both_jump",
		"left": &"player_both_left",
		"right": &"player_both_right",
	},
}


func _ready() -> void:
	_setup_both_actions()


# Sets up the "both" actions, bound to the corresponding events from both players one and two.
# This is done dynamically so that we don't have to keep them in sync in the project settings.
func _setup_both_actions() -> void:
	for action: String in _PLAYER_ACTIONS[Global.Player.BOTH]:
		var p1: StringName = _PLAYER_ACTIONS[Global.Player.ONE][action]
		var p2: StringName = _PLAYER_ACTIONS[Global.Player.TWO][action]
		var both: StringName = _PLAYER_ACTIONS[Global.Player.BOTH][action]

		var deadzone := maxf(InputMap.action_get_deadzone(p1), InputMap.action_get_deadzone(p2))
		InputMap.add_action(both, deadzone)

		for event: InputEvent in InputMap.action_get_events(p1) + InputMap.action_get_events(p2):
			InputMap.action_add_event(both, event)


## Looks up the full action name for [param player] and [param action].
## [br][br]
## For example, [code]Actions.lookup(Global.Player.TWO, "jump")[/code] returns
## [code]"player_2_jump"[/code].
func lookup(player: Global.Player, action: StringName) -> StringName:
	return _PLAYER_ACTIONS[player][action]
