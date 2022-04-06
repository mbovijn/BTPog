class BTGhostRecorder extends Actor;

var PlayerPawn PlayerPawn;

var float Delta;
var float DeltaCountdown;

var vector Positions[2048];
var int Offset;
var float CapTime;

var vector TempPositions[2048];
var int TempOffset;
var float StartTimeOfRun;

// function PreBeginPlay()
// {
//     local CTFFlag  CTFFlag;
//     local FlagBase FlagBase;

//     PlayerPawn = PlayerPawn(Owner);

//     Tag = 'Boi';

//     PlayerPawn.ClientMessage("The tag is "$Tag$" with role "$Role);

//     foreach allactors(class'CTFFlag', CTFFlag)
//     {
//         CTFFlag.HomeBase.Event = Tag;
//         PlayerPawn.ClientMessage("Found CTFFlag! "$CTFFlag.HomeBase.Event);
//     }

//     foreach allactors(class'FlagBase', FlagBase)
//     {
//         FlagBase.Event = Tag;
//         PlayerPawn.ClientMessage("Found FlagBase! "$FlagBase.Event);
//     }
// }

//EDITACTOR CLASS=<classname>
//EDITACTOR NAME=<objectname>


// doesn't work client or server side for some reason
simulated event Trigger(Actor Other, Pawn EventInstigator)
{
    PlayerPawn.ClientMessage("It workssss with role "$Role);
}


simulated function PlayerCappedEvent() // Need to get a notification somehow..
{
    // local int i;
    // // if (Level.TimeSeconds - StartTimeOfRun < CapTime)
    // // {
    //     for (i = 0; i <= TempOffset; i++)
    //         Positions[i] = TempPositions[i];
    //     Offset = TempOffset;
    //     CapTime = Level.TimeSeconds - StartTimeOfRun;
    //     PlayerPawn.ClientMessage("We stored the run with offset="$Offset);
    // }
}

simulated function PlayerSpawnedEvent() // does this also work after capping the flag? besides suicide or death
{
    // StartTimeOfRun = Level.TimeSeconds;
    // TempOffset = 0;
    // DeltaCountdown = -1; // So next tick it'll start picking up the position.
    // PlayerPawn.ClientMessage("Let's go baby!");
}

simulated function Tick(float DeltaTime)
{
    if (Role == ROLE_Authority)
        return;
    
    // if (DeltaCountdown < 0)
    // { 
    //     if (TempOffset < ArrayCount(TempPositions))
    //     {
    //         TempPositions[TempOffset] = PlayerPawn.Location;
    //         if (TempOffset < ArrayCount(TempPositions) - 1) TempOffset++;
    //     }
    //     DeltaCountdown = Delta;
    // }
    // DeltaCountdown -= DeltaTime;
}

defaultproperties
{
    CapTime=999999
    Delta=0.1
    DeltaCountdown=0.1
    RemoteRole=ROLE_SimulatedProxy
    Tag='Boi'
}
