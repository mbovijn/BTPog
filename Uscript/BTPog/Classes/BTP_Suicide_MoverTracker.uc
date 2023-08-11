class BTP_Suicide_MoverTracker extends Info;

var PlayerPawn PlayerPawn;
var Mover Mover;
var float TimePoint;
var float Alpha;
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

function Print(int Index)
{
    ClientMessage("Index = "$Index$", Name = "$Mover.Name$", Time = "$class'BTP_Misc_Utils'.static.FloatToString(TimePoint, 3)
                    $", Alpha = "$class'BTP_Misc_Utils'.static.FloatToString(Alpha, 3));
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
    return (TimePoint - Alpha) % Period < TimeSinceKeyNumTransition0To1
            && TimeSinceKeyNumTransition0To1 < (TimePoint + 2*DeltaTime + Alpha) % Period;
}

function SetAlpha(float NewAlpha)
{
    if (AmountOfLoops < 2)
    {
        ClientMessage("Please wait until the period of the mover has been determined, and try again");
        return;
    }

    if (NewAlpha < 0 || NewAlpha > Period/2)
    {
        ClientMessage("Specify an alpha value between 0 and "$class'BTP_Misc_Utils'.static.FloatToString(Period/2, 3));
        return;
    }

    Alpha = NewAlpha;
    ClientMessage("Configured alpha value "$class'BTP_Misc_Utils'.static.FloatToString(Alpha, 3)$" for mover "$Mover.Name);
}

function SetTimePoint(string OptionalTimePoint)
{
    local float TempTimePoint;

    if (AmountOfLoops < 2)
    {
        ClientMessage("Please wait until the period of the mover has been determined, and try again");
        return;
    }

    if (OptionalTimePoint == "")
        TempTimePoint = TimeSinceKeyNumTransition0To1;
    else
        TempTimePoint = float(OptionalTimePoint);

    if (TempTimePoint < 0 || TempTimePoint > Period)
    {
        ClientMessage("Time point has to be between 0 and the mover period (="$class'BTP_Misc_Utils'.static.FloatToString(Period, 3)$")");
        return;
    }

    TimePoint = TempTimePoint;
    ClientMessage("Configured time point "$class'BTP_Misc_Utils'.static.FloatToString(TimePoint, 3)
                    $" for mover "$Mover.Name$" with period "$class'BTP_Misc_Utils'.static.FloatToString(Period, 3));
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}
