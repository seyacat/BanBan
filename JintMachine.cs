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
        machine.SetValue("_p", GetParent<Node2D>().Position);
        machine.SetValue("_v", "");
        machine.SetValue("_b", "");
        machine.SetValue("_d", "");
        machine.SetValue("_h", false);
        machine.SetValue("update", "");
        try
        {
            machine.Execute(
                @"
            const global = this;
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
                    }else{
                        update = null
                    }
                }
			}
            const m = (x,y)=>{
                _p = [x,y]
				update = (context)=>{
                    if( _p[0]-context.position[0] == 0 && _p[1]-context.position[1] == 0 ){
                        update = null
                    }
                    global._v = [ _p[0]-context.position[0],_p[1]-context.position[1] ]
                }
			}
            const b = (angle,vel)=>{
                global._b = [Math.cos(angle*Math.PI/180)*vel,Math.sin(angle*Math.PI/180)*vel]
			}
            const u = (step=32)=>{
                m( _p[0],_p[1]-step  )
			}
            const d = (step=32)=>{
                m( _p[0],_p[1]+step  )
			}
            const l = (step=32)=>{
                m( _p[0]-step,_p[1]  )
			}
            const r = (step=32)=>{
                m( _p[0]+step,_p[1]  )
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
            Node2D me = GetParent<Node2D>();
            Node2D players = GetParent<Node2D>().GetParent<Node2D>();
            List<object> positions = new List<object> { };
            foreach (Node2D p in players.GetChildren())
            {
                if (p.Name != me.Name)
                {
                    positions.Add(new { position = p.Position, id = p.Name });
                }
            }
            machine.SetValue(
                "context",
                new
                {
                    delta = (startTic - lastTic) / 1000,
                    position = GetParent<Node2D>().Position,
                    enemies = positions.ToArray()
                }
            );

            machine.Execute(
                @"
                if( typeof update === 'function' ){
						update(context);
                        global._d = context.delta
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

    public Godot.Collections.Array<double> getDoubleArrayAndNulify(String name)
    {
        Godot.Collections.Array<double> ret = getDoubleArray(name);
        machine.SetValue(name, "");
        machine.Execute(name + "= null");

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

    public double getDoubleAndNulify(String name)
    {
        Jint.Native.JsValue jsOb = machine.GetValue(name);
        if (jsOb.IsNumber())
        {
            double ret = jsOb.AsNumber();
            machine.SetValue(name, "");
            return ret;
        }
        return Double.NaN;
    }

    public Boolean getBooleanAndFalse(String name)
    {
        Jint.Native.JsValue jsOb = machine.GetValue(name);
        if (jsOb.IsBoolean())
        {
            Boolean ret = jsOb.AsBoolean();
            machine.SetValue(name, false);
            return ret;
        }
        return false;
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
