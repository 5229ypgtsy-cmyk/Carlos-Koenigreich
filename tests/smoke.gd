extends SceneTree

func _initialize() -> void:
 call_deferred("run")

func run() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.mode = "trap"
 game._cancel_mode()
 assert(game.mode == "")
 game.gold = 500
 game.druid_healed_turn = game.turn
 game._save_game()
 game.gold = 1
 game._load_game()
 assert(game.gold == 500)
 assert(game.druid_healed_turn == game.turn)
 var before = game.turn
 game._next_day()
 assert(game.turn == before + 1)
 game._load_game()
 assert(game.turn == before + 1)
 assert(not game._valid_save({"version":7}))
 for viewport in [Vector2i(1024,768), Vector2i(1180,820), Vector2i(1366,1024)]:
  root.size = viewport
  await process_frame
  assert(game.controls.get_child_count() == 17)
 # Real touch events, with no mouse button events for map actions.
 game.camera_offset = Vector2.ZERO
 game.zoom = 1.0
 game.battle_ticks = 0
 game.mode = ""
 var unit_point: Vector2 = game._iso(game.soldiers[0])
 finger(game,0,unit_point,true)
 finger(game,0,unit_point,false)
 assert(game.selected == 0)
 game.mode = "trap"
 finger(game,0,unit_point,true)
 finger(game,0,unit_point,false)
 assert(game.mode == "" and game.selected == 0)
 var old_units = game.soldiers.duplicate()
 var offset: Vector2 = game.camera_offset
 finger(game,0,Vector2(800,400),true)
 var drag := InputEventScreenDrag.new()
 drag.index = 0
 drag.position = Vector2(850,430)
 drag.relative = Vector2(50,30)
 game._input(drag)
 finger(game,0,drag.position,false)
 assert(game.camera_offset == offset + Vector2(50,30))
 assert(game.soldiers == old_units)
 var old_zoom: float = game.zoom
 finger(game,0,Vector2(800,400),true)
 finger(game,1,Vector2(900,400),true)
 drag.index = 1
 drag.position = Vector2(950,400)
 game._input(drag)
 finger(game,0,Vector2(800,400),false)
 finger(game,1,Vector2(950,400),false)
 assert(game.zoom > old_zoom)
 game.controls.visible = true
 await process_frame
 var before_touches: int = game.touches.size()
 finger(game,0,game.controls.global_position+Vector2(10,10),true)
 assert(game.touches.size() == before_touches)
 assert(ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
 game.controls.visible = false
 game.menu_open = false
 root.size = Vector2i(1100,760)
 await process_frame
 # Feed touch events through the engine, so this tests actual Button activation.
 for down in [true,false]:
  var tap := InputEventScreenTouch.new()
  tap.position = game.menu_button.get_global_rect().get_center()
  tap.pressed = down
  Input.parse_input_event(tap)
  await process_frame
 assert(game.menu_open and game.controls.visible)

 print("PASS: touch select, cancel build, swipe without action, pinch, UI isolation, button touch setting")
 print("PASS: selection, save/load, druid cooldown, daily autosave, invalid save, iPad viewports")
 quit(0)

func finger(game, index: int, point: Vector2, down: bool) -> void:
 var event := InputEventScreenTouch.new()
 event.index = index
 event.position = point
 event.pressed = down
 game._input(event)
