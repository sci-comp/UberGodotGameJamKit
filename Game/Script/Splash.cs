using Godot;

public partial class Splash : Node
{
    [Export] public string StartingLevel;

    private int frameCount = 0;

    public override void _Process(double delta)
    {
        frameCount++;

        if (frameCount == 2)
        {
            LevelManager.Inst.ChangeLevel(StartingLevel);
            SetProcess(false);
        }
    }

}