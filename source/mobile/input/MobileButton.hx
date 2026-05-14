#if mobile
package mobile.input;

import flixel.util.FlxPoint;
import flixel.util.FlxRect;

class MobileButton
{
	public var name:String;
	public var bounds:FlxRect;
	public var justPressed:Bool = false;
	public var justReleased:Bool = false;
	public var pressed:Bool = false;
	
	private var _lastPressed:Bool = false;
	
	public function new(name:String, x:Float, y:Float, width:Float, height:Float)
	{
		this.name = name;
		bounds = FlxRect.get(x, y, width, height);
	}
	
	public function update()
	{
		justPressed = false;
		justReleased = false;
		
		var isPressed:Bool = false;
		var touches:Array<FlxTouch> = FlxG.touches.list;
		
		for(touch in touches)
		{
			if(touch.overlaps(bounds))
			{
				isPressed = true;
				if(!_lastPressed)
				{
					justPressed = true;
				}
				break;
			}
		}
		
		if(_lastPressed && !isPressed)
		{
			justReleased = true;
		}
		
		pressed = isPressed;
		_lastPressed = isPressed;
	}
	
	public function reset()
	{
		justPressed = false;
		justReleased = false;
		pressed = false;
		_lastPressed = false;
	}
	
	public function destroy()
	{
		bounds = null;
	}
}
#end
