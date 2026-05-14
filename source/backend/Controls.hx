package backend;

import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.keyboard.FlxKey;
import flixel.input.touch.FlxTouch;
import flixel.input.touch.FlxTouchManager;

#if mobile
import mobile.input.MobileInput;
import mobile.input.MobileButton;
#end

class Controls
{
	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	
	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	
	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;

	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	
	// Mobile specific
	#if mobile
	public var mobileBinds:Map<String, Array<MobileButton>>;
	public var mobileMode:Bool = false;
	#end

	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;
	public var controllerMode:Bool = false;
	
	// Getters for directions
	private function get_UI_UP_P() return justPressed('ui_up');
	private function get_UI_DOWN_P() return justPressed('ui_down');
	private function get_UI_LEFT_P() return justPressed('ui_left');
	private function get_UI_RIGHT_P() return justPressed('ui_right');
	private function get_NOTE_UP_P() return justPressed('note_up');
	private function get_NOTE_DOWN_P() return justPressed('note_down');
	private function get_NOTE_LEFT_P() return justPressed('note_left');
	private function get_NOTE_RIGHT_P() return justPressed('note_right');
	
	private function get_UI_UP() return pressed('ui_up');
	private function get_UI_DOWN() return pressed('ui_down');
	private function get_UI_LEFT() return pressed('ui_left');
	private function get_UI_RIGHT() return pressed('ui_right');
	private function get_NOTE_UP() return pressed('note_up');
	private function get_NOTE_DOWN() return pressed('note_down');
	private function get_NOTE_LEFT() return pressed('note_left');
	private function get_NOTE_RIGHT() return pressed('note_right');
	
	private function get_UI_UP_R() return justReleased('ui_up');
	private function get_UI_DOWN_R() return justReleased('ui_down');
	private function get_UI_LEFT_R() return justReleased('ui_left');
	private function get_UI_RIGHT_R() return justReleased('ui_right');
	private function get_NOTE_UP_R() return justReleased('note_up');
	private function get_NOTE_DOWN_R() return justReleased('note_down');
	private function get_NOTE_LEFT_R() return justReleased('note_left');
	private function get_NOTE_RIGHT_R() return justReleased('note_right');
	
	// Getters for action buttons
	private function get_ACCEPT() return justPressed('accept');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_RESET() return justPressed('reset');

	public function justPressed(key:String):Bool
	{
		var result:Bool = checkKeyboard(key, true);
		if(result) controllerMode = false;
		
		if(!result) result = checkGamepad(key, true);
		#if mobile
		if(!result) result = checkMobile(key, true);
		#end
		
		return result;
	}

	public function pressed(key:String):Bool
	{
		var result:Bool = checkKeyboard(key, false);
		if(result) controllerMode = false;
		
		if(!result) result = checkGamepad(key, false);
		#if mobile
		if(!result) result = checkMobile(key, false);
		#end
		
		return result;
	}

	public function justReleased(key:String):Bool
	{
		var result:Bool = checkKeyboard(key, false, true);
		if(result) controllerMode = false;
		
		if(!result) result = checkGamepad(key, false, true);
		#if mobile
		if(!result) result = checkMobile(key, false, true);
		#end
		
		return result;
	}
	
	private function checkKeyboard(key:String, justPressed:Bool, justReleased:Bool = false):Bool
	{
		if(keyboardBinds.exists(key) && keyboardBinds[key] != null)
		{
			if(justReleased)
				return FlxG.keys.anyJustReleased(keyboardBinds[key]);
			else if(justPressed)
				return FlxG.keys.anyJustPressed(keyboardBinds[key]);
			else
				return FlxG.keys.anyPressed(keyboardBinds[key]);
		}
		return false;
	}
	
	private function checkGamepad(key:String, justPressed:Bool, justReleased:Bool = false):Bool
	{
		if(gamepadBinds.exists(key) && gamepadBinds[key] != null && gamepadBinds[key].length > 0)
		{
			var result:Bool = false;
			var binds:Array<FlxGamepadInputID> = gamepadBinds[key];
			
			if(justReleased)
			{
				for(button in binds)
				{
					if(FlxG.gamepads.anyJustReleased(button))
					{
						result = true;
						break;
					}
				}
			}
			else if(justPressed)
			{
				for(button in binds)
				{
					if(FlxG.gamepads.anyJustPressed(button))
					{
						result = true;
						break;
					}
				}
			}
			else
			{
				for(button in binds)
				{
					if(FlxG.gamepads.anyPressed(button))
					{
						result = true;
						break;
					}
				}
			}
				
			if(result) controllerMode = true;
			return result;
		}
		return false;
	}
	
