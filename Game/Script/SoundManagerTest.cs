using Godot;

public partial class SoundManagerTest : Node
{
    [Export] public Button btnBubbles;
    [Export] public Button btnVelcro;

    [Export] public Label sfxInfoText;
    //[Export] public Label uiInfoText;
    //[Export] public Label voiceInfoText;

    public override void _Ready()
    {
        btnBubbles.Pressed += PlayBubbles;
        btnVelcro.Pressed += PlayVelcro;
    }

    public override void _Process(double delta)
    {
        SoundBusInfo sfxBusInfo = SoundManager.Instance.AllBusInfo[SoundBUS.SFX];
        sfxInfoText.Text = $"Bus: SFX\n" +
                        $"Active Voices: {sfxBusInfo.ActiveSources.Count}/{sfxBusInfo.VoiceLimit}\n" +
                        $"Volume: {sfxBusInfo.Volume}";

        /*
        uiInfoText.Text = $"Bus: UI\n" +
                        $"Active Voices: {sfxBusInfo.ActiveSources.Count}/{sfxBusInfo.VoiceLimit}\n" +
                        $"Volume: {sfxBusInfo.Volume}";

        voiceInfoText.Text = $"Bus: Voice\n" +
                        $"Active Voices: {sfxBusInfo.ActiveSources.Count}/{sfxBusInfo.VoiceLimit}\n" +
                        $"Volume: {sfxBusInfo.Volume}";*/
    }

    private static void PlayBubbles()
    {
        GD.Print("Playing bubbles..");
        SoundManager.Instance.PlaySound("sfx_bubbles", new Vector3(0,0,0));
    }

    private static void PlayVelcro()
    {
        SoundManager.Instance.PlaySound("sfx_velcro", new Vector3(0, 0, 0));
    }

}
