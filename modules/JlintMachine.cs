using Godot;
using System;
using Jint;

public partial class JlintMachine : Sprite2D
{
	Jint.Engine machine;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		machine = new Jint.Engine(options =>
		{
			// Limit memory allocations to MB
			options.LimitMemory(4_000_000);

			// Set a timeout to 4 seconds.
			options.TimeoutInterval(TimeSpan.FromSeconds(0.1));

			// Set limit of 1000 executed statements.
			options.MaxStatements(1000);

			// Use a cancellation token.
			//options.CancellationToken(cancellationToken);
		});
		machine.SetValue("log", new Action<string>(GD.Print));
		machine.Execute(
			@"
							function hello() { 
									log('Hello World');
							};
							hello();
					"
		);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta) { }
}
