package states;
import flixel.ui.FlxButton;
import states.TitleState;
class ScoreOverviewState extends MusicBeatState
{
    var scoreComparison:FlxText;
    var accComparison:FlxText;
    var overallComparison:FlxText;
    static public var instance:ScoreOverviewState;
    override public function create():Void
        {
            instance = this;
            super.create();
            Main.instance.initCalcScore();
            new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new TitleState());
				});
        }
    public function calculateRankings(p1score:Int = 0, p1acc:Float = 0.0, p2score:Int = 0, p2acc:Float = 0.0) {
        var scoreComparisontext = "hi";
        var accComparisontext = "hi";
        var overallComparisontext = "hi";
        var accWinner = -1;
        var scoreWinner = -1;
        if (p1score == p2score) {
            scoreComparisontext = "Opponent tied with Boyfriend for a score of " + p1score + "!";
        } else if (p1score >= p2score) {
            scoreComparisontext = "Opponent beat Boyfriend's score of " + p2score + " with a score of " + p1score + "!";
            scoreWinner = 1;
        } else {
            scoreComparisontext = "Boyfriend beat Opponent's score of " + p1score + " with a score of " + p2score + "!";
            scoreWinner = 2;
        }
        if (p1acc == p2acc) {
            accComparisontext = "Opponent tied with Boyfriend for an accuracy of " + p1acc + "!";
            accWinner = 1;
        } else if (p1acc >= p2acc) {
            accComparisontext = "Opponent beat Boyfriend's accuracy of " + p2acc + " with an accuracy of " + p1acc + "!";
            accWinner = 2;
        } else {
            accComparisontext = "Boyfriend beat Opponent's accuracy of " + p1acc + " with an accuracy of " + p2acc + "!";
        }
        var absolutep1 = p1acc * p1score;
        var absolutep2 = p2acc * p2score;
        var winner = -1;
        var opponentWinsArray = new Array<Bool>();
        if (absolutep1 == absolutep2) {
            winner = 3;
        } else if (absolutep1 >= absolutep2) {
            winner = 1;
        } else {
            winner = 2;
        }
        opponentWinsArray.push(winner == 1);
        opponentWinsArray.push(accWinner == 1);
        opponentWinsArray.push(scoreWinner == 1);
        switch(opponentWinsArray) {
            case [true, true, true]:
                overallComparisontext = "Opponent wins in a landslide! \nOpponent had a higher accuracy of " + p1acc + "\nAND a higher score of " + p1score + "!";
            case [true, true, false]:
                overallComparisontext = "Opponent wins! \nOpponent had a higher accuracy of " + p1acc + "\nbut a lower score of " + p1score + "!";
            case [true, false, true]:
                overallComparisontext = "Opponent wins! \nOpponent had a higher score of " + p1score + "\nbut a lower accuracy of " + p1acc + "!";
            case [false, false, false]:
                overallComparisontext = "Boyfriend wins in a landslide! \nBoyfriend had a higher accuracy of " + p2acc + "\nAND a higher score of " + p2score + "!";
            case [false, true, false]:
                overallComparisontext = "Boyfriend wins! \nBoyfriend had a higher accuracy of " + p2acc + "\nbut a lower score of " + p2score + "!";
            case [false, false, true]:
                overallComparisontext = "Boyfriend wins! \nBoyfriend had a higher score of " + p2score + "\nbut a lower accuracy of " + p2acc + "!";
            default:
                overallComparisontext = "Something seems to be wrong, \nOR there is a tie\nDid opponent win? \nDid opponent score more?" + opponentWinsArray[2] + "\ndid opponent have more accuracy?" + opponentWinsArray[1] + "\nIF THERE SHOULD BE A WINNER, \nreport this to the mod's \n issue tracker!!!!! \n https://github.com/FreyDragon/PsychMulti/issues";
        }
        overallComparison = new FlxText(100, 100, 0, overallComparisontext, 30);
        add(overallComparison);
        accComparison = new FlxText(100, 250, 0, accComparisontext, 30);
        add(accComparison);
        scoreComparison = new FlxText(100, 400, 0, scoreComparisontext, 30);
        add(scoreComparison);
    }
	override function update(elapsed:Float)
        {
            super.update(elapsed);
        }
}