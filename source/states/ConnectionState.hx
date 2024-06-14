package states;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxInputText;
import flixel.FlxState;
import flixel.ui.FlxButton;
import states.FreeplayState;
import options.OptionsState;
class ConnectionState extends FlxState {
    var coolServerButton:FlxButton;
    var coolClientButton:FlxButton;
    var coolIpBox:FlxInputText;
    var coolPortBox:FlxInputText;
    var coolTimer:FlxTimer;
    override public function new() {
        super();
        FlxG.mouse.enabled = true;
        FlxG.mouse.visible = true;
        FlxG.autoPause = false;
        coolServerButton = new FlxButton(100, 300, "Start Server", clickServer);
        var coolSettingsButton = new FlxButton(500, 300, "Change Settings", clickSettings);
        coolClientButton = new FlxButton(100, 400, "Join Server", clickClient);
        coolIpBox = new FlxInputText(100, 500, 200, "Server IP");
        coolPortBox = new FlxInputText(100, 600, 100, "Port");
        add(coolServerButton);
        add(coolClientButton);
        add(coolSettingsButton);
        add(coolIpBox);
        add(coolPortBox);
    }
    function clickServer():Void {
        Main.instance.startServer(Std.parseInt(coolPortBox.text));
        coolTimer = new FlxTimer().start(0.005, function(tmr:FlxTimer)
            {
                if (Main.instance.successfulConnect) {
                    FlxG.switchState(new FreeplayState());
                    coolTimer.cancel();
                }
            }, 0);
    }
    function clickSettings():Void {
    MusicBeatState.switchState(new OptionsState());
    OptionsState.onPlayState = false;
    }
    function clickClient():Void {
        Main.instance.startClient(coolIpBox.text, Std.parseInt(coolPortBox.text));
        coolTimer = new FlxTimer().start(0.005, function(tmr:FlxTimer)
            {
                if (Main.instance.successfulConnect) {
                    FlxG.switchState(new FreeplayState());
                    coolTimer.cancel();
                }
            }, 0);
    }
}