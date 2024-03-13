using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
public partial class SceneBaseClass : Node3D
{
	private List<TravelZone> travelZones;
	Node3D spawn;
	protected void InitializeScene()
	  	{
		// This only happens once when a  new game is started
		if (GameManager.currentPlace == "none")
		{
			spawn = GetNode<Node3D>("Spawn");
			GameManager.currentPlace = "Zuhause";
			SetPlayer(spawn.GlobalPosition);
			return;
		}
		var nodes = GetChildren().Where(child => child.IsInGroup("TravelZones")).Select(child => child).Cast<TravelZone>();
		travelZones = new List<TravelZone>();
		foreach (TravelZone travelZone in nodes)
		{
			if (travelZone.destination == GameManager.currentPlace)
			{
				GameManager.currentPlace = travelZone.departure;
				SetPlayer(travelZone.GlobalPosition);
				return;
			}
			else
			{
				GD.Print("|" + travelZone.departure + "|!=|" + GameManager.currentPlace + "|");
			}
		}
	}

	private void SetPlayer(Vector3 position)
	{
		var player = GD.Load<PackedScene>("res://scenes/player/PlayerController.tscn");
		var playerInstance = player.Instantiate();
		AddChild(playerInstance);
		Node3D playerPosition = GetNode<Node3D>("PlayerController");
		playerPosition.GlobalPosition = position;
	}
}
