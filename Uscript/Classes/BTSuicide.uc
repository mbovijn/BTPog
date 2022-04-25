class BTSuicide extends Info;

var PlayerPawn PlayerPawn;

var bool IsSuicide;
var bool IsFire;
var Mover SelectedMover;
var float SelectedTimePoint;

var float MoverPeriodTime;
var byte PreviousKeyNum;
var float TimeSinceKeyNumTransition0To1;
var int AmountOfMoverLoops;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 2))
	{
		case "suicide":
			Suicide();
			break;
		case "fire":
			Fire();
			break;
		case "select":
			SelectMover();
			break;
		case "time":
			switch (class'Utils'.static.GetArgument(MutateString, 3))
			{
				case "":
					SelectTimePoint(TimeSinceKeyNumTransition0To1);
					break;
				default: SelectTimePoint(float(class'Utils'.static.GetArgument(MutateString, 3)));
			}
			break;
		default:
	}
}

function Tick(float DeltaTime)
{
    if (SelectedMover != None)
    {
        // Keeping track of:
        //   - The amount time passed since the mover transitioned from KeyNum 0 to 1.
        //   - The total time it takes for the mover to do a full loop.
        //   - The amount of times the mover looped.
        TimeSinceKeyNumTransition0To1 += Deltatime;
        if (SelectedMover.KeyNum == 1 && PreviousKeyNum == 0)
        {
            MoverPeriodTime = TimeSinceKeyNumTransition0To1;
            TimeSinceKeyNumTransition0To1 = 0;
            if (AmountOfMoverLoops < 2) AmountOfMoverLoops++;
        }
        PreviousKeyNum = SelectedMover.KeyNum;

        // Checking if this is the tick we have to suicide.
        if ((IsFire || IsSuicide)
            && SelectedTimePoint < TimeSinceKeyNumTransition0To1
            && TimeSinceKeyNumTransition0To1 < (SelectedTimePoint + 2*DeltaTime) % MoverPeriodTime)
        {
            if (IsFire)
            {
                PlayerPawn.Fire();
                IsFire = false;
            }
            else if (IsSuicide)
            {
                PlayerPawn.KilledBy(None);
                IsSuicide = false;
            }
        }
    }
}

function Fire()
{
    if (SelectedMover == None || SelectedTimePoint == 0)
    {
        ClientMessage("First select a mover and time point.");
        return;
    }

    IsFire = true;
}

function Suicide()
{
    if (SelectedMover == None || SelectedTimePoint == 0)
    {
        ClientMessage("First select a mover and time point.");
        return;
    }

    IsSuicide = true;
}

function SelectMover()
{
    MoverPeriodTime = 0;
    AmountOfMoverLoops = 0;
    TimeSinceKeyNumTransition0To1 = 0;
    SelectedTimePoint = 0;

    SelectedMover = GetTargettedMover(PlayerPawn);
    if (SelectedMover == None)
    {
        ClientMessage("No mover selected. Aim at a mover, and try again.");
        return;
    }

    PreviousKeyNum = SelectedMover.KeyNum;
    ClientMessage("Selected mover with tag "$SelectedMover.Tag);
}

function SelectTimePoint(float TimePoint)
{
    if (SelectedMover == None)
    {
        ClientMessage("No time point selected. First select a mover.");
        return;
    }

    if (AmountOfMoverLoops < 2)
    {
        ClientMessage("Mover period time is being determined. Try again.");
        return;
    }

    if (TimePoint > MoverPeriodTime)
    {
        ClientMessage("Pick a time point smaller than the mover period time of "$MoverPeriodTime);
        return;
    }

    SelectedTimePoint = TimePoint;
    ClientMessage("Selected time point "$SelectedTimePoint$" for mover with period "$MoverPeriodTime);
}

// Taken from https://github.com/bunnytrack/TriggerMover
function Mover GetTargettedMover(PlayerPawn Sender)
{
	local Actor HitActor;
	local vector X, Y, Z, HitLocation, HitNormal, EndTrace, StartTrace;
	local Mover HitMover;

	GetAxes(Sender.ViewRotation, X, Y, Z);

	StartTrace = Sender.Location + Sender.EyeHeight * vect(0, 0, 1);
	EndTrace = StartTrace + X * 10000;

	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
	HitMover = Mover(HitActor);

	return HitMover;
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}
