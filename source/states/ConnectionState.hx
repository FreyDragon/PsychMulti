package states;

import flixel.addons.ui.FlxInputText;
import flixel.FlxState;
import flixel.ui.FlxButton;
import states.FreeplayState;
class ConnectionState extends FlxState {
    var coolServerButton:FlxButton;
    var coolClientButton:FlxButton;
    var coolIpBox:FlxInputText;
    var coolPortBox:FlxInputText;

    override public function new() {
        super();
        FlxG.mouse.enabled = true;
        FlxG.mouse.visible = true;
        FlxG.autoPause = false;
        coolServerButton = new FlxButton(100, 300, "Start Server", clickServer);
        coolClientButton = new FlxButton(100, 400, "Join Server", clickClient);
        coolIpBox = new FlxInputText(100, 500, 200, "Server IP");
        coolPortBox = new FlxInputText(100, 600, 100, "Port");
        add(coolServerButton);
        add(coolClientButton);
        add(coolIpBox);
        add(coolPortBox);
    }
    function clickServer():Void {
        Main.instance.startServer(Std.parseInt(coolPortBox.text));
        FlxG.switchState(new FreeplayState());
    }
    function clickClient():Void {
        Main.instance.startClient(coolIpBox.text, Std.parseInt(coolPortBox.text));
        FlxG.switchState(new FreeplayState());
    }
}