extends Control

const W := 20
const H := 16
const TW := 78.0
const TH := 40.0
var camera_offset := Vector2(0, 0)
var zoom := 1.0
const ORIGIN := Vector2(530, 165)
const HOME := Vector2i(3, 4)
const FORT := Vector2i(6, 3)
const NEIGHBORS := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
var gold := 320
var food := 65
var farmers := 3
var houses := 1
var barracks := false
var academy := false
var fields: Array[Vector2i] = [Vector2i(2,3), Vector2i(3,3)]
var walls: Array[Vector2i] = []
var soldiers: Array[Vector2i] = [Vector2i(5,4),Vector2i(5,5)]
var levels: Array[int] = [1,1]
var soldier_hp: Array[int] = [3,3]
const MAX_SOLDIER_HP := 3
var druid_pos := Vector2i(-1, -1)
var druid_healed_turn := -1
var hospital := false
var traps: Array[Vector2i] = []
var battle_notice := ""
var battle_ticks := 0
var types: Array[int] = [0,0] # 0 Rekrut, 1 Nahkampf, 2 Fernkampf
var enemies: Array[Vector2i] = [Vector2i(8,4),Vector2i(8,5)]
var enemy_hp: Array[int] = [2,2]
var selected := -1
var mode := ""
var turn := 1
var message := "Wähle einen Soldaten. Gebäude und Mauern kannst du unten bauen."
var hud: Label
var info: Label
var help: Label
var action_help: Label
var controls: GridContainer
var menu_open := false
var touches := {}
var touch_start := Vector2.ZERO
var touch_dragged := false
var menu_button: Button
var cancel_button: Button
var rng := RandomNumberGenerator.new()

func _ready() -> void:
 rng.randomize()
 mouse_filter = Control.MOUSE_FILTER_PASS
 hud = Label.new()
 hud.position = Vector2(20, 12)
 hud.add_theme_font_size_override("font_size", 23)
 hud.add_theme_color_override("font_color", Color("253d2d"))
 add_child(hud)
 info = Label.new()
 info.position = Vector2(20, 49)
 info.size = Vector2(1050, 72)
 info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 info.add_theme_font_size_override("font_size", 16)
 info.add_theme_color_override("font_color", Color("293c2b"))
 add_child(info)
 action_help = Label.new()
 action_help.position = Vector2(20, 548)
 action_help.size = Vector2(1060, 35)
 action_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 action_help.add_theme_font_size_override("font_size", 15)
 action_help.add_theme_color_override("font_color", Color("234b67"))
 add_child(action_help)
 help = Label.new()
 help.position = Vector2(20, 578)
 help.size = Vector2(1060, 38)
 help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 help.add_theme_font_size_override("font_size", 15)
 help.add_theme_color_override("font_color", Color("273d30"))
 add_child(help)
 controls = GridContainer.new()
 controls.columns = 3
 controls.position = Vector2(14, 220)
 controls.add_theme_constant_override("h_separation", 7)
 controls.add_theme_constant_override("v_separation", 5)
 add_child(controls)
 _button("🌾 Feld (60 G)", _buy_field, "Feld: 60 Gold. Bis zu 2 Bauern arbeiten darauf. Jeder arbeitet für 6 Essen pro Tag vor Wetter.")
 _button("👨 Bauer (30 G)", _buy_farmer, "Bauer: 30 Gold. Braucht einen freien Hausplatz und täglich 1 Essen. Arbeitet auf Feldern.")
 _button("🏠 Haus (90 G)", _buy_house, "Haus: 90 Gold. Schafft 4 zusätzliche Wohnplätze für Bauern.")
 _button("🏯 Kaserne (130 G)", _buy_barracks, "Kaserne: 130 Gold, einmalig. Danach wird 1 Bauer für 40 Gold zu 1 Soldaten.")
 _button("⚔ Bauer → Soldat", _recruit, "Rekrutierung: Kaserne + 1 Bauer + 40 Gold. Der Bauer fehlt danach bei der Ernte.")
 _button("🎯 Training (110 G)", _buy_academy, "Trainingsstation: 110 Gold, einmalig. Ermöglicht Levelaufstieg und Spezialisierung.")
 _button("⭐ Aufwerten", _upgrade, "Aufwerten: Soldat auswählen. Kosten: aktuelles Level × 25 Gold. Maximal Level 5.")
 _button("🏹 Spezialisieren", _specialize, "Spezialisieren: 60 Gold. Rekrut wird zufällig Schwertkämpfer oder Bogenschütze.")
 _button("🧱 Mauer (35 G)", _wall_mode, "Mauer: 35 Gold. Danach freies Feld anklicken. Blockiert Feinde und eigene Truppen.")
 _button("⏭ Nächster Tag", _next_day, "Nächster Tag: Ernte, Verbrauch, Steuern und Gegnerbewegung ausführen.")
 _button("❤️ Lazarett (120 G)", _hospital, "Einmalig 120 Gold. Verwundeten ausgewählten Soldaten am Heimatort für 12 Nahrung heilen.")
 _button("🧙 Druide (100 G)", _hire_druid, "100 Gold. Beweglicher Heiler. Druiden anklicken, dann freies Nachbarfeld; Heilung per Schaltfläche.")
 _button("✨ Heilen (8 Essen)", _druid_heal, "Druide heilt einen benachbarten verletzten Soldaten um 1 LP. Einmal je Tag, 8 Nahrung.")
 _button("🪤 Falle (35 G)", _trap_mode, "35 Gold. Danach Feld anklicken. Feinde verlieren beim Betreten 2 Lebenspunkte.")
 _button("🏥 Lazarett-Heilung", _hospital_heal, "Heilt ausgewählten verletzten Soldaten am Dorf (12 Nahrung, 1 LP).")
 _button("💾 Speichern", _save_game, "Speichert den Spielstand lokal in diesem Browser oder auf diesem Gerät.")
 _button("📂 Laden", _load_game, "Lädt den zuletzt gespeicherten Spielstand.")
 controls.visible = false
 menu_button = Button.new()
 menu_button.text = "Bauen & Aktionen"
 menu_button.position = Vector2(16, 690)
 menu_button.custom_minimum_size = Vector2(250, 54)
 menu_button.pressed.connect(func() -> void: menu_open = not menu_open; controls.visible = menu_open)
 add_child(menu_button)
 cancel_button = Button.new()
 cancel_button.text = "Abbrechen"
 cancel_button.position = Vector2(280, 690)
 cancel_button.custom_minimum_size = Vector2(170, 54)
 cancel_button.pressed.connect(_cancel_mode)
 add_child(cancel_button)
 var day_button := Button.new()
 day_button.text = "Nächster Tag"
 day_button.position = Vector2(850, 690)
 day_button.custom_minimum_size = Vector2(234, 54)
 day_button.pressed.connect(_next_day)
 add_child(day_button)
 help.visible = false
 info.position.y = 52
 info.size.y = 90
 action_help.position.y = 638
 action_help.size.y = 46
 _refresh()

