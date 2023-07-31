class BTStatsInventory extends TournamentWeapon;

var BTStats BTStats;

var float TimestampFirstInput;
var float TimestampLastInput;

var int AmountOfTicksWithInput;
var int AmountOfTicksUntilLastInput;
var int AmountOfTicks;

var bool IsRecording;

var bool BTPogInputTestTriggered;

replication
{
	reliable if (Role == ROLE_Authority)
		BTStats;
}

simulated function Tick(float DeltaTime)
{
    if (Role == ROLE_Authority || !BTStats.ClientSettings.IsActive) return;

    if (BTPogInputTestTriggered && !IsRecording) Start();

    AmountOfTicks++;

    if (BTPogInputTestTriggered)
    {
        TimestampLastInput = Level.TimeSeconds;
        AmountOfTicksWithInput++;
        AmountOfTicksUntilLastInput = AmountOfTicks;
    }

    if (IsRecording)
    {
        if (BTStats.ClientSettings.IsDebugging) LogHorizontalSpeed();
        if ((Level.TimeSeconds - TimestampLastInput) > 0.5) Finish();
    }

    BTPogInputTestTriggered = False;
}

simulated function LogHorizontalSpeed()
{
    local float Speed2D, Accel2D;

    local PlayerPawn Player;
    Player = PlayerPawn(Owner);

    Speed2D = Sqrt(Player.Velocity.X * Player.Velocity.X + Player.Velocity.Y * Player.Velocity.Y);
    Accel2D = Sqrt(Player.Acceleration.X * Player.Acceleration.X + Player.Acceleration.Y * Player.Acceleration.Y);
    Log("[BTPog/BTStats/InputTest] - Height=" $ Player.Location.Z $ " Accel2D=" $ Accel2D $ " Speed2D=" $ Speed2D $ " Input=" $ BTPogInputTestTriggered
            $ " Phys=" $ GetEnum(enum'EPhysics', Player.Physics) $ " Velocity.Z=" $ Player.Velocity.Z);
}

simulated exec function BTPogInputTest()
{
    if (Role == ROLE_Authority)
    {
        Log("[BTPog/BTStats/InputTest] Should only execute on the client.");
        return;
    }

    BTPogInputTestTriggered = True;
}

simulated function Start() // aka reset vars
{
    IsRecording = True;

    AmountOfTicks = 0;
    AmountOfTicksWithInput = 0;
    AmountOfTicksUntilLastInput = 0;
    
    TimestampFirstInput = Level.TimeSeconds;
    TimestampLastInput = Level.TimeSeconds;
}

simulated function Finish() // do calc with current vars and publish results
{
    IsRecording = False;

    BTStats.InputTestTicks = AmountOfTicksUntilLastInput;
    BTStats.InputTestTicksWithInput = AmountOfTicksWithInput;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    bGameRelevant=True
    bHidden=True
}
