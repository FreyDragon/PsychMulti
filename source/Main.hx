package;

import states.ConnectionState;
import states.PlayState;
import states.ScoreOverviewState;
import states.OutdatedState;
#if android
import android.content.Context;
#end
import backend.Rating;
import debug.FPSCounter;
import networking.Network;
import networking.sessions.Session;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.TitleState;
import backend.Song;
#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	static public var instance:Main;
	var server:Dynamic;
	var client:Dynamic;
	public var scoresArray:Dynamic;
	public var otherScoresArray:Dynamic;
	public var freyVersion:Dynamic;
	public var newFreyVersion:Dynamic;
	public var serverstate = "none";
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: ConnectionState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		freyVersion = "0.0.3";
		Main.instance = this;
		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
	
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
	public function startServer(ports:Int = 8888) {
		serverstate = "server";
		server = Network.registerSession(NetworkMode.SERVER, {
			ip: '0.0.0.0',
			port: ports,
			max_connections: 1
		  });
		  server.start();
		  server.addEventListener(NetworkEvent.CONNECTED, function(e: NetworkEvent) {
			var connected_client = e.client;
			connected_client.send({ message: ['version', freyVersion], verb: 'test' });
		  });
		  server.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(e: NetworkEvent) {
			trace(e.data.message); // Welcome to the server!
			switch(e.data.message[0]) {
				case "setHealth":
					if (PlayState.instance.health >= e.data.message[1] + 0.05) {
						PlayState.instance.health -= e.data.message[1];
					}
				case "playAnim":
					PlayState.instance.opponentNoteTrigger(e.data.message[1]);
				case "getRating":
					var dharmann:Rating = e.data.message[2];
					PlayState.instance.popupOpponentScore(dharmann, e.data.message[1]);
				case "playerScore":
					otherScoresArray = [e.data.message[1], e.data.message[2]];
					sendServerMessage(["playerScore", scoresArray]);
				case "BRO HES DEAD":
					PlayState.instance.endSong();
				default:
					trace('unknown prompt '+ e.data.message[0]);
			}
		  });
	}
	public function initCalcScore() {
		if (ScoreOverviewState.instance != null) {
			if (serverstate == "client") {
				ScoreOverviewState.instance.calculateRankings(otherScoresArray[0], otherScoresArray[1], scoresArray[0], scoresArray[1]);
			} else {
				ScoreOverviewState.instance.calculateRankings(scoresArray[0], scoresArray[1], otherScoresArray[0], otherScoresArray[1]);
			}
		}
	}
	public function sendServerMessage(messages:Dynamic) {
		server.send({ message: messages, verb: 'test' });
	}
	public function sendClientMessage(messages:Dynamic) {
		client.send({ message: messages, verb: 'test' });
	}
	public function startClient(serverIP:String = "0.0.0.0", ports:Int = 8888) {
		serverstate = "client";
		client = Network.registerSession(NetworkMode.CLIENT, {
			ip: serverIP,
			port: ports
		  });
		  client.start();
		  client.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(e: NetworkEvent) {
			trace(e.data.message); // Welcome to the server!
			switch(e.data.message[0]) {
				case "setHealth":
					if (PlayState.instance.health >= e.data.message[1] + 0.05) {
						PlayState.instance.health -= e.data.message[1];
					}
				case "playAnim":
					PlayState.instance.opponentNoteTrigger(e.data.message[1]);
				case "playerScore":
					otherScoresArray = [e.data.message[1], e.data.message[2]];
				case 'version':
					if (e.data.message[1] != freyVersion) {
						client = null;
						newFreyVersion = e.data.message[1];
						FlxG.switchState(new OutdatedState());
					}
				case "sync":
				 PlayState.instance.forceTime(e.data.message[1]);
				case "BRO HES DEAD":
					PlayState.instance.endSong();
				case "getRating":
					var dharmann:Rating = e.data.message[2];
					PlayState.instance.popupOpponentScore(dharmann, e.data.message[1]);
				case "loadNewSong":
					PlayState.SONG = Song.loadFromJson(e.data.message[1], e.data.message[2]);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = e.data.message[3];

					LoadingState.loadAndSwitchState(new PlayState());
					default:
						trace('unknown prompt '+ e.data.message[0]);
			}
		  });
	}
	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
