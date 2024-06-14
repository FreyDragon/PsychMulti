package states;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxInputText;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import states.FreeplayState;
import options.OptionsState;
import flixel.addons.ui.FlxUICheckBox;
import flixel.util.FlxColor;
class ConnectionState extends FlxState {
    var coolServerButton:FlxButton;
    var coolClientButton:FlxButton;
    var coolIpBox:FlxInputText;
    var coolPortBox:FlxInputText;
    var coolTimer:FlxTimer;
    var coolDeathToggle:FlxUICheckBox;
    static public var instance:ConnectionState;
    override public function new() {
        super();
        ConnectionState.instance = this;
        FlxG.mouse.enabled = true;
        FlxG.mouse.visible = true;
        FlxG.autoPause = false;
        coolDeathToggle = new FlxUICheckBox(500, 500, new FlxSprite().makeGraphic(64, 64, FlxColor.WHITE), new FlxSprite().makeGraphic(32, 32, FlxColor.BLACK), "Allow Death?\nFull white square\nmeans yes.", 150, [null], function()
            {
                if (Main.allowDeath) {
                    Main.allowDeath = false;
                } else {
                    Main.allowDeath = true;
                }
            });
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
        add(coolDeathToggle);
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
    public function setText(textVar:String = "there was text here\n but it failed to load!", xVar:Dynamic = 500, yVar:Dynamic = 200){
        var tempText = new FlxText(xVar, yVar, 0, textVar, 16);
        add(tempText);
    }
}