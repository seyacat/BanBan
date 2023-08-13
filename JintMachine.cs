using Godot;
using Jint;
using Jint.Native;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public partial class JintMachine : Node
{
    bool running = false;
    Jint.Engine machine;
    string context = "{\"test\":\"1\"}";
    JsArray acel;
    double lastTic = Time.GetTicksUsec();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        machine = new Jint.Engine(options =>
        {
            // Limit memory allocations to MB
            options.LimitMemory(4_000_000);

            // Set a timeout to 4 seconds.
            options.TimeoutInterval(TimeSpan.FromSeconds(1));

            // Set limit of 1000 executed statements.
            options.MaxStatements(1000);

            // Use a cancellation token.
            //options.CancellationToken(cancellationToken);
        });
        JsValue[] zero = new JsValue[] { 0, 0 };
        machine.SetValue("log", new Action<string>((x) => GD.Print(x)));
        try
        {
            machine.Execute(
                @"
            const global = this;
            let update
            let _timelapse_data
			const _timelapse = (data)=>{
                _timelapse_data = data
				update = (context)=>{
                    if( _timelapse_data.length ){
                        _timelapse_data[0][2] = (_timelapse_data[0]?.[2] ?? 1000) - context.delta
                        if( _timelapse_data[0][2] <= 0 ){
                            action = _timelapse_data.shift()
                            this[action[0]] = action[1]
                        }
                    }
                }
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
        try
        {
            running = true;
            //await Task.Delay(2000);
            double startTic = Time.GetTicksUsec();

            machine.SetValue("context", new { delta = (startTic - lastTic) / 1000 });

            machine.Execute(
                @"
				if( typeof update === 'function' ){
						update(context);
					}
				"
            );

            lastTic = startTic;
        }
        catch (Exception e)
        {
            GD.Print(e);
        }
        //machine.GetValue
        running = false;
    }

    public Godot.Collections.Array<double> getDoubleArray(String name)
    {
        Jint.Native.JsValue jsOb = machine.GetValue(name);
        Godot.Collections.Array<double> ret = new Godot.Collections.Array<double>();
        if (jsOb.IsObject())
        {
            foreach (JsValue v in jsOb.AsArray())
            {
                if (v.AsNumber() == double.NaN)
                {
                    return ret;
                }
                ret.Add(v.AsNumber());
            }
        }
        return ret;
    }

    public double getDouble(String name)
    {
        Jint.Native.JsValue jsOb = machine.GetValue(name);
        if (jsOb.IsNumber())
        {
            return jsOb.AsNumber();
        }
        return Double.NaN;
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
