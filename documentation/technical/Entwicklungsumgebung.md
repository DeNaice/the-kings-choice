# Entwicklungsumgebung
--- 

Hier die benötigte Software, exklusive der Programme welche für Assetgenerierung genutzt werden.

## Godot
##### Version
4.2.3 .NET Version
Diese erfordert die Installation von .NET SDK
[.NET SDK](https://dotnet.microsoft.com/en-us/download)

##### Einrichten von Godot mit VSC

[Offizielle Doku](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_basics.html)s



## Visual Studio Code
Da die Extensions hier am weitesten ausgebaut sind und kostenlose Software am besten ist.
##### Extensions
`C#`
`godot-tools` : Für Autocomplete etc mit C#
`Markdown Preview Enhanced` : Mit `STRG+k`+`v` wird ein ein Preview eines Markdown Dokuments geöffnet
`EditorConfig for VS Code` : Ermöglicht eine gemeinsame Autoformatierungsstruktur 
`C# Tools for Godot` : ein paar hilfreiche Features fürs Debugging falls nötig

##### Hinweis

VSC kann Probleme mit der Autovervollständigung( Erreichen des Godot Language Servers) haben wenn man es nicht von Godot aus startet in dem man dort auf ein Skript drückt.

# Versionsmanagment

---

##### Umgang mit Git
Abseits der IDE Integration von VSC die gut fürs stagen und normale commits funktioniert sollte für andere Befehle die [Git BASH](https://gitforwindows.org/) genutzt werden, eine Konsolenanwendung. 



##### Zugang und Einrichten

Es muss ein Account existieren, dieser muss eingeladen werden. Zur Authentifizierung wird `SSH` genutzt.

[Offizielle Doku ](
https://docs.gitlab.com/ee/gitlab-basics/start-using-git.html#add-your-git-username-and-set-your-email)

1. Key Paar generieren (ED25519)
2. Zu Gitlab Account hinzufügen

Mit SSH das Projekt klonen. Also im gewünschten Verzeichniss 
`git clone git@git.thm.de:tjfr32/the-kings-choice.git` ausführen.

Die Bash sollte noch VSC als Texteditor ansprechen da Vim oder was auch immer da default eingestellt ist direkt aus der Hölle gekrochen ist. 
`git config --global core.editor "code --wait"`

# Sprache

---

Im Code und den Commits englisch. 
Dokumentation sowie Diskussionen im gitlab in Issues und Merge-Requests auf deutsch.
