using Godot;

public partial class DemoCharacterController : CharacterBody3D
{
    [Export] public float SPEED = 5.0f;
    [Export] public float JUMP_VELOCITY = 4.5f;
    [Export] public bool EnableGravity = true;

    private Node3D model;
    private Camera3D camera;

    private const float Gravity = 9.8f;

    public override void _Ready()
    {
        model = GetNode<Node3D>("PlayerModel");
        camera = GetParent().GetNode<Camera3D>("MainCamera3D");
    }

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
            model.Rotation = new Vector3(model.Rotation.X, lookDirection.Angle(), model.Rotation.Z);
        }

        Vector3 direction = GlobalTransform.Basis * new Vector3(inputDir.X, 0, inputDir.Y);
        direction = direction.Normalized();

        if (direction != Vector3.Zero)
        {
            Vector3 moveDir = Vector3.Zero;
            moveDir.X = direction.X;
            moveDir.Z = direction.Z;
            moveDir = moveDir.Rotated(Vector3.Up, camera.Rotation.Y).Normalized();
            Velocity = new Vector3(moveDir.X * SPEED, Velocity.Y, moveDir.Z * SPEED);
        }
        else
        {
            Velocity = new Vector3(Mathf.MoveToward(Velocity.X, 0, SPEED), Velocity.Y, Mathf.MoveToward(Velocity.Z, 0, SPEED));
        }

        MoveAndSlide();
    }
}
