class BTP_Stats_Main extends Info dependson(BTP_Stats_Structs);

var PlayerPawn PlayerPawn;

var BTP_Stats_ClientConfig ClientConfig; // CLIENT VAR
var BTP_Stats_Structs.ClientConfigDto ClientConfigDto; // SERVER VAR

var BTP_Stats_Inventory StatsInventory;

var EDodgeDir PreviousDodgeDir;
var float PreviousDodgeClickTimer;
var float StoppedDodgingTimestamp;
var float DodgeBlockDuration;
var float DodgeDoubleTapInterval;
var float TimeBetweenTwoDodges;

var int KeyPressesBeforeDodge;
var int KeyPressesAfterDodge;

var EDodgeDir LastDodgeDirection;
var float LastDodgeTimestamp;

var int ForwardKeyPressCounter;
var float MostRecentForwardKeyPress;
var int BackKeyPressCounter;
var float MostRecentBackKeyPress;
var int LeftKeyPressCounter;
var float MostRecentLeftKeyPress;
var int RightKeyPressCounter;
var float MostRecentRightKeyPress;

var EPhysics PreviousPhysics;
var float StartedFallingTimestamp;
var float AirTime;
var float StartedWalkingTimestamp;
var float GroundTime;

var bool PlayerJustSpawned;

var int InputTestTicks;
var int InputTestTicksWithInput;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, ToggleIsActive, ToggleIsDebugging, PlayerSpawnedEventToClient;
	reliable if (Role < ROLE_Authority)
		ReplicateConfigToServer;
}

simulated function PreBeginPlay()
{
	local Object Obj;

	PlayerPawn = PlayerPawn(Owner);

	if (Role < ROLE_Authority)
	{
		Obj = new (none, 'BTPog') class'Object';
		ClientConfig = new (Obj, 'Stats_ClientConfig') class'BTP_Stats_ClientConfig';
		ClientConfig.SaveConfig();

		ReplicateConfigToServer(ClientConfig.GetClientConfig());
	}
}

function ReplicateConfigToServer(BTP_Stats_Structs.ClientConfigDto aClientConfigDto)
{
	ClientConfigDto = aClientConfigDto;
}

function InitStatsInventory()
{
	StatsInventory = Spawn(class'BTP_Stats_Inventory', Owner);
	StatsInventory.BTP_Stats_Main = Self;

	PlayerPawn.AddInventory(StatsInventory);
}

function ExecuteCommand(string MutateString)
{
	switch(class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString))
	{
		case "debug":
			ToggleIsDebugging();
			break;
		default:
            ToggleIsActive();
            break;
	}
}

function PlayerSpawnedEvent()
{
	if (ClientConfigDto.IsActive) InitStatsInventory(); // The engine destroys this on death.
	PlayerSpawnedEventToClient();
}

simulated function PlayerSpawnedEventToClient()
{
	PlayerJustSpawned = True;
}

simulated function ToggleIsActive()
{
    ClientConfig.IsActive = !ClientConfig.IsActive;
    ClientConfig.SaveConfig();

	ReplicateConfigToServer(ClientConfig.GetClientConfig());
}

simulated function ToggleIsDebugging()
{
    ClientConfig.IsDebugging = !ClientConfig.IsDebugging;
    ClientMessage("Stats Debugging Enabled = "$ClientConfig.IsDebugging);
    ClientConfig.SaveConfig();

	ReplicateConfigToServer(ClientConfig.GetClientConfig());
}

simulated function CustomTick(float DeltaTime)
{
    local string Messages[7];

	if (Role == ROLE_Authority || (!ClientConfig.IsActive && !ClientConfig.IsDebugging)) return;

	UpdateStats(DeltaTime);

	if (ClientConfig.IsActive)
	{
		Messages[0] = "Dodge Double Tap Interval = "$class'BTP_Misc_Utils'.static.TimeDeltaToString(DodgeDoubleTapInterval, Level.TimeDilation)$"s";
		Messages[1] = "Dodge Block Duration = "$class'BTP_Misc_Utils'.static.TimeDeltaToString(DodgeBlockDuration, Level.TimeDilation)$"s";
		Messages[2] = "Time Between Dodges = "$class'BTP_Misc_Utils'.static.TimeDeltaToString(TimeBetweenTwoDodges, Level.TimeDilation)$"s";
		Messages[3] = "Air Time = "$class'BTP_Misc_Utils'.static.TimeDeltaToString(AirTime, Level.TimeDilation)
						$"s | Ground Time = "$class'BTP_Misc_Utils'.static.TimeDeltaToString(GroundTime, Level.TimeDilation)$"s";
		Messages[4] = "Tick Hit Rate = "$class'BTP_Misc_Utils'.static.FloatToString(float(InputTestTicksWithInput)/InputTestTicks, 3)$" ("$InputTestTicksWithInput$"/"$InputTestTicks$")";
		Messages[5] = "Key Presses Before Dodge = " $ KeyPressesBeforeDodge $ " | Key Presses After Dodge = " $ KeyPressesAfterDodge;
		ClientProgressMessage(Messages);
	}

	if (ClientConfig.IsDebugging)
	{
		Log("[BTPog/Stats] "$PlayerPawn.Health$" - "$GetEnum(enum'EPhysics', PlayerPawn.Physics)$" - "$GetEnum(enum'EDodgeDir', PlayerPawn.DodgeDir)
			$" - "$PlayerPawn.DodgeClickTimer$" - "$DeltaTime$" - "$Level.TimeSeconds);
	}
}

