using Godot;
using System;

public partial class MapNode : Node2D
{
	[Export]
	public string sceneName;

	[Export]
	public Godot.Collections.Array<string> destinations { get; set; }

	[Export]
	public bool hasTeleporter;

	[Export]
	public bool playerLocation = false;

	[Export] 
	public bool isShowingName = false;
 	private Label label;
	private MeshInstance2D mapIndicatorPlayer;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		label = GetNode<Label>("SceneName");
		mapIndicatorPlayer = GetNode<MeshInstance2D>("MapIndicator");
		if(isShowingName){
		label.Text = sceneName;
		}else{
			label.Text = "";
		}
	}

	public void SetPlayerMapLocation()
	{
		Material material = mapIndicatorPlayer.Material;
		ShaderMaterial shaderMaterial = material as ShaderMaterial;
		shaderMaterial.SetShaderParameter("isActive", 1);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
