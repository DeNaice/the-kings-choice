using Godot;
using System;

public partial class TravelZone : Node3D
{
	[Export]
	public string destination = "Place of Destination";
	[Export]
	public string departure = "Place of Departure";

	bool canTravel = false;

	Label3D destinationDisplay;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		destinationDisplay = GetNode<Label3D>("Destination");
		destinationDisplay.Text = destination;
		destinationDisplay.Hide();
		GD.Print(GameManager.currentPlace);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("enter"))
		{
			if (canTravel)
			{
				GetTree().ChangeSceneToFile("res://scenes/levels/" + destination + ".tscn");
			}
		}
	}

	public void DetectionAreaEntered(Node3D node)
	{
		if (node.IsInGroup("Player"))
		{
			destinationDisplay.Show();
		}
	}
	public void DetectionAreaExited(Node3D node)
	{
		if (node.IsInGroup("Player"))
		{
			destinationDisplay.Hide();
		}
	}
	public void TravelAreaEntered(Node3D node)
	{
		if (node.IsInGroup("Player"))
		{
			canTravel = true;
			destinationDisplay.Text = "Drücke Enter um nach " + destination + " zu reisen";
		}
	}
	public void TravelAreaExited(Node3D node)
	{
		if (node.IsInGroup("Player"))
		{
			canTravel = false;
			destinationDisplay.Text = destination;
		}
	}
}