simulated function UpdateStats(float DeltaTime)
{
	if (HasStartedDodging())
	{
		// Using 'PreviousDodgeClickTimer - DeltaTime' here instead of 'PlayerPawn.DodgeClickTimer' since it's possible for the DodgeDir variable to go
		// straight from e.g. DODGE_Forward to DODGE_Done. This can happen when a player dodges against the underside of a slope. For example on the
		// map BT-1545. If DODGE_Done is set the DodgeClickTimer will be equal to 0.
		DodgeDoubleTapInterval = PlayerPawn.DodgeClickTime - (PreviousDodgeClickTimer - DeltaTime);
		TimeBetweenTwoDodges = Level.TimeSeconds - StoppedDodgingTimestamp;
		if (ClientConfig.IsDebugging) LogAndClientMessage("Start of dodge");
	}
	if (HasStoppedDodging())
	{
		StoppedDodgingTimestamp = Level.TimeSeconds;
		if (ClientConfig.IsDebugging) LogAndClientMessage("End of dodge");
	}
	if (IsAfterDodgeBlock())
	{
		DodgeBlockDuration = Level.TimeSeconds - StoppedDodgingTimestamp;
		if (ClientConfig.IsDebugging) LogAndClientMessage("Dodge Block Duration = "$DodgeBlockDuration);
	}

	if (HasStarted(PHYS_Falling))
	{
		StartedFallingTimestamp = Level.TimeSeconds;
	}
	if (HasStopped(PHYS_Falling))
	{
		AirTime = Level.TimeSeconds - StartedFallingTimestamp;
	}
	
	if (HasStarted(PHYS_Walking))
	{
		StartedWalkingTimestamp = Level.TimeSeconds;
	}
	if (HasStopped(PHYS_Walking))
	{
		GroundTime = Level.TimeSeconds - StartedWalkingTimestamp;
	}

	UpdateKeyPressLoggerStat();

	PreviousDodgeDir = PlayerPawn.DodgeDir;
	PreviousPhysics = PlayerPawn.Physics;
	PlayerJustSpawned = False;
	PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
}

simulated function bool HasStarted(EPhysics Physics)
{
	return PreviousPhysics != Physics && PlayerPawn.Physics == Physics;
}

simulated function bool HasStopped(EPhysics Physics)
{
	return PreviousPhysics == Physics && PlayerPawn.Physics != Physics;
}

simulated function bool HasStartedDodging()
{
	return (PreviousDodgeDir == DODGE_Forward || PreviousDodgeDir == DODGE_Back || PreviousDodgeDir == DODGE_Left || PreviousDodgeDir == DODGE_Right)
				&& (PlayerPawn.DodgeDir == DODGE_Active || PlayerPawn.DodgeDir == DODGE_Done);
}

simulated function bool HasStoppedDodging()
{
	return (PreviousDodgeDir == DODGE_Forward || PreviousDodgeDir == DODGE_Back || PreviousDodgeDir == DODGE_Left || PreviousDodgeDir == DODGE_Right || PreviousDodgeDir == DODGE_Active)
				&& PlayerPawn.DodgeDir == DODGE_Done;
}

simulated function bool IsAfterDodgeBlock()
{
	return PreviousDodgeDir == DODGE_Done && PlayerPawn.DodgeDir == DODGE_None && !PlayerJustSpawned && PreviousPhysics != PHYS_None;
}

