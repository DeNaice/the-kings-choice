using Godot;
using System;
using System.Collections.Generic;
using System.Linq;


public partial class Map : Control
{
	List<MapNode> nodes;
	Dictionary<string, List<string>> edges = new Dictionary<string, List<string>>();
	Color edgeColor = new Color(100, 100, 100, 1);

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Get the child nodes marked as MapNodes to the list of Nodes
		var mapNodes = GetChildren().Where(child => child.IsInGroup("MapNodes")).Select(child => child).Cast<MapNode>();
		nodes = new List<MapNode>();
		foreach (MapNode node in mapNodes)
		{
			if (node.sceneName == GameManager.currentPlace)
			{
				node.SetPlayerMapLocation();
			}
			nodes.Add(node);
		}
	}


	// Called once, if a redraw is needed, call CanvasItem.Redraw()
	public override void _Draw()
	{
		foreach (MapNode node in nodes)
		{
			if (!node.hasTeleporter)
			{
				MeshInstance2D teleportIndicator = node.GetNode<MeshInstance2D>("TeleportIndicator");
				teleportIndicator.Hide();
			}
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
