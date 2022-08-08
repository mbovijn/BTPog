class BTSuicideMoverTracker extends Info;

var PlayerPawn PlayerPawn;
var Mover Mover;
var float TimePoint;
var float Period;

var byte PreviousKeyNum;
var float TimeSinceKeyNumTransition0To1;

var int AmountOfLoops;

function Init(PlayerPawn aPlayerPawn, Mover aMover)
{
    PlayerPawn = aPlayerPawn;
    Mover = aMover;
    PreviousKeyNum = aMover.KeyNum;
}

function CustomTick(float DeltaTime)
{
    TimeSinceKeyNumTransition0To1 += Deltatime;
    if (Mover.KeyNum == 1 && PreviousKeyNum == 0)
    {
        Period = TimeSinceKeyNumTransition0To1;
        TimeSinceKeyNumTransition0To1 = 0;
        if (AmountOfLoops < 2) AmountOfLoops++;
    }
    PreviousKeyNum = Mover.KeyNum;
}

function bool CanSuicide(float DeltaTime)
{
    return TimePoint < TimeSinceKeyNumTransition0To1
            && TimeSinceKeyNumTransition0To1 < (TimePoint + 2*DeltaTime) % Period;
}

function SetTimePoint(string optionalTimePoint)
{
    local float tempTimePoint;

    if (AmountOfLoops < 2)
    {
        ClientMessage("Please wait until the period of the mover has been determined, and try again");
        return;
    }

    if (optionalTimePoint == "")
        tempTimePoint = TimeSinceKeyNumTransition0To1;
    else
        tempTimePoint = float(optionalTimePoint);

    if (tempTimePoint < 0 || tempTimePoint > Period)
    {
        ClientMessage("Time point has to be between 0 and the mover period (="$class'Utils'.static.FloatToString(Period, 3)$")");
        return;
    }

    TimePoint = tempTimePoint;
    ClientMessage("Configured time point "$class'Utils'.static.FloatToString(TimePoint, 3)
                    $" for mover with period "$class'Utils'.static.FloatToString(Period, 3));
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}