func _button(caption: String, action: Callable, explanation: String) -> void:
 var b := Button.new()
 b.text = caption
 b.custom_minimum_size = Vector2(214, 58)
 b.add_theme_font_size_override("font_size", 14)
 b.tooltip_text = explanation
 b.mouse_entered.connect(func() -> void: action_help.text = "ℹ " + explanation)
 b.focus_entered.connect(func() -> void: action_help.text = "ℹ " + explanation)
 b.pressed.connect(func() -> void:
  action_help.text = explanation
  menu_open = false
  controls.visible = false
  action.call())
 controls.add_child(b)

func _refresh() -> void:
 hud.text = "🏰 CARLOS' KÖNIGREICH   |   Tag %d   |   💰 %d G   |   🌾 %d Essen   |   ⚔ %d Soldaten" % [turn,gold,food,soldiers.size()]
 info.text = ("BAUMODUS: %s | ESC / Rechtsklick: Abbrechen\n" % ("Falle" if mode=="trap" else "Mauer" if mode=="wall" else "Druide bewegen") if mode!="" else "") + message + "\nBauern: %d/%d Plätze   Felder: %d   Feinde: %d   |   Kaserne: %s   Training: %s" % [farmers, houses * 4, fields.size(), enemies.size(), "Ja" if barracks else "Nein", "Ja" if academy else "Nein"]
 if action_help.text.is_empty(): action_help.text = "ℹ Zeige mit der Maus auf eine Aktion, um ihre Wirkung und Kosten zu erfahren."
 help.text = "ESC / Rechtsklick: Aktion abbrechen. Erneuter Klick auf Falle/Mauer: abwählen.\n🗺 Pfeiltasten: Karte verschieben. Mausrad: Zoom. 🧙 Druide anklicken, dann bewegen. ✨ heilt benachbarte Soldaten.\n🌾 1 Bauer arbeitet auf 1 Feld (max. 2/Feld), 6 Essen/Tag ± Wetter. Verbrauch: 1/Bauer, 2/Soldat. Haus: 4 Plätze."
 queue_redraw()

