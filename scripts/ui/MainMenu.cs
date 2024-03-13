using Godot;
using System;

public partial class MainMenu : Node2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		GD.Print("Applikation startet");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	public  void OnNeuesSpiel(){
		GetTree().ChangeSceneToFile("scenes/levels/Zuhause.tscn");
	}
	public  void OnSpielLaden(){
		GD.Print("Spiel Laden gedrückt, nicht implementiert");
	}
	public  void OnTestLevel(){
		GetTree().ChangeSceneToFile("scenes/test/TestLevel.tscn");
	}
	public  void OnCredits(){
		GetTree().ChangeSceneToFile("scenes/UI/Credits.tscn");
	}
	public  void OnOptionen(){
		GD.Print("Optionen gedrückt, nicht implementiert");
	}
	public  void OnSpielVerlassen(){
		GD.Print("Ciao");
		GetTree().Quit();
	}
}
