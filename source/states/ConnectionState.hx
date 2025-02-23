package states;
import objects.menus.ClickableSpriteButton;
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
    var coolIpBox:FlxInputText;
    var coolPortBox:FlxInputText;
    var coolTimer:FlxTimer;
    var coolDeathToggle:FlxUICheckBox;
    var settingsButton:ClickableSpriteButton;
    var serverButton:ClickableSpriteButton;
    var clientButton:ClickableSpriteButton;
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
        
        coolIpBox = new FlxInputText(500, 250, 500, "Server IP", 30);
        coolPortBox = new FlxInputText(500, 125, 500, "Port", 30);
        add(coolIpBox);
        add(coolPortBox);
        add(coolDeathToggle);
        settingsButton = new ClickableSpriteButton("Settings");
        serverButton = new ClickableSpriteButton("Host Game");
        clientButton = new ClickableSpriteButton("Join Game");
        settingsButton.setPositions(25, 25);
        serverButton.setPositions(25, 125);
        clientButton.setPositions(25, 225);
        add(settingsButton);
        add(serverButton);
        add(clientButton);
    }
    override function update(elapsed:Float) {
        if (settingsButton.isClicked)
            clickSettings();
        if (serverButton.isClicked)
            clickServer();
        if (clientButton.isClicked)
            clickClient();
        super.update(elapsed);
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
    public function setText(textVar:String = "there was text here\n but it failed to load!", xVar:Dynamic = 500, yVar:Dynamic = 25) {
        var tempText = new FlxText(xVar, yVar, 0, textVar, 16);
        add(tempText);
    }
}