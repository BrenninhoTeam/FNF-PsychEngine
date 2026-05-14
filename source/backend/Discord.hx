package backend;

#if DISCORD_ALLOWED
import sys.thread.Thread;
import lime.app.Application;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import flixel.util.FlxStringUtil;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private inline static final _defaultID:String = "863222024192262205";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordPresence = new DiscordPresence();
	@:unreflective private static var __thread:Thread;

	public static function check()
	{
		if(ClientPrefs.data.discordRPC) initialize();
		else if(isInitialized) shutdown();
	}
	
	public static function prepare()
	{
		if (!isInitialized && ClientPrefs.data.discordRPC)
			initialize();

		Application.current.window.onClose.add(function() {
			if(isInitialized) shutdown();
		});
	}

	public dynamic static function shutdown()
	{
		if (!isInitialized) return;
		isInitialized = false;
		Discord.Shutdown();
	}
	
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final user = cast (request[0].username, String);
		final discriminator = cast (request[0].discriminator, String);
		changePresence();
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {}

	public static function initialize()
	{
		if (isInitialized) return;

		var discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), 1, null);

		if (__thread == null)
		{
			__thread = Thread.create(() ->
			{
				while (true)
				{
					if (isInitialized)
					{
						#if DISCORD_DISABLE_IO_THREAD
						Discord.UpdateConnection();
						#end
						Discord.RunCallbacks();
					}
					Sys.sleep(1.0);
				}
			});
		}
		isInitialized = true;
	}

	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, largeImageKey:String = 'icon')
	{
		if (!isInitialized) return;

		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		presence.state = state;
		presence.details = details;
		presence.smallImageKey = smallImageKey;
		presence.largeImageKey = largeImageKey;
		presence.largeImageText = "Engine Version: " + states.MainMenuState.psychEngineVersion;
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		
		updatePresence();
	}

	public static function updatePresence()
	{
		if (!isInitialized) return;
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence.__presence));
	}
	
	inline public static function resetClientID()
	{
		clientID = _defaultID;
	}

	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;

		if(change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}

	#if MODS_ALLOWED
	public static function loadModRPC()
	{
		var pack:Dynamic = Mods.getPack();
		if(pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
			clientID = pack.discordRPC;
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "changeDiscordPresence", changePresence);
		Lua_helper.add_callback(lua, "changeDiscordClientID", function(?newID:String) {
			clientID = (newID == null) ? _defaultID : newID;
		});
	}
	#end
}

@:allow(backend.DiscordClient)
private final class DiscordPresence
{
	public var state(get, set):String;
	public var details(get, set):String;
	public var smallImageKey(get, set):String;
	public var largeImageKey(get, set):String;
	public var largeImageText(get, set):String;
	public var startTimestamp(get, set):Int;
	public var endTimestamp(get, set):Int;

	@:noCompletion private var __presence:DiscordRichPresence;

	function new()
	{
		__presence = DiscordRichPresence.create();
	}

	@:noCompletion inline function get_state():String return __presence.state;
	@:noCompletion inline function set_state(v:String):String return __presence.state = v;

	@:noCompletion inline function get_details():String return __presence.details;
	@:noCompletion inline function set_details(v:String):String return __presence.details = v;

	@:noCompletion inline function get_smallImageKey():String return __presence.smallImageKey;
	@:noCompletion inline function set_smallImageKey(v:String):String return __presence.smallImageKey = v;

	@:noCompletion inline function get_largeImageKey():String return __presence.largeImageKey;
	@:noCompletion inline function set_largeImageKey(v:String):String return __presence.largeImageKey = v;

	@:noCompletion inline function get_largeImageText():String return __presence.largeImageText;
	@:noCompletion inline function set_largeImageText(v:String):String return __presence.largeImageText = v;

	@:noCompletion inline function get_startTimestamp():Int return __presence.startTimestamp;
	@:noCompletion inline function set_startTimestamp(v:Int):Int return __presence.startTimestamp = v;

	@:noCompletion inline function get_endTimestamp():Int return __presence.endTimestamp;
	@:noCompletion inline function set_endTimestamp(v:Int):Int return __presence.endTimestamp = v;
}
#end
