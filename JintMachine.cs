using Godot;
using Jint;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public partial class JintMachine : Node
{
	bool running = false;
	Jint.Engine machine;
	string context = "{\"test\":\"1\"}";
	double dx;
	double dy;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		machine = new Jint.Engine(options =>
		{
			// Limit memory allocations to MB
			//options.LimitMemory(4_000_000);

			// Set a timeout to 4 seconds.
			options.TimeoutInterval(TimeSpan.FromSeconds(0.1));

			// Set limit of 1000 executed statements.
			//options.MaxStatements(10);

			// Use a cancellation token.
			//options.CancellationToken(cancellationToken);
		});
		machine.SetValue("log", new Action<string>((x) => GD.Print(x)));
		machine.SetValue("dx", 0);
		machine.SetValue("dy", 0);
		try
		{
			machine.Execute(
				@"
			let context = {}
			const parseContext = () => {
				context = JSON.parse(jsonContext)
			}
			let process = async (ctx) => {
				//log(JSON.stringify(ctx))
				//dx = dx + 1
				//dy = dy + 1.1
			}
			"
			);
		}
		catch (Exception e)
		{
			GD.Print(e);
		}
	}

	public override async void _Process(double delta)
	{
		AsyncFunction(nameof(_Process));
	}

	private async Task AsyncFunction(string from)
	{
		if (running)
		{
			return;
		}
		running = true;
		await Task.Delay(2000);
		double startTime = Time.GetTicksUsec();

		machine.SetValue("jsonContext", context);
		try
		{
			machine.Execute(
				@"
			parseContext();
			(async ()=>{process(context)})(); 
			"
			);
		}
		catch (Exception e)
		{
			GD.Print(e);
		}
		double elapsed = Time.GetTicksUsec() - startTime;

		dx = machine.GetValue("dx").AsNumber();
		dy = machine.GetValue("dy").AsNumber();
		//GD.Print(elapsed);
		GD.Print("DATA");
		GD.Print(dx);
		GD.Print(dy);

		//machine.GetValue
		running = false;
	}
	public async void ExecMessage(string msg)
	{
		try
		{
			machine.Execute(msg);
		}
		catch (Exception e)
		{
			GD.Print(e);
		}
	}
}
