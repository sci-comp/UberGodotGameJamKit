using Godot;

public partial class DemoCharacterController : CharacterBody3D
{
    private float maxSpeed = 5.0f;
    private float acceleration = 15.0f;
    private float commonGroundFriction = 0.02f;
    private float jumpImpulse = 10.0f;
    private float mouseSensitivity = 0.2f;
    private float controllerSensitivity = 200.0f;
    private Vector3 inputDir;

    private Node3D cameraAxis;
    private Camera3D camera;

    private float G = 9.81f;

    public override void _Ready()
    {
        cameraAxis = GetNode<Node3D>("CameraAxis");
        camera = GetNode<Camera3D>("CameraAxis/Camera3D");

        Input.MouseMode = Input.MouseModeEnum.Captured;
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseMotion motionEvent)
        {
            RotateY(Mathf.DegToRad(-motionEvent.Relative.X * mouseSensitivity));
            cameraAxis.RotateX(Mathf.DegToRad(-motionEvent.Relative.Y * mouseSensitivity));
            cameraAxis.Rotation = new(
                Mathf.Clamp(cameraAxis.Rotation.X, Mathf.DegToRad(-89.0f), Mathf.DegToRad(89.0f)), 
                cameraAxis.Rotation.Y, 
                cameraAxis.Rotation.Z);
        }

        if (@event.IsAction("Exit"))
        {
            GetTree().Quit();
        }
    }

    public override void _Process(double delta)
    {
        float dt = (float)delta;

        if (Input.IsActionPressed("camera_left"))
        {
            RotateY(Mathf.DegToRad(controllerSensitivity * Input.GetActionStrength("camera_left") * dt));
        }

        if (Input.IsActionPressed("camera_right"))
        {
            RotateY(Mathf.DegToRad(controllerSensitivity * Input.GetActionStrength("camera_right") * dt * -1.0f));
        }

        if (Input.IsActionPressed("camera_up"))
        {
            cameraAxis.RotateX(Mathf.DegToRad(controllerSensitivity * Input.GetActionStrength("camera_up") * dt));
        }

        if (Input.IsActionPressed("camera_down"))
        {
            cameraAxis.RotateX(Mathf.DegToRad(controllerSensitivity * Input.GetActionStrength("camera_down") * dt * -1.0f));
        }

        cameraAxis.Rotation = new(
            Mathf.Clamp(cameraAxis.Rotation.X, Mathf.DegToRad(-89.0f), Mathf.DegToRad(89.0f)),
            cameraAxis.Rotation.Y,
            cameraAxis.Rotation.Z);

        inputDir = new Vector3(
            Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left"),
            0.0f,
            Input.GetActionStrength("move_backward") - Input.GetActionStrength("move_forward")
        ).Normalized();
        inputDir = inputDir.Rotated(GlobalTransform.Basis.Y, Mathf.DegToRad(RotationDegrees.Y));
    }

    public override void _PhysicsProcess(double delta)
    {
        float dt = (float)delta;

        if (IsOnFloor())
        {
            if (inputDir.LengthSquared() > 0.0f)
            {
                var inputVelocity = inputDir * acceleration * dt;
                Velocity += inputVelocity;
                Velocity -= Velocity * commonGroundFriction;
            }
            else
            {
                Velocity = Velocity.Normalized() * Mathf.Clamp(Velocity.Length() - 3.0f * acceleration * dt, 0.0f, maxSpeed);
            }

            if (Input.IsActionJustPressed("jump"))
            {
                Velocity += Vector3.Up * jumpImpulse;
            }
        }
        else
        {
            Velocity += Vector3.Down * G * dt;
        }

        MoveAndSlide();
    }

}

