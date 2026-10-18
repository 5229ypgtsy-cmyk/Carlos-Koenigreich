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
 print("PASS: selection, save/load, druid cooldown, daily autosave, invalid save, iPad viewports")
 quit(0)
