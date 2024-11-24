using Godot;
using System.Collections.Generic;

namespace Game
{
    public partial class PossibleSFX3D : Node
    {
        public void Initialize(SFXPlayer3D player)
        {

        }

        public Dictionary<string, SoundGroup3D> GetSoundGroups()
        {
            return new();
        }

    }

}

