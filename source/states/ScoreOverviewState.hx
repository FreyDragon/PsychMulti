package states;
import flixel.ui.FlxButton;
import states.TitleState;
import states.FreeplayState;
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
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
                    //timer so game has time to not crash!
                    Main.instance.initCalcScore();
				});
            new FlxTimer().start(10, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new FreeplayState());
				});
        }
    public function calculateRankings(p1score:Dynamic = 0, p1acc:Dynamic = 0.0, p3score:Dynamic = 0, p3acc:Dynamic = 0.0) {
        if (p1score != null && p1acc != null && p3score != null && p3acc != null) {
        var scoreComparisontext = "hi";
        var accComparisontext = "hi";
        var overallComparisontext = "hi";
        var accWinner = -1;
        var scoreWinner = -1;
        var p2score:Dynamic = 0;
        var p2acc:Dynamic = 0.0;
        if (Main.instance.serverstate == 'server') {
            p2acc = p3acc;
            p2score = p3score;
        } else {
            p2acc = p1acc;
            p2score = p1score;
            p1acc = p3acc;
            p1score = p3score;
        }
        if (p1score == p2score) {
            scoreComparisontext = "Opponent tied with Boyfriend for a score of " + p1score + "!";
        } else if (p1score >= p2score) {
            scoreComparisontext = "Opponent beat Boyfriend's score of " + p2score + " \nwith a score of " + p1score + "!";
            scoreWinner = 1;
        } else if (p1score <= p2score) {
            scoreComparisontext = "Boyfriend beat Opponent's score of " + p1score + " \nwith a score of " + p2score + "!";
            scoreWinner = 2;
        }
        if (p1acc == p2acc) {
            accComparisontext = "Opponent tied with Boyfriend for an accuracy of " + p1acc * 100 + "%!";
        } else if (p1acc >= p2acc) {
            accComparisontext = "Opponent beat Boyfriend's accuracy of " + p2acc * 100 + "%\nwith an accuracy of " + p1acc * 100 + "%!";
            accWinner = 1;
        } else if (p1acc <= p2acc) {
            accComparisontext = "Boyfriend beat Opponent's accuracy of " + p1acc * 100 + "%\nwith an accuracy of " + p2acc * 100 + "%!";
            accWinner = 2;
        }
        var absolutep1 = (p1acc * 100) * (p1score / 10);
        var absolutep2 = (p2acc * 100) * (p2score / 10);
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
                overallComparisontext = "Opponent wins in a landslide! \nOpponent had a higher accuracy of " + p1acc * 100 + "%\nAND a higher score of " + p1score + "!";
            case [true, true, false]:
                overallComparisontext = "Opponent wins! \nOpponent had a higher accuracy of " + p1acc * 100 + "%\nbut a lower score of " + p1score + "!";
            case [true, false, true]:
                overallComparisontext = "Opponent wins! \nOpponent had a higher score of " + p1score + "\nbut a lower accuracy of " + p1acc * 100 + "%!";
            case [false, false, false]:
                overallComparisontext = "Boyfriend wins in a landslide! \nBoyfriend had a higher accuracy of " + p2acc * 100 + "%\nAND a higher score of " + p2score + "!";
            case [false, false, true]:
                overallComparisontext = "Boyfriend wins! \nBoyfriend had a higher accuracy of " + p2acc * 100 + "%\nbut a lower score of " + p2score + "!";
            case [false, true, false]:
                overallComparisontext = "Boyfriend wins! \nBoyfriend had a higher score of " + p2score + "\nbut a lower accuracy of " + p2acc * 100 + "%!";
            default:
                overallComparisontext = "Something seems to be wrong, \nOR there is a tie\nDid opponent win? \nDid opponent score more?" + opponentWinsArray[2] + "\ndid opponent have more accuracy?" + opponentWinsArray[1] + "\nIF THERE SHOULD BE A WINNER, \nreport this to the mod's \n issue tracker!!!!! \n https://github.com/FreyDragon/PsychMulti/issues";
        }
        overallComparison = new FlxText(100, 100, 0, overallComparisontext, 30);
        add(overallComparison);
        accComparison = new FlxText(100, 250, 0, accComparisontext, 30);
        add(accComparison);
        scoreComparison = new FlxText(100, 400, 0, scoreComparisontext, 30);
        add(scoreComparison);
        } else {
            overallComparison = new FlxText(100, 100, 0, "Score cannot be compared\nNull object almost crashed game!\nReport this to the mod's \n issue tracker!!!!! \n https://github.com/FreyDragon/PsychMulti/issues", 30);
            add(overallComparison);
        }
    }
	override function update(elapsed:Float)
        {
            super.update(elapsed);
        }
}