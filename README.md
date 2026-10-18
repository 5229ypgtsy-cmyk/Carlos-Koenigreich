# Carlos’ Königreich 0.7.1

Phase 1, ausgehend vom unveränderten Funktionsbestand 0.6.1.

## Start
Godot 4.3: project.godot importieren und starten. Web: erfolgreicher GitHub Actions Lauf veröffentlicht über Pages, sofern der Kontotarif Pages für das private Repository zulässt. Unter Settings → Pages muss GitHub Actions als Quelle aktiv sein. Das Spiel wird durch Veröffentlichung öffentlich erreichbar.

## Bedienung
Querformat. Tippen zum Auswählen, Bewegen und Angreifen. Wischen verschiebt die Karte, zwei Finger zoomen. Maus: Pfeiltasten oder mittlere Maustaste verschieben, Mausrad zoomt. Bauen & Aktionen öffnet das Menü. Abbrechen, ESC oder Rechtsklick beendet den Baumodus. Einheiten lassen sich auch im Baumodus auswählen.

## Spielstände
Speichern und Laden im Aktionsmenü. Automatisches Speichern nach jedem Tag. Speicherformat 7, Version 6 bleibt lesbar. Safari speichert unter derselben Webadresse im Browserprofil. Privatmodus, Löschen von Websitedaten oder Speicherbereinigung können Spielstände entfernen. Der Home-Bildschirm ersetzt keine Sicherung. Druiden-Heilung pro Tag wird mitgespeichert.

## Qualität
Actions importiert das Projekt, führt Regressionstests aus und erstellt einen Webexport ohne Threads. Veröffentlichung hängt vom erfolgreichen Test- und Exportjob ab. Viewport-Tests prüfen den Programmablauf bei drei iPad-Größen; echte Safari-Gesten und visuelle Qualität benötigen zusätzlich einen Gerätetest.

## Noch offen
Phase 2 und 3: größere Welt, Gelände, Nebel, Gegnerwirtschaft, Ritter, platzierbare zusätzliche Gebäude, Hotseat, Siegbedingungen und Balancing. Der aktuelle Stand ist weiterhin ein kompakter Einzelspieler-Prototyp.

## Erster Veröffentlichungsversuch
Tests und Webexport auf GitHub erfolgreich. Pages-Erstaktivierung scheiterte mit `Resource not accessible by integration`. Einmalig unter Repository Settings → Pages die Quelle GitHub Actions aktivieren und den fehlgeschlagenen Deployjob erneut ausführen. Sichtbarkeit des Repositorys bleibt unverändert.