	#if mobile
	private function checkMobile(key:String, justPressed:Bool, justReleased:Bool = false):Bool
	{
		if(mobileBinds != null && mobileBinds.exists(key) && mobileBinds[key] != null)
		{
			for(button in mobileBinds[key])
			{
				if(button == null) continue;
				
				if(justReleased && button.justReleased)
				{
					mobileMode = true;
					return true;
				}
				else if(justPressed && button.justPressed)
				{
					mobileMode = true;
					return true;
				}
				else if(!justPressed && !justReleased && button.pressed)
				{
					mobileMode = true;
					return true;
				}
			}
		}
		return false;
	}
	
	public function updateMobile()
	{
		if(mobileBinds != null)
		{
			for(key in mobileBinds.keys())
			{
				if(mobileBinds[key] != null)
				{
					for(button in mobileBinds[key])
					{
						if(button != null) button.update();
					}
				}
			}
		}
	}
	#end
	
	public function resetInputStates()
	{
		#if mobile
		if(mobileBinds != null)
		{
			for(key in mobileBinds.keys())
			{
				if(mobileBinds[key] != null)
				{
					for(button in mobileBinds[key])
					{
						if(button != null) button.reset();
					}
				}
			}
		}
		#end
	}
	
	public function getInputName(key:String, ?forGamepad:Bool = false, ?forMobile:Bool = false):String
	{
		#if mobile
		if(forMobile && mobileBinds.exists(key) && mobileBinds[key] != null && mobileBinds[key].length > 0)
		{
			var button:MobileButton = mobileBinds[key][0];
			if(button != null) return button.name;
		}
		#end
		
		if(forGamepad && gamepadBinds.exists(key) && gamepadBinds[key] != null && gamepadBinds[key].length > 0)
		{
			var inputId:FlxGamepadInputID = gamepadBinds[key][0];
			return getGamepadButtonName(inputId);
		}
		else if(keyboardBinds.exists(key) && keyboardBinds[key] != null && keyboardBinds[key].length > 0)
		{
			var keyCode:FlxKey = keyboardBinds[key][0];
			return FlxKey.toStringMap.get(keyCode);
		}
		return "?";
	}
	
	private function getGamepadButtonName(buttonId:FlxGamepadInputID):String
	{
		switch(buttonId)
		{
			case A: return "A";
			case B: return "B";
			case X: return "X";
			case Y: return "Y";
			case BACK: return "Back";
			case START: return "Start";
			case LEFT_SHOULDER: return "LB";
			case RIGHT_SHOULDER: return "RB";
			case LEFT_TRIGGER: return "LT";
			case RIGHT_TRIGGER: return "RT";
			case DPAD_UP: return "D-Pad Up";
			case DPAD_DOWN: return "D-Pad Down";
			case DPAD_LEFT: return "D-Pad Left";
			case DPAD_RIGHT: return "D-Pad Right";
			case LEFT_STICK_DIGITAL: return "LS";
			case RIGHT_STICK_DIGITAL: return "RS";
			case LEFT_STICK_UP: return "L Stick Up";
			case LEFT_STICK_DOWN: return "L Stick Down";
			case LEFT_STICK_LEFT: return "L Stick Left";
			case LEFT_STICK_RIGHT: return "L Stick Right";
			case RIGHT_STICK_UP: return "R Stick Up";
			case RIGHT_STICK_DOWN: return "R Stick Down";
			case RIGHT_STICK_LEFT: return "R Stick Left";
			case RIGHT_STICK_RIGHT: return "R Stick Right";
			default: return "Button";
		}
	}
	
	public function isGamepad():Bool
	{
		return controllerMode;
	}
	
	#if mobile
	public function isMobile():Bool
	{
		return mobileMode;
	}
	#end
	
	public function setKeyboardBinds(binds:Map<String, Array<FlxKey>>)
	{
		keyboardBinds = binds;
	}
	
	public function setGamepadBinds(binds:Map<String, Array<FlxGamepadInputID>>)
	{
		gamepadBinds = binds;
	}
	
	#if mobile
	public function setMobileBinds(binds:Map<String, Array<MobileButton>>)
	{
		mobileBinds = binds;
	}
	#end
	
	public function copyFrom(other:Controls)
	{
		keyboardBinds = other.keyboardBinds.copy();
		gamepadBinds = other.gamepadBinds.copy();
		controllerMode = other.controllerMode;
		
		#if mobile
		if(other.mobileBinds != null) mobileBinds = other.mobileBinds.copy();
		mobileMode = other.mobileMode;
		#end
	}

	public static var instance:Controls;
	public function new()
	{
		keyboardBinds = ClientPrefs.keyBinds;
		gamepadBinds = ClientPrefs.gamepadBinds;
		
		#if mobile
		if(ClientPrefs.mobileBinds != null) mobileBinds = ClientPrefs.mobileBinds;
		#end
	}
}
