using Godot;

public partial class DemoCharacterController : CharacterBody3D
{
    [Export] public Node3D Rendered;
    [Export] public Camera3D Camera;

    [Export] public float Speed = 5.0f;
    [Export] public float JumpVelocity = 4.5f;
    [Export] public bool EnableGravity = true;

    private const float Gravity = 9.8f;

    public override void _PhysicsProcess(double _delta)
    {
        float delta = (float) _delta;

        if (EnableGravity && !IsOnFloor())
           Velocity = new Vector3(Velocity.X, Velocity.Y - Gravity * delta, Velocity.Z);

        Vector2 inputDir = new(
            Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left"),
            Input.GetActionStrength("move_backward") - Input.GetActionStrength("move_forward")
        );

        if (Velocity.Length() > 0.2f)
        {
            Vector2 lookDirection = new (Velocity.Z, Velocity.X);
            Rendered.Rotation = new Vector3(Rendered.Rotation.X, lookDirection.Angle(), Rendered.Rotation.Z);
        }

        Vector3 direction = GlobalTransform.Basis * new Vector3(inputDir.X, 0, inputDir.Y);
        direction = direction.Normalized();

        if (direction != Vector3.Zero)
        {
            Vector3 moveDir = Vector3.Zero;
            moveDir.X = direction.X;
            moveDir.Z = direction.Z;
            moveDir = moveDir.Rotated(Vector3.Up, Camera.Rotation.Y).Normalized();
            Velocity = new Vector3(moveDir.X * Speed, Velocity.Y, moveDir.Z * Speed);
        }
        else
        {
            Velocity = new Vector3(Mathf.MoveToward(Velocity.X, 0, Speed), Velocity.Y, Mathf.MoveToward(Velocity.Z, 0, Speed));
        }

        MoveAndSlide();
    }
}
