extends Control

const GRID_SIZE := 4
const CELL_SIZE := 72
const SWIPE_THRESHOLD := 28.0
const MOVE_RULES := [
	"Swipe Up: move piece up",
	"Swipe Down: move piece down",
	"Swipe Left: move piece left",
	"Swipe Right: move piece right",
]

var board: GridContainer
var status_label: Label
var info_label: Label
var lie_state_label: Label
var restart_button: Button
var piece_cells: Array[ColorRect] = []
var player_pos := Vector2i.ZERO
var goal_pos := Vector2i(GRID_SIZE - 1, GRID_SIZE - 1)
var lie_rule_index := 0
var lie_type_name := "Horizontal inversion"
var move_log: PackedStringArray = []
var moves := 0
var lie_caught := false
var puzzle_complete := false
var start_drag := Vector2.ZERO
var drag_active := false
var glitch_flash := 0


func _ready() -> void:
	randomize()
	board = $Board
	status_label = $Status
	info_label = $Info
	lie_state_label = $LieState
	restart_button = $RestartButton
	restart_button.pressed.connect(_restart_puzzle)
	_setup_board()
	_new_puzzle()
	_refresh_ui()


func _setup_board() -> void:
	for child in board.get_children():
		child.queue_free()
	piece_cells.clear()

	board.columns = GRID_SIZE
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var cell := ColorRect.new()
			cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.color = Color(0.12, 0.13, 0.16)
			cell.add_theme_constant_override("margin_left", 4)
			cell.add_theme_constant_override("margin_top", 4)
			cell.add_theme_constant_override("margin_right", 4)
			cell.add_theme_constant_override("margin_bottom", 4)
			board.add_child(cell)
			piece_cells.append(cell)


func _new_puzzle() -> void:
	player_pos = Vector2i(0, 0)
	goal_pos = Vector2i(GRID_SIZE - 1, GRID_SIZE - 1)
	lie_rule_index = randi() % MOVE_RULES.size()
	moves = 0
	lie_caught = false
	puzzle_complete = false
	glitch_flash = 0
	move_log = []
	info_label.text = "Probe the board. One rule lies."


func _unhandled_input(event: InputEvent) -> void:
	if puzzle_complete:
		if event is InputEventScreenTouch and event.pressed:
			_restart_puzzle()
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_restart_puzzle()
			return
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			start_drag = event.position
			drag_active = true
		elif drag_active:
			_handle_release(event.position)
	elif event is InputEventScreenDrag:
		if drag_active and start_drag.distance_to(event.position) >= SWIPE_THRESHOLD:
			_handle_swipe(start_drag, event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag = event.position
				drag_active = true
			elif drag_active:
				_handle_release(event.position)
	elif event is InputEventMouseMotion and drag_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if start_drag.distance_to(event.position) >= SWIPE_THRESHOLD:
			_handle_swipe(start_drag, event.position)


func _handle_release(end_pos: Vector2) -> void:
	if start_drag.distance_to(end_pos) < SWIPE_THRESHOLD:
		drag_active = false
		return
	_handle_swipe(start_drag, end_pos)


func _handle_swipe(from_pos: Vector2, to_pos: Vector2) -> void:
	if not drag_active:
		return
	drag_active = false

	var delta := to_pos - from_pos
	var direction := _swipe_direction(delta)
	if direction == Vector2i.ZERO:
		return

	moves += 1
	var moved := _apply_rule(direction)
	var direction_name := _direction_name(direction)
	if moved:
		move_log.push_back("%s -> %s" % [direction_name, player_pos])
		if move_log.size() > 3:
			move_log.pop_front()
		lie_caught = lie_caught or direction_index(direction) == lie_rule_index
		if player_pos == goal_pos:
			_finish_puzzle()
	else:
		move_log.push_back("%s -> blocked" % direction_name)
		if move_log.size() > 3:
			move_log.pop_front()
		info_label.text = "No move happened. That itself is a clue."

	_refresh_ui()


func _swipe_direction(delta: Vector2) -> Vector2i:
	if abs(delta.x) > abs(delta.y):
		return Vector2i(sign(delta.x), 0)
	if abs(delta.y) > 0.0:
		return Vector2i(0, sign(delta.y))
	return Vector2i.ZERO


func _apply_rule(direction: Vector2i) -> bool:
	var actual_direction := direction
	if direction_index(direction) == lie_rule_index:
		actual_direction = Vector2i(-direction.x, -direction.y)
		glitch_flash = 2

	var next_pos := player_pos + actual_direction
	if _inside_board(next_pos):
		player_pos = next_pos
		return true
	return false


func _inside_board(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE


func direction_index(direction: Vector2i) -> int:
	if direction == Vector2i(0, -1):
		return 0
	if direction == Vector2i(0, 1):
		return 1
	if direction == Vector2i(-1, 0):
		return 2
	return 3


func _direction_name(direction: Vector2i) -> String:
	if direction == Vector2i(0, -1):
		return "Up"
	if direction == Vector2i(0, 1):
		return "Down"
	if direction == Vector2i(-1, 0):
		return "Left"
	return "Right"


func _finish_puzzle() -> void:
	puzzle_complete = true
	var caught_text := "You caught the lie." if lie_caught else "You solved it without proving the lie."
	status_label.text = "%s Moves: %d | Lie: %s" % [caught_text, moves, lie_type_name]
	info_label.text = "Tap Restart or tap anywhere to restart."
	lie_state_label.text = "Lie revealed: %s" % MOVE_RULES[lie_rule_index]


func _refresh_ui() -> void:
	info_label.text = "Rules:\n%s\n\nCatch the lie while solving the grid." % _rules_text()
	status_label.text = "Moves: %d | Lie caught: %s | Goal: %s" % [
		moves,
		"yes" if lie_caught else "no",
		"%d,%d" % [goal_pos.x + 1, goal_pos.y + 1]
	]
	var log_text := "Recent: " + (", ".join(move_log) if move_log.size() > 0 else "none yet")
	lie_state_label.text = puzzle_complete ? "Lie revealed: %s" % MOVE_RULES[lie_rule_index] : "Lie hidden: observe board behavior to expose it."
	info_label.text += "\n\n%s" % log_text
	_draw_board()


func _rules_text() -> String:
	var lines: PackedStringArray = []
	for i in range(MOVE_RULES.size()):
		var line := MOVE_RULES[i]
		if i == lie_rule_index:
			line = "%s (this one lies)" % line
		lines.append(line)
	return "\n".join(lines)


func _draw_board() -> void:
	for i in range(piece_cells.size()):
		var cell := piece_cells[i]
		var x := i % GRID_SIZE
		var y := i / GRID_SIZE
		var pos := Vector2i(x, y)
		var color := Color(0.12, 0.13, 0.16)
		if pos == goal_pos:
			color = Color(0.20, 0.28, 0.45)
		if pos == player_pos:
			color = glitch_flash > 0 ? Color(0.95, 0.55, 0.20) : Color(0.65, 0.86, 0.98)
		cell.color = color

	if glitch_flash > 0:
		glitch_flash -= 1


func _process(_delta: float) -> void:
	if puzzle_complete and Input.is_action_just_pressed("ui_accept"):
		_restart_puzzle()


func _restart_puzzle() -> void:
	_new_puzzle()
	_refresh_ui()
