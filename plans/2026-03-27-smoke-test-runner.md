# 2026-03-27-smoke-test-runner

Status: awaiting-plan-review
assigned-to: praxis

## Summary

Erweitert die Engine um einen echten GPT-2-Smoke-Test-Runner, der den bereits exportierten `.gpy`-Code kompiliert und im Smoke-Modus ausführt. Der Slice liefert damit den ersten realen Trainings-Sanity-Check aus `VISION.md`, bleibt aber bewusst Engine-only: kein UI-Button, sondern ein strukturierter Runner, den spätere SwiftUI-Flows nur noch ansteuern müssen.

**Depends on**: 2026-03-27-gopy-export (muss zuerst als Feature oder Infra-Blocker geklärt sein)

## Target State

- Ein Engine-Typ wie `GopySmokeRunner` kann ein `TemplateInstance`-Exportprogramm in ein temporäres Projekt schreiben, kompilieren und mit Smoke-Argument starten
- Der Runner liefert ein strukturiertes Ergebnis mit Exit-Status, relevanten Logzeilen und einer klaren Aussage, ob der Smoke-Lauf erfolgreich war
- Compile-Fehler, Runtime-Fehler und Toolchain-Fehler sind unterscheidbar und werden nicht als generischer String-Brei zurückgegeben
- GPT-2-Smoke läuft gegen die echte gopy-Toolchain, kein Mock-Executor
- Der Slice erzeugt keinen UI-State und keine AppKit-/SwiftUI-Abhängigkeiten

## Decisions

### In Scope

- Neuer Engine-Typ `GopySmokeRunner` plus Fehler-/Result-Typen
- Wiederverwendung von `GopyExporter` als einzige Exportquelle
- Projektverzeichnis-Handling für Export, Compile und Run in isoliertem Arbeitsordner
- Parsen der wichtigsten Smoke-Ausgabe:
  - Compile erfolgreich / fehlgeschlagen
  - Smoke-Shape-Check bestanden / fehlgeschlagen
  - Loss-Wert gefunden / nicht gefunden
- Reale End-to-End-Tests gegen lokale gopy-Toolchain

### Out of Scope

- SwiftUI-Buttons, Fortschrittsbalken oder Ergebnisdarstellung
- Mehrere Modellfamilien außer GPT-2
- Volles Training jenseits des bestehenden Smoke-Modus
- Persistenz historischer Runs
- Dataset-Management oder Tokenizer-Konfiguration in der App

### Rejected Alternatives

- **UI startet Shell-Commands direkt**: Verletzt die Architekturgrenze. Prozesssteuerung gehört in Ebene A.
- **Nur Compile prüfen, Run skippen**: Verfehlt den Zweck des Smoke-Slices. Wir brauchen den ersten echten Trainingssanity-Check.
- **Logs ungeparst als Rohtext zurückgeben**: Zu schwach für spätere UI. Der Runner muss bereits jetzt die wichtigen Signale strukturieren.
- **Separate Smoke-Exportdatei neben `GopyExporter`**: Doppelte Wahrheit. Export bleibt zentral im bestehenden Exporter.

## Implementation Steps

1. **Runner-API definieren**
   - `GopySmokeRunner` mit einer klaren High-Level-Methode einführen
   - Ergebnis- und Fehlertypen für Toolchain-, Compile- und Runtime-Fehler modellieren
   - Arbeitsverzeichnis und Artefaktpfade deterministisch kapseln

2. **Compile- und Run-Pipeline**
   - `GopyExporter` wiederverwenden, `.gpy` schreiben und kompilieren
   - Das kompilierte Programm im gopy-Smoke-Modus starten
   - Prozessausgaben sammeln, Exit-Codes auswerten und Guard-Failures sauber trennen

3. **Smoke-Output strukturieren**
   - Relevante Zeilen wie Shape-Check, Loss und offensichtliche Fehlermeldungen extrahieren
   - Kein fragiles Volltext-Matching; nur auf wenige stabile Signale gehen
   - Ergebnis so schneiden, dass spätere UI ohne Parsing nachziehen kann

4. **Tests**
   - Erfolgsfall gegen echte Toolchain
   - Fehlerfall bei fehlender Toolchain
   - Fehlerfall bei Compile- oder Runtime-Abbruch mit strukturierter Diagnose
   - `make test` muss den Smoke-Runner mitprüfen

## Change Log

- initial plan

## Tests

- `GopySmokeRunnerTests` für Ergebnis-Parsing und Fehlertypen
- End-to-End-Test: Export + Compile + Smoke-Run gegen lokale gopy-Toolchain
- `make test` besteht inklusive Smoke-Runner

## Risks

- **Toolchain-Flakiness**: Reale gopy-Läufe können an lokaler Python-/MLX-Umgebung hängen. Fehler müssen deshalb sehr klar separiert sein.
- **Log-Parsing driftet**: Nur wenige stabile Marker extrahieren, sonst werden Tests brittle.
- **Laufzeit**: Reale Smoke-Läufe sind langsamer als reine Unit-Tests. Der Slice braucht schmale, aber echte Inputs.
- **Artefakt-Müll**: Runner muss Arbeitsordner kontrolliert anlegen, damit der Repo-Root nicht zugemüllt wird.

## Approval Block

(filled by reviewer)
