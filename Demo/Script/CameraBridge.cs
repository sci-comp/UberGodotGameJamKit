using Godot;
using System;

namespace Game
{
    public partial class CameraBridge : Node
    {
        private LevelManager levelManager;

        public override void _Ready()
        {
            levelManager = GetNode<LevelManager>("/root/LevelManager");
        }

        public void Blink()
        {
            // Not yet implemented
        }

        public Camera3D MainCamera => new();

        /*public Camera3D MainCamera
        {
            get
            {
                levelManager.CurrentLevel.GetTree().GetNodesInGroup("Spawnpoint");
            }
        }*/


    }

}