simulated function UpdateKeyPressLoggerStat()
{
	if (PlayerPawn.bWasForward && PlayerPawn.bEdgeForward)
	{
		ForwardKeyPressCounter++;
		MostRecentForwardKeyPress = Level.TimeSeconds;
	}
	if (PlayerPawn.bWasBack && PlayerPawn.bEdgeBack)
	{
		BackKeyPressCounter++;
		MostRecentBackKeyPress = Level.TimeSeconds;
	}
	if (PlayerPawn.bWasLeft && PlayerPawn.bEdgeLeft)
	{
		LeftKeyPressCounter++;
		MostRecentLeftKeyPress = Level.TimeSeconds;
	}
	if (PlayerPawn.bWasRight && PlayerPawn.bEdgeRight)
	{
		RightKeyPressCounter++;
		MostRecentRightKeyPress = Level.TimeSeconds;
	}
	
	if (PlayerPawn.DodgeDir == DODGE_Active)
	{
		if (PreviousDodgeDir == DODGE_Forward)
		{
			LastDodgeDirection = DODGE_Forward;
			LastDodgeTimestamp = Level.TimeSeconds;

			KeyPressesBeforeDodge = ForwardKeyPressCounter;
			ForwardKeyPressCounter = 0;
		}
		else if (PreviousDodgeDir == DODGE_Back)
		{
			LastDodgeDirection = DODGE_Back;
			LastDodgeTimestamp = Level.TimeSeconds;

			KeyPressesBeforeDodge = BackKeyPressCounter;
			BackKeyPressCounter = 0;
		}
		else if (PreviousDodgeDir == DODGE_Left)
		{
			LastDodgeDirection = DODGE_Left;
			LastDodgeTimestamp = Level.TimeSeconds;

			KeyPressesBeforeDodge = LeftKeyPressCounter;
			LeftKeyPressCounter = 0;
		}
		else if (PreviousDodgeDir == DODGE_Right)
		{
			LastDodgeDirection = DODGE_Right;
			LastDodgeTimestamp = Level.TimeSeconds;

			KeyPressesBeforeDodge = RightKeyPressCounter;
			RightKeyPressCounter = 0;
		}
	}

	if (LastDodgeDirection == DODGE_Forward && (Level.TimeSeconds - LastDodgeTimestamp) > PlayerPawn.DodgeClickTime)
	{
		LastDodgeDirection = DODGE_None;
		KeyPressesAfterDodge = ForwardKeyPressCounter;
	}
	else if (LastDodgeDirection == DODGE_Back && (Level.TimeSeconds - LastDodgeTimestamp) > PlayerPawn.DodgeClickTime)
	{
		LastDodgeDirection = DODGE_None;
		KeyPressesAfterDodge = BackKeyPressCounter;
	}
	else if (LastDodgeDirection == DODGE_Left && (Level.TimeSeconds - LastDodgeTimestamp) > PlayerPawn.DodgeClickTime)
	{
		LastDodgeDirection = DODGE_None;
		KeyPressesAfterDodge = LeftKeyPressCounter;
	}
	else if (LastDodgeDirection == DODGE_Right && (Level.TimeSeconds - LastDodgeTimestamp) > PlayerPawn.DodgeClickTime)
	{
		LastDodgeDirection = DODGE_None;
		KeyPressesAfterDodge = RightKeyPressCounter;
	}

	if (Level.TimeSeconds - MostRecentForwardKeyPress > PlayerPawn.DodgeClickTime)
		ForwardKeyPressCounter = 0;
	if (Level.TimeSeconds - MostRecentBackKeyPress > PlayerPawn.DodgeClickTime)
		BackKeyPressCounter = 0;
	if (Level.TimeSeconds - MostRecentLeftKeyPress > PlayerPawn.DodgeClickTime)
		LeftKeyPressCounter = 0;
	if (Level.TimeSeconds - MostRecentRightKeyPress > PlayerPawn.DodgeClickTime)
		RightKeyPressCounter = 0;
}

// Alternative would be to draw using:
// https://github.com/bunnytrack/BTE/blob/master/source/BTE_BTNet1/Classes/BTHUD_BTNet.uc#L1215
// https://github.com/Slipyx/UT99/blob/master/Engine/Mutator.uc#L24
// https://gist.github.com/SeriousBuggie/eb1533b0b7a4d46046f0bd65a5b1909f#draw-text-with-outline-around-it
simulated function ClientProgressMessage(string Messages[7])
{
    local int i;

	PlayerPawn.ClearProgressMessages();
    PlayerPawn.SetProgressTime(0.1);

	for (i = 0; i < ArrayCount(Messages); i++)
    	if (Messages[i] != "") PlayerPawn.SetProgressMessage(Messages[i], ArrayCount(Messages) - i);
}

simulated function LogAndClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
    Log("[BTPog/Stats] "$Message);
}

simulated function ClientMessage(String Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
