using Godot;

public partial class Splash : Node
{
    [Export] public string StartingScene;

    private int frameCount = 0;

    public override void _Process(double delta)
    {
        frameCount++;

        if (frameCount == 2)
        {
            SceneManager.Instance.ChangeScene(StartingScene);
            SetProcess(false);
        }
    }

}