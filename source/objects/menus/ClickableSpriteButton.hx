package objects.menus;
import flixel.input.mouse.FlxMouse;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
class ClickableSpriteButton extends FlxTypedSpriteGroup<FlxSprite> {
    public var isHovered = false;
    public var isClicked = false;
    public var imageSPR:FlxSprite;
    public var imageSPR2:FlxSprite;
    var txtSPR:FlxText;
    override public function new(buttonText:String = "Test Button") {
        super();
        imageSPR2 = new FlxSprite(5, 5).makeGraphic(390, 65, FlxColor.BLACK);
        imageSPR = new FlxSprite(0, 0).makeGraphic(400, 75, FlxColor.WHITE);
        add(imageSPR);
        add(imageSPR2);
        txtSPR = new FlxText(10, 10, 380, buttonText, 35);
        add(txtSPR);
    }
    public function setPositions(xv:Int = 0, yv:Int = 0) {
        imageSPR.setPosition(xv, yv);
        imageSPR2.setPosition(xv + 5, yv + 5);
        txtSPR.setPosition(xv + 10, yv + 10);
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        isHovered = FlxG.mouse.overlaps(this);
        isClicked = FlxG.mouse.justPressed && isHovered;
        if (isHovered) {
            scale.set(1.1, 1.1);
        } else {
            scale.set(1, 1);
        }

    }
    
}