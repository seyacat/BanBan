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
    double startTic = Time.GetTicksUsec();
    double lastTic = Time.GetTicksUsec();
    Esprima.Ast.Script runUpdate;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        runUpdate = new Esprima.JavaScriptParser().ParseScript(
            @"
				if( typeof update === 'function' ){
						const ret = update();
						global._d = getDelta()
					}
				"
        );
        machine = new Jint.Engine(options =>
        {
            // Limit memory allocations to MB
            options.LimitMemory(60_000);

            // Set a timeout to 4 seconds.
            options.TimeoutInterval(TimeSpan.FromSeconds(1));

            // Set limit of 1000 executed statements.
            options.MaxStatements(100);

            // Recursion Limit.
            options.LimitRecursion(10);

            options.Strict(true);
        });
        JsValue[] zero = new JsValue[] { 0, 0 };
        machine.SetValue("log", new Action<string>((x) => GD.Print(x)));
        machine.SetValue("getDelta", GetDelta);
        machine.SetValue("getPosition", GetPosition);
        machine.SetValue("getEnemies", GetEnemies);
        machine.SetValue("getEnemyCount", GetEnemyCount);
        machine.SetValue("getEnemy", GetEnemy);
        machine.SetValue("getBombs", GetBombs);
        machine.SetValue("getBombCount", GetBombCount);
        machine.SetValue("getBomb", GetBomb);
        machine.SetValue("_p", GetParent<Node2D>().Position);
        machine.SetValue("_v", "");
        machine.SetValue("_b", "");
        machine.SetValue("_d", "");
        machine.SetValue("_h", false);
        machine.SetValue("update", "");
        machine.SetValue("test", "");
        try
        {
            machine.Execute(
                @"
			const global = this;
			
			const m = (x,y)=>{
				_p = [x,y]
				update = (context)=>{
					const position = getPosition()
					if( Math.abs(_p[0]-position[0]) < 0.4 && Math.abs(_p[1]-position[1]) < 0.4 ){
						global._v = [0,0]
						update = null
						return
					}
					global._v = [ _p[0]-position[0],_p[1]-position[1] ]
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

    double GetDelta()
    {
        return (startTic - lastTic) / 1000;
    }

    Godot.Vector2 GetPosition()
    {
        return GetParent<Node2D>().Position;
    }

    object[] GetEnemies()
    {
        Node2D players = GetParent<Node2D>().GetParent<Node2D>();
        Node2D me = GetParent<Node2D>();
        List<object> positions = new List<object> { };
        foreach (Node2D p in players.GetChildren())
        {
            if (p.Name != me.Name)
            {
                positions.Add(new { position = p.Position, id = p.Name });
            }
        }
        return positions.ToArray();
    }

    int GetEnemyCount()
    {
        Node2D players = GetParent<Node2D>().GetParent<Node2D>();
        return players.GetChildCount() - 1;
    }

    object GetEnemy(int index)
    {
        Node2D players = GetParent<Node2D>().GetParent<Node2D>();
        Node2D me = GetParent<Node2D>();
        List<object> positions = new List<object> { };
        int c = 0;
        foreach (Node2D p in players.GetChildren())
        {
            if (p.Name != me.Name)
            {
                if (c == index)
                {
                    return new { position = p.Position, id = p.Name };
                }
                c++;
            }
        }
        return null;
    }

    object[] GetBombs()
    {
        Node2D bombs = GetParent<Node2D>()
            .GetParent<Node2D>()
            .GetParent<Node2D>()
            .GetNode<Node2D>("Bombs");
        //Node2D me = GetParent<Node2D>();
        List<object> positions = new List<object> { };
        foreach (Node2D b in bombs.GetChildren())
        {
            positions.Add(new { position = b.Position });
        }
        return positions.ToArray();
    }

    int GetBombCount()
    {
        Node2D bombs = GetParent<Node2D>()
            .GetParent<Node2D>()
            .GetParent<Node2D>()
            .GetNode<Node2D>("Bombs");
        return bombs.GetChildCount();
    }

    object GetBomb(int index)
    {
        Node2D bombs = GetParent<Node2D>()
            .GetParent<Node2D>()
            .GetParent<Node2D>()
            .GetNode<Node2D>("Bombs");
        List<object> positions = new List<object> { };
        RigidBody2D b = bombs.GetChild<RigidBody2D>(index);
        if (b != null)
        {
            return new { position = b.Position, velocity = b.LinearVelocity };
        }
        return null;
    }

    public override async void _Process(double delta)
    {
        AsyncFunction(nameof(_Process));
    }

    public override void _ExitTree()
    {
        machine.Dispose();
        base._ExitTree();
    }

    private async Task AsyncFunction(string from)
    {
        if (running)
        {
            return;
        }
        //GD.Print("run");
        running = true;
        try
        {
            //await Task.Delay(2000);
            startTic = Time.GetTicksUsec();
            //machine.SetValue("context", new { delta = (startTic - lastTic) / 1000, });
            machine.Execute(runUpdate);
            lastTic = startTic;
        }
        catch (Exception e)
        {
            GD.Print(e);
            machine.Execute(
                @"
				update = null
				"
            );
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
        if (ret.Count != 0)
        {
            machine.SetValue(name, "");
            machine.Execute(name + "= null");
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
            if (ret)
            {
                machine.SetValue(name, false);
            }
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