func _iso(p: Vector2i) -> Vector2:
 return ORIGIN + camera_offset + Vector2((p.x-p.y)*TW*0.5,(p.x+p.y)*TH*0.5) * zoom

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color("e7e1cb"))
 for y in range(H):
  for x in range(W):
   var p := Vector2i(x,y)
   var c := _iso(p)
   if c.x < -70 or c.x > size.x+70 or c.y < 150 or c.y > 620: continue
   var color := Color("83a968") if (x+y)%2==0 else Color("94b875")
   if fields.has(p): color = Color("d8b66c")
   var poly := PackedVector2Array([c+Vector2(0,-TH*zoom/2),c+Vector2(TW*zoom/2,0),c+Vector2(0,TH*zoom/2),c+Vector2(-TW*zoom/2,0)])
   draw_colored_polygon(poly,color)
   draw_polyline(PackedVector2Array([poly[0],poly[1],poly[2],poly[3],poly[0]]),Color("658450"),1.2)
   if fields.has(p):
    for j in range(3):
     draw_line(c+Vector2(-19+j*13,2),c+Vector2(-19+j*13,-11),Color("477b35"),3)
     draw_circle(c+Vector2(-19+j*13,-12),4,Color("d6d04e"))
   if traps.has(p):
    draw_circle(c, 7, Color("6c4630"))
    draw_line(c+Vector2(-8,0), c+Vector2(8,0), Color("f2c15b"), 2)
   if walls.has(p):
    draw_rect(Rect2(c+Vector2(-23,-29),Vector2(46,22)),Color("727d83"))
    for j in range(3): draw_rect(Rect2(c+Vector2(-23+j*16,-36),Vector2(12,9)),Color("929ca0"))
   if p==HOME:
    draw_rect(Rect2(c+Vector2(-21,-35),Vector2(42,34)),Color("a65e3d"))
    draw_colored_polygon(PackedVector2Array([c+Vector2(-29,-35),c+Vector2(0,-57),c+Vector2(29,-35)]),Color("724533"))
    draw_rect(Rect2(c+Vector2(-5,-18),Vector2(10,17)),Color("3c3429"))
   if p==FORT:
    draw_rect(Rect2(c+Vector2(-23,-44),Vector2(46,42)),Color("89919a"))
    draw_rect(Rect2(c+Vector2(-29,-61),Vector2(15,37)),Color("697682"))
    draw_rect(Rect2(c+Vector2(14,-61),Vector2(15,37)),Color("697682"))
    if barracks: draw_rect(Rect2(c+Vector2(-11,-43),Vector2(22,13)),Color("ad643b"))
    if academy: draw_circle(c+Vector2(0,-69),7,Color("e8c64b"))
 if hospital:
  var hc := _iso(HOME)+Vector2(37,-38)
  draw_rect(Rect2(hc,Vector2(26,28)),Color("f0e8db"))
  draw_line(hc+Vector2(13,5),hc+Vector2(13,23),Color("c64242"),4)
  draw_line(hc+Vector2(5,14),hc+Vector2(21,14),Color("c64242"),4)
 if druid_pos.x >= 0:
  var dc := _iso(druid_pos)+Vector2(0,-15)
  draw_circle(dc,13,Color("49815b"))
  draw_circle(dc+Vector2(0,-11),7,Color("f1d3b0"))
  draw_line(dc+Vector2(13,4),dc+Vector2(15,-22),Color("a8864c"),3)
  draw_circle(dc+Vector2(15,-23),5,Color("87db93"))
  draw_string(ThemeDB.fallback_font,dc+Vector2(-16,-27),"DRUID",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
 for i in range(soldiers.size()):
  var c := _iso(soldiers[i])+Vector2(0,-15)
  draw_circle(c,12,Color("2466ba"))
  draw_circle(c+Vector2(0,-10),7,Color("f3d6ae"))
  if types[i]==2:
   draw_arc(c+Vector2(13,-8),10,-PI/2,PI/2,12,Color("e5c47c"),3)
  else:
   draw_line(c+Vector2(9,1),c+Vector2(19,-19),Color("dddddd"),3)
  draw_string(ThemeDB.fallback_font,c+Vector2(-9,-24),"L%d" % levels[i],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
  _health_bar(c + Vector2(0, 15), soldier_hp[i], MAX_SOLDIER_HP, Color("368a4c"))
  if selected==i: draw_arc(c,18,0,TAU,32,Color("ffea54"),3)
 for i in range(enemies.size()):
  var c := _iso(enemies[i])+Vector2(0,-15)
  draw_circle(c,12,Color("b73939"))
  draw_circle(c+Vector2(0,-10),7,Color("f3d6ae"))
  draw_line(c+Vector2(-9,1),c+Vector2(-19,-19),Color("dddddd"),3)
  _health_bar(c + Vector2(0, 15), enemy_hp[i], 3, Color("bd4b45"))

 _draw_battle_notice()

func _health_bar(center: Vector2, hp: int, max_hp: int, tint: Color) -> void:
 var frame := Rect2(center + Vector2(-18, 0), Vector2(36, 6))
 draw_rect(frame, Color("313b37"))
 draw_rect(Rect2(frame.position + Vector2(1, 1), Vector2(34.0 * clampf(float(hp) / float(max_hp), 0.0, 1.0), 4)), tint)

func _draw_battle_notice() -> void:
 if battle_ticks <= 0: return
 var panel := Rect2(Vector2(325, 260), Vector2(450, 145))
 draw_rect(panel, Color("f9f2db"))
 draw_rect(panel, Color("574a36"), false, 3)
 draw_string(ThemeDB.fallback_font, Vector2(350, 293), "⚔ WÜRFELKAMPF", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("273d30"))
 var lines := battle_notice.split("\n")
 for i in range(mini(lines.size(), 3)):
  draw_string(ThemeDB.fallback_font, Vector2(350, 326 + i * 28), lines[i], HORIZONTAL_ALIGNMENT_LEFT, 400, 18, Color("273d30"))

func _valid(p: Vector2i) -> bool:
 return p.x>=0 and p.x<W and p.y>=0 and p.y<H

func _blocked(p: Vector2i) -> bool:
 return fields.has(p) or walls.has(p) or p==druid_pos or soldiers.has(p) or enemies.has(p) or p==HOME or p==FORT

func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode == KEY_ESCAPE:
   _cancel_mode()
   return
  var delta := Vector2.ZERO
  if event.keycode == KEY_LEFT: delta.x = 75
  if event.keycode == KEY_RIGHT: delta.x = -75
  if event.keycode == KEY_UP: delta.y = 60
  if event.keycode == KEY_DOWN: delta.y = -60
  if delta != Vector2.ZERO:
   camera_offset += delta
   queue_redraw()
 if event is InputEventMouseButton and event.pressed:
  if event.button_index == MOUSE_BUTTON_RIGHT:
   _cancel_mode()
   return
  if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom = minf(1.6, zoom + 0.1); queue_redraw()
  if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom = maxf(0.55, zoom - 0.1); queue_redraw()

func _cancel_mode() -> void:
 mode = ""
 selected = -1
 message = "Auswahl aufgehoben. Du kannst wieder Soldaten auswählen."
 _refresh()
 queue_redraw()

func _gui_input(event: InputEvent) -> void:
 if event is InputEventScreenTouch:
  if event.pressed:
   touches[event.index] = event.position
   if touches.size() == 1:
    touch_start = event.position
    touch_dragged = false
   else:
    touch_dragged = true
  else:
   touches.erase(event.index)
   if touches.is_empty() and not touch_dragged:
    _map_click(event.position)
  accept_event()
  return
 if event is InputEventScreenDrag:
  if touches.size() >= 2:
   var keys: Array = touches.keys()
   var old_distance: float = touches[keys[0]].distance_to(touches[keys[1]])
   touches[event.index] = event.position
   var new_distance: float = touches[keys[0]].distance_to(touches[keys[1]])
   if old_distance > 1.0: zoom = clampf(zoom * new_distance / old_distance, 0.55, 1.6)
   touch_dragged = true
  elif touches.has(event.index):
   if event.position.distance_to(touch_start) > 12.0: touch_dragged = true
   if touch_dragged: camera_offset += event.relative
   touches[event.index] = event.position
  queue_redraw()
  accept_event()
  return
 if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
  camera_offset += event.relative
  queue_redraw()
  return
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  _map_click(event.position)

func _map_click(click: Vector2) -> void:
 if click.y < 145 or click.y > 630: return
 if battle_ticks > 0:
  battle_ticks = 0
  queue_redraw()
  return
 var target := Vector2i(-1,-1)
 var closest := 99999.0
 for y in range(H):
  for x in range(W):
   var p := Vector2i(x,y)
   var c := _iso(p)
   var d: float = abs(click.x-c.x)/(TW*zoom/2)+abs(click.y-c.y)/(TH*zoom/2)
   if d<closest:
    closest=d
    target=p
 if closest>1.0: return
 # Eigene Einheiten lassen sich auch bei aktivem Baumodus direkt auswählen.
 var clicked_soldier := soldiers.find(target)
 if clicked_soldier != -1 and mode != "":
  mode = ""
  selected = clicked_soldier
  message = "Soldat %d ausgewählt. Klicke auf ein benachbartes Feld." % (clicked_soldier + 1)
  _refresh()
  queue_redraw()
  return
 if target == druid_pos and mode != "":
  mode = "druid_move"
  selected = -1
  message = "Druide ausgewählt. Klicke auf ein benachbartes Feld."
  _refresh()
  queue_redraw()
  return
 if mode=="trap":
  if _blocked(target) or traps.has(target): message="Dort passt keine Falle hin."
  elif gold<35: message="Du brauchst 35 Gold."
  else:
   traps.append(target)
   gold-=35
   message="Falle versteckt! Feinde verlieren 2 LP."
   mode=""
  _refresh()
  return
 if mode=="druid_move":
  if abs(target.x-druid_pos.x)+abs(target.y-druid_pos.y)!=1: message="Druide bewegt sich 1 Feld pro Aktion."
  elif _blocked(target): message="Dieses Feld ist besetzt."
  else:
   druid_pos=target
   message="Druide bewegt. Wähle ✨ Heilen bei einem verletzten Nachbarn."
   mode=""
  _refresh()
  return
 if mode=="wall":
  if _blocked(target): message="Dort kannst du keine Mauer bauen."
  elif gold<35: message="Du brauchst 35 Gold."
  else:
   walls.append(target)
   gold-=35
   message="Mauer gebaut! Sie blockiert Gegner und eigene Soldaten."
   mode=""
  _refresh()
  return
 if target==druid_pos:
  selected=-1
  mode="druid_move"
  message="Druide ausgewählt. Klicke ein benachbartes freies Feld oder nutze ✨ Heilen."
  _refresh()
  return
 var idx := soldiers.find(target)
 if idx!=-1:
  selected=idx
  message="Soldat %d: %s, Level %d, Leben %d/%d. Wähle ein Zielfeld oder trainiere." % [idx+1,_type_name(types[idx]),levels[idx],soldier_hp[idx],MAX_SOLDIER_HP]
 elif selected!=-1:
  var old := soldiers[selected]
  var distance: int = abs(old.x-target.x)+abs(old.y-target.y)
  var enemy_idx := enemies.find(target)
  var attack_range := 2 if types[selected]==2 else 1
  if enemy_idx!=-1 and distance<=attack_range:
   _combat(selected,enemy_idx)
  elif distance!=1:
   message="Bewegen: 1 Feld. Fernkämpfer greifen bis 2 Felder weit an."
  elif _blocked(target):
   message="Dieses Feld ist besetzt."
  else:
   soldiers[selected]=target
   message="Soldat bewegt."
   selected=-1
 _refresh()

func _type_name(t: int) -> String:
 if t==1: return "Schwertkämpfer"
 if t==2: return "Bogenschütze"
 return "Rekrut"

func _combat(s: int,e: int) -> void:
 var attack_roll := rng.randi_range(1, 6)
 var defense_roll := rng.randi_range(1, 6)
 var bonus: int = levels[s] + (2 if types[s] == 1 else 1 if types[s] == 2 else 0)
 var attack := attack_roll + bonus
 var defense := defense_roll + 2
 var outcome := ""
 if attack >= defense:
  enemy_hp[e] -= 1
  outcome = "Treffer! Gegner verliert 1 Leben."
  if enemy_hp[e] <= 0:
   enemies.remove_at(e)
   enemy_hp.remove_at(e)
   gold += 25
   outcome = "Gegner besiegt! +25 Gold."
 else:
  outcome = "Abgewehrt! Dein Soldat verliert 1 Leben."
  soldier_hp[s] -= 1
  if soldier_hp[s] <= 0:
   soldiers.remove_at(s)
   levels.remove_at(s)
   types.remove_at(s)
   soldier_hp.remove_at(s)
   outcome = "Dein Soldat ist gefallen!"
 battle_notice = "Angriff: %d + %d = %d   |   Abwehr: %d + 2 = %d\n%s\nKlicke zum Weiterspielen." % [attack_roll,bonus,attack,defense_roll,defense,outcome]
 battle_ticks = 1
 message = "⚔ " + outcome
 selected = -1

func _buy_field() -> void:
 if gold<60: message="Du brauchst 60 Gold."
 else:
  var spot := Vector2i(-1,-1)
  for y in range(H):
   for x in range(W):
    var p := Vector2i(x,y)
    if not _blocked(p) and (spot.x==-1 or p.distance_squared_to(HOME)<spot.distance_squared_to(HOME)): spot=p
  if spot.x==-1: message="Kein freies Feld vorhanden."
  else:
   fields.append(spot)
   gold-=60
   message="Feld gekauft. Für volle Ernte brauchst du passende Bauern."
 _refresh()

func _buy_farmer() -> void:
 if gold<30: message="Du brauchst 30 Gold."
 elif farmers>=houses*4: message="Baue zuerst ein Haus! Alle Wohnplätze sind belegt."
 else:
  gold-=30
  farmers+=1
  message="Neuer Bauer! Er braucht täglich 1 Essen."
 _refresh()

func _buy_house() -> void:
 if gold<90: message="Du brauchst 90 Gold für ein Haus."
 else:
  gold-=90
  houses+=1
  message="Haus gebaut! Platz für 4 weitere Bauern."
 _refresh()

func _buy_barracks() -> void:
 if barracks: message="Die Kaserne steht bereits."
 elif gold<130: message="Du brauchst 130 Gold."
 else:
  gold-=130
  barracks=true
  message="Kaserne gebaut! Hier kannst du Bauern zu Soldaten machen."
 _refresh()

func _recruit() -> void:
 if not barracks: message="Baue zuerst die Kaserne (130 G)."
 elif farmers<1: message="Du brauchst mindestens einen Bauern."
 elif gold<40: message="Ausbildung kostet 40 Gold."
 else:
  var spawn := Vector2i(-1,-1)
  for y in range(H):
   for x in range(W):
    var p := Vector2i(x,y)
    if not _blocked(p) and p.distance_squared_to(FORT)<=8:
     spawn=p
     break
   if spawn.x!=-1: break
  if spawn.x==-1: message="Kein freier Platz bei der Kaserne."
  else:
   farmers-=1
   gold-=40
   soldiers.append(spawn)
   levels.append(1)
   types.append(0)
   soldier_hp.append(MAX_SOLDIER_HP)
   message="Ein Bauer ist jetzt Soldat. Deine Felder haben einen Arbeiter weniger!"
 _refresh()

func _buy_academy() -> void:
 if not barracks: message="Zuerst brauchst du eine Kaserne."
 elif academy: message="Die Trainingsstation ist schon gebaut."
 elif gold<110: message="Du brauchst 110 Gold."
 else:
  gold-=110
  academy=true
  message="Trainingsstation gebaut! Soldaten können aufsteigen und sich spezialisieren."
 _refresh()

func _upgrade() -> void:
 if not academy: message="Baue zuerst die Trainingsstation."
 elif selected<0: message="Wähle einen blauen Soldaten."
 elif levels[selected]>=5: message="Level 5 ist das Maximum."
 elif gold<levels[selected]*25: message="Zu wenig Gold fürs Training."
 else:
  gold-=levels[selected]*25
  levels[selected]+=1
  message="Soldat auf Level %d! Höheres Level verbessert seine Würfelchance." % levels[selected]
 _refresh()

func _specialize() -> void:
 if not academy: message="Baue zuerst die Trainingsstation."
 elif selected<0: message="Wähle einen blauen Soldaten."
 elif types[selected]!=0: message="Dieser Soldat ist bereits spezialisiert."
 elif gold<60: message="Spezialisierung kostet 60 Gold."
 else:
  gold-=60
  types[selected]=1 if rng.randi_range(0,1)==0 else 2
  message="Spezialisierung: %s! (Zufallsauswahl)" % _type_name(types[selected])
 _refresh()

func _wall_mode() -> void:
 if mode == "wall":
  _cancel_mode()
  return
 if gold<35: message="Eine Mauer kostet 35 Gold."
 else:
  mode="wall"
  selected=-1
  message="Klicke auf ein freies Feld für deine Mauer (35 G)."
 _refresh()

func _enemy_turn() -> void:
 if turn%2==0 and enemies.size()<18:
  for y in [2,4,6,8,10,12,14,1,5,3,7,9]:
   var spawn := Vector2i(16,y)
   if not _blocked(spawn):
    enemies.append(spawn)
    enemy_hp.append(2+rng.randi_range(0,1))
    break
 var next_enemies: Array[Vector2i] = []
 var next_hp: Array[int] = []
 for i in range(enemies.size()):
  var enemy := enemies[i]
  var destination := enemy
  if turn%2==1:
   var steps: Array[Vector2i] = [Vector2i(-1,0),Vector2i(0,-1),Vector2i(0,1)]
   steps.sort_custom(func(a: Vector2i,b: Vector2i) -> bool: return (enemy+a).distance_squared_to(HOME)<(enemy+b).distance_squared_to(HOME))
   for step in steps:
    var candidate := enemy+step
    if _valid(candidate) and not walls.has(candidate) and not soldiers.has(candidate) and not next_enemies.has(candidate) and not enemies.has(candidate) and candidate!=HOME and candidate!=FORT:
     destination=candidate
     break
  if traps.has(destination):
   traps.erase(destination)
   var remaining_hp: int = enemy_hp[i]-2
   if remaining_hp<=0:
    gold+=10
    message+=" Eine Falle besiegt einen Feind!"
    continue
   next_enemies.append(destination)
   next_hp.append(remaining_hp)
   message+=" Ein Feind tritt in eine Falle!"
   continue
  if fields.has(destination):
   food=max(0,food-12)
   message+=" Ein Feind plündert ein Feld: -12 Essen!"
  next_enemies.append(destination)
  next_hp.append(enemy_hp[i])
 enemies=next_enemies
 enemy_hp=next_hp

func _next_day() -> void:
 selected = -1
 mode = ""
 turn+=1
 var workers: int = min(farmers,fields.size()*2)
 var base_harvest: int = workers*6
 var weather: int = rng.randi_range(0,4)
 var harvest: int = base_harvest
 var weather_name := "normal"
 if weather==0:
  harvest=int(round(base_harvest*0.5))
  weather_name="Dürre"
 elif weather==4:
  harvest=int(round(base_harvest*1.5))
  weather_name="reiche Ernte"
 var consumption: int = farmers+soldiers.size()*2
 food+=harvest-consumption
 gold+=12
 message="%s: +%d Essen, Verbrauch: %d. Steuern: +12 G." % [weather_name,harvest,consumption]
 if food<0:
  food=0
  if not soldiers.is_empty():
   soldiers.pop_back()
   levels.pop_back()
   types.pop_back()
   soldier_hp.pop_back()
   selected=-1
   message+=" Hunger! Ein Soldat verlässt das Heer."
 if food>=100 and turn%3==0 and farmers<houses*4:
  food-=30
  farmers+=1
  message+=" Ein Kind wird erwachsen: +1 Bauer (-30 Essen)!"
 elif food>=130:
  food-=30
  gold+=20
  message+=" Nahrung verkauft: +20 G."
 _enemy_turn()
 var day_report := message
 _save_game()
 message = day_report + " " + message
 _refresh()

func _hospital() -> void:
 if hospital: message="Das Lazarett steht bereits."
 elif gold<120: message="Das Lazarett kostet 120 Gold."
 else:
  gold-=120
  hospital=true
  message="Lazarett gebaut. Wähle einen Soldaten am Heimatort, um ihn für 12 Essen zu heilen."
 _refresh()

func _hire_druid() -> void:
 if druid_pos.x>=0: message="Du hast bereits einen Druiden."
 elif gold<100: message="Ein Druide kostet 100 Gold."
 else:
  var spawn := Vector2i(-1,-1)
  for step in NEIGHBORS:
   if _valid(HOME+step) and not _blocked(HOME+step): spawn=HOME+step; break
  if spawn.x<0: message="Kein Platz beim Dorf für den Druiden."
  else:
   gold-=100
   druid_pos=spawn
   message="Druide angekommen. Anklicken und auf Nachbarfeld bewegen."
 _refresh()

func _druid_heal() -> void:
 if druid_pos.x<0: message="Du brauchst zuerst einen Druiden (100 Gold)."
 elif druid_healed_turn==turn: message="Der Druide hat heute bereits geheilt."
 elif food<8: message="Heilung kostet 8 Nahrung."
 else:
  var target := -1
  for i in range(soldiers.size()):
   var dist: int = abs(soldiers[i].x-druid_pos.x)+abs(soldiers[i].y-druid_pos.y)
   if dist<=1 and soldier_hp[i]<MAX_SOLDIER_HP:
    target=i
    break
  if target<0: message="Kein verletzter Soldat direkt neben dem Druiden."
  else:
   soldier_hp[target]+=1
   food-=8
   druid_healed_turn=turn
   message="Druide heilt Soldat %d um 1 Lebenspunkt!" % (target+1)
 _refresh()

func _trap_mode() -> void:
 if mode == "trap":
  _cancel_mode()
  return
 if gold<35: message="Eine Falle kostet 35 Gold."
 else:
  mode="trap"
  selected=-1
  message="Wähle ein freies Feld für die Falle (35 Gold)."
 _refresh()

func _encode_positions(items: Array) -> Array:
 var result := []
 for item in items: result.append([item.x,item.y])
 return result

func _decode_positions(items: Array) -> Array[Vector2i]:
 var result: Array[Vector2i] = []
 for item in items:
  if item is Array and item.size()==2: result.append(Vector2i(int(item[0]),int(item[1])))
 return result

func _save_game() -> void:
 var data := {"version":7,"druid_healed_turn":druid_healed_turn,"camera":[camera_offset.x,camera_offset.y],"zoom":zoom,"gold":gold,"food":food,"farmers":farmers,"houses":houses,"barracks":barracks,"academy":academy,"hospital":hospital,"turn":turn,"fields":_encode_positions(fields),"walls":_encode_positions(walls),"traps":_encode_positions(traps),"soldiers":_encode_positions(soldiers),"levels":levels,"types":types,"soldier_hp":soldier_hp,"enemies":_encode_positions(enemies),"enemy_hp":enemy_hp,"druid": [druid_pos.x,druid_pos.y]}
 var file := FileAccess.open("user://carlos_save.json",FileAccess.WRITE)
 if file==null: message="Speichern fehlgeschlagen."
 else:
  file.store_string(JSON.stringify(data))
  file.flush()
  file.close()
  message="Spielstand gespeichert!"
 _refresh()

func _load_game() -> void:
 if not FileAccess.file_exists("user://carlos_save.json"):
  message="Noch kein Spielstand vorhanden."
  _refresh()
  return
 var file := FileAccess.open("user://carlos_save.json",FileAccess.READ)
 if file==null:
  message="Spielstand konnte nicht geöffnet werden."
  _refresh()
  return
 var data = JSON.parse_string(file.get_as_text())
 file.close()
 if not (data is Dictionary) or int(data.get("version",0)) not in [6,7]:
  message="Ungültiger oder nicht unterstützter Spielstand."
  _refresh()
  return
 if not _valid_save(data):
  message = "Spielstand beschädigt. Dein laufendes Spiel bleibt erhalten."
  _refresh()
  return
 gold=int(data.get("gold",160))
 food=int(data.get("food",65))
 farmers=int(data.get("farmers",3))
 houses=int(data.get("houses",1))
 barracks=bool(data.get("barracks",false))
 academy=bool(data.get("academy",false))
 hospital=bool(data.get("hospital",false))
 turn=int(data.get("turn",1))
 fields=_decode_positions(data.get("fields",[]))
 walls=_decode_positions(data.get("walls",[]))
 traps=_decode_positions(data.get("traps",[]))
 soldiers=_decode_positions(data.get("soldiers",[]))
 enemies=_decode_positions(data.get("enemies",[]))
 levels.clear()
 for v in data.get("levels",[]): levels.append(int(v))
 types.clear()
 for v in data.get("types",[]): types.append(int(v))
 soldier_hp.clear()
 for v in data.get("soldier_hp",[]): soldier_hp.append(int(v))
 enemy_hp.clear()
 for v in data.get("enemy_hp",[]): enemy_hp.append(int(v))
 var d: Array = data.get("druid",[-1,-1])
 druid_pos=Vector2i(int(d[0]),int(d[1]))
 selected=-1
 mode=""
 druid_healed_turn=int(data.get("druid_healed_turn",-1))
 var cam: Array = data.get("camera",[0,0])
 camera_offset = Vector2(float(cam[0]),float(cam[1]))
 zoom = clampf(float(data.get("zoom",1.0)),0.55,1.6)
 message="Spielstand geladen."
 _refresh()

func _hospital_heal() -> void:
 if not hospital: message="Baue zuerst ein Lazarett."
 elif selected<0 or selected>=soldiers.size(): message="Wähle einen verletzten Soldaten."
 elif soldiers[selected].distance_squared_to(HOME)>2: message="Soldat muss direkt am Dorf stehen."
 elif soldier_hp[selected]>=MAX_SOLDIER_HP: message="Soldat ist bereits gesund."
 elif food<12: message="Du brauchst 12 Nahrung."
 else:
  food-=12
  soldier_hp[selected]+=1
  message="Lazarett: Soldat erhält 1 Lebenspunkt."
 _refresh()

func _valid_save(data: Dictionary) -> bool:
 for key in ["gold","food","farmers","houses","turn"]:
  if not data.get(key) is float and not data.get(key) is int: return false
  if float(data[key]) < 0: return false
 for key in ["fields","walls","traps","soldiers","enemies"]:
  if not data.get(key) is Array: return false
  for pos in data[key]:
   if not pos is Array or pos.size() != 2: return false
   if not (pos[0] is float or pos[0] is int) or not (pos[1] is float or pos[1] is int): return false
   if not _valid(Vector2i(int(pos[0]),int(pos[1]))): return false
 for key in ["levels","types","soldier_hp","enemy_hp"]:
  if not data.get(key) is Array: return false
  if data[key].size() != data["enemies" if key == "enemy_hp" else "soldiers"].size(): return false
  for value in data[key]:
   if not (value is float or value is int): return false
   if value < (0 if key == "types" else 1) or value > (2 if key == "types" else 5 if key == "levels" else 3): return false
 var druid = data.get("druid")
 if not druid is Array or druid.size() != 2: return false
 for value in druid:
  if not (value is float or value is int): return false
 var cam = data.get("camera",[0,0])
 if not cam is Array or cam.size() != 2: return false
 for value in cam:
  if not (value is float or value is int): return false
 return true
