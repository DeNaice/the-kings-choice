# Beschreibung
---
Hier wird eine Vorgehensweise zugrunde gelegt um zusammen effizient und agil arbeiten zu können.
Gitlab bietet hier eigentlich alles was wir brauchen.

Grundsätzlich gibt es eine `main` branch, diese ist eine lauffähige Applikation.
Alle Änderungen die einfließen werden im Rahmen eines `merge-requests` geprüft.
Features, Änderungen, Bugfixes oder auch kreative Diskussionen werden erst in ein Ticket geschrieben,
wir benutzen dafür `issues`.

##### Besonderheit bei der Entwicklung mit Godot

Da das gleichzeitige Arbeiten an `scenes` zu ungewünschten Nebeneffekten führt sollten wir hier darauf achten dass wir Szenen "reservieren" um Kopfschmerzen aus dem Weg zu gehen. 
Dafür wird für **jede** `scene` ein Label kreiert, wenn ein Issue Änderungen an einer Scene vornimmt muss das `issue` sowie der `merge-request` mit den entsprechenden Labeln versehen werden. 

##### Dokumentation

Als Markdown damit die Doku auch dem normalen Workflow mit Review etc folgt und Änderungen nachvollziehbar sind. Zudem kann Markdown in Gitlab geladen werden in dem man auf die Datei klickt.

---

## Ablauf 


1. `issue` wird erstellt, hier wird geschildert was die Änderung sein soll. Das `issue` sollte dann mit notwendigen Labeln versehen werden, typisch wären : `Diskussionsbedarf` `Code` `Bug` `Feature` `Wiki`
2. Die verantwortliche Person assigned sich das Ticket und drückt im `issue` auf den "Create Merge Request" Knopf. Danach kann man mit `git fetch` gefolgt von `git checkout <branchname>` auf die neu erstellte `branch` wechseln.
3. Nun arbeitet man das Ticket ab. Im `issue` kann man auch weiter kommunizieren.
4. Wenn man denkt dass man fertig ist entfernt man den `Draft`-Prefix,und weißt einen Reviever zu, am besten gibt man ihm auch noch so Bescheid. **wichtig** Die `branch` an der man arbeitet muss an die `main` branch `rebased` werden.
5. Der Reviewer führt das `code-review` durch.
6. Solange man Änderungswünsche zurück erhält arbeitet man diese ein und gibt es wieder zum Review.
7. Wenn der Reviewer zufriedengestellt drückt er auf den "Approved"-Knopf und die `branch` kann nun gemerged werden
---

## Git Slang

- `branch` aufgebaut wie eine "Perlenkette" aus `commits` kann im Gegensatz zu einem Baum die Äste wieder in den Haupttrieb intergrieren.
- `commit` ein Zustand des repositories. Man versucht also inhaltlich abtrennbare Änderungen in eigene `Commits` zu fassen. Dies dient dazu  Änderungen miteinander vergleichen zu können. 
- `merge-request` ist die Anfrage eine `branch` in eine andere zu integrieren, im praktischen bedeutet das dass man die Änderungen im Interface genau nachverfolgen kann und dies beim Entwickeln und für den `Code-Review`-Prozess nutzt. Die Änderungen können ein oder mehrere `commits` enthalten.
- `issue` Eine Art Ticket mit dem man eine oder auch mehrere Merge-Requests vereint. 
- `code-review` Wenn man denkt dass seine `branch` bereit ist in die `main` integriert zu werden fragt man von einem Teammitglied eine Überprufüng an. Dieser prüft dann auf Bugs, Probleme mit dem Code und gibt dies mit anderen Änderungsvorschlagen zurück. 
- `rebase` Hierbei steckt man Änderungen unter eine gewisse Stelle der momentanen `branch`. Während man eine Änderung einbaut wird wahrscheinlich an der `main` weitergearbeitet, das heißt man muss unter seinen `commits` die neuen die auf die `main` "draufgebaut" wurden haben um konflitkfrei integrieren zu können. Der Befehl `git rebase -i origin/main` kann dazu genutzt werden. Hier können Mergekonflikte entstehen, hier muss man dann eben die Stellen an seinem Branch entsprechend anpassen/aussuchen je nach IDE. 
- `staged` Wenn Änderungen vorgenommen wurden müssen diese erst mit beispielweise `git add .` gestaged werden. Das heißt diese Änderungen sind nun Teil des commits wenn wir `git commit -m "commitmessage"` ausführen. 

---

## Git Befehle

##### Repo pushen

`git push -f` force push um lokale Änderungen hochzupushen, **-f ist wichtig**

##### Auf branch wechseln 

- `git fetch` zieht Änderungen am Repo (kein updaten der Dateien auf momentanen Branch), so können beispielsweise neue Branches entdeckt werden auf die man wechseln kann

- `git checkout <branch-name>` Um auf die spezifizierte Branch zu wechseln

- `git checkout -b <branch-name>` Falls `branch` nicht exisitiert kann so eine neue erstellt werden mit gewähltem Namen

Hier kann es passieren dass man noch Änderungen offen hat die nicht gestaged sind eine Warnung erhält dass es ungespeicherte Änderungen gibt und man nicht wechseln kann.

Dafür kann man die Änderungen zwischenspeichern mit.

- `git stash` fügt alle Änderungen einem stash hinzu
- `git stash pop` holt die Änderungen vom stash (dem obersten Eintrag im Stash)

##### Änderungen commiten / rückgängig machen
- `git add .` `staged` die momentanen Änderungen 
- `git commit -m "message" ` Fügt der Branch die `gestageten` Daten als `commit` hinzu
- `git commit --amend ` Fügt die gestageten Änderungen an den letzten `commit` hinzu anstatt einen neuen zu kreieren
- `git reset --soft HEAD^1` Setzt den letzten `commit` zurück auf gestaged

##### Rebasing
Man sollte davor einmal `git fetch` ausführen

`git rebase -i origin/main` setzt den momentanen branch auf die `main` auf. Das `origin/main` bedeuted dass zum Vergleich die `main` im Repo benutzt wird und nicht die lokale `main` branch die man eventuell noch updaten müsste.
Die IDE geleitet einen im Normalfall durch die Konflikte.


##### An altem Commit arbeiten

Das sollte nur passieren während man noch aktiv an einem `merge-request` arbeitet.
Wenn ein Bug sich auf die `main` einschleicht wird dieser mit einem neuen `commit` behoben.

1. Man macht seinen Fix als eigenen Commit
2. Man führt `git rebase -i HEAD~X` aus, X ist hierbei die Anzahl an commits die gleich angezeigt werden
3. Sobald der Texteditor nun die Liste der `commits` anzeigt ändert man das add in ein squash und setzt den `commit` mit copy-paste über den `commit` auf dem Mann aufbauen will.

---

## Label

`Dokumentation` : Das Ergebnis ist ein Dokument oder die Überarbeitung existierender
`Code` : Es gibt Änderungen am Code
`Brainstorming` : Hier wird im Issue diskutiert und der Assignee fasst das ganze zusammen als Dokument
`Assets` : Die Änderung enthält ein oder mehrere Assets die importiert werden müssen
`Diskussionbedarf` : Das Issue braucht Input bevor es in die Bearbeitung kann
`Bug` : Ein Bug treibt sein Unwesen
`Feature` : Ein neues Feature wird eingeführt