class BTGhostPlayer extends Actor;

var PlayerPawn PlayerPawn;

var BTGhostPuppet Puppet;
var int ReplayIndex;

var vector Positions[2048];
var int Offset;
var float CapTime;

var float Delta;
var float DeltaCountdown;

simulated function PostNetBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

simulated function PlayerCappedEvent() // actually, how do we know if the player capped? -> Teams[Scorer.PlayerReplicationInfo.Team].Score in CTFGame, how to get CTFGame? Level.Game
{
}

simulated function PlayerSpawnedEvent()
{
}

simulated function Tick(float DeltaTime)
{
    if (Role == ROLE_Authority)
        return;

    // if (CapTime != 0)
    // {
    //     if (Puppet == None) Puppet = Spawn(class'BTGhostPuppet', Owner, , Positions[ReplayIndex]);
    //     Puppet.SetLocation(Interpolate(Positions[ReplayIndex], Positions[ReplayIndex+1], 1 - (DeltaCountdown/Delta)));
    // }
    
    // if (DeltaCountdown < 0)
    // {
    //     if (CapTime != 0)
    //     {
    //         ReplayIndex++;
    //     }

    //     DeltaCountdown = Delta;
    // }
    // DeltaCountdown -= DeltaTime;
}

simulated function vector Interpolate(vector Origin, vector Target, float Alpha)
{
    local vector NewVector;
    NewVector.X = Origin.X + ((Target.X - Origin.X)*Alpha);
    NewVector.Y = Origin.Y + ((Target.Y - Origin.Y)*Alpha);
    NewVector.Z = Origin.Z + ((Target.Z - Origin.Z)*Alpha);
    return NewVector;
}

defaultproperties
{
    CapTime=999999
    Delta=0.1
    DeltaCountdown=0.1
    RemoteRole=ROLE_SimulatedProxy
}
