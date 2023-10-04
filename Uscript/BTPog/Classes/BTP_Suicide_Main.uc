class BTP_Suicide_Main extends Info dependson(BTP_Suicide_Structs);

var BTP_Suicide_ClientConfig ClientConfig; // CLIENT VARIABLE

var BTP_Suicide_Controller RedController;
var BTP_Suicide_Controller BlueController;

replication
{
	reliable if (Role < ROLE_Authority)
		ReplicateMoverTrackerCollectionToServer;
	reliable if (Role == ROLE_Authority)
		ReplicateMoverTrackerCollectionToClient;
}

simulated function PostNetBeginPlay()
{
	local string MapName;
    if (Role < ROLE_Authority)
    {
        ClientConfig = class'BTP_Suicide_ClientConfig'.static.Create();
		MapName = class'BTP_Misc_Utils'.static.GetMapName(Level);
		
        ReplicateMoverTrackerCollectionToServer(ClientConfig.GetMoverTrackerCollection(MapName, 0)); // RED side
	    ReplicateMoverTrackerCollectionToServer(ClientConfig.GetMoverTrackerCollection(MapName, 1)); // BLUE side
    }
}

function ReplicateMoverTrackerCollectionToServer(BTP_Suicide_Structs.MoverTrackerCollection MoverTrackerCollection)
{
	if (MoverTrackerCollection.Team == 0)
	{
		RedController = Spawn(class'BTP_Suicide_Controller', Owner);
		RedController.Init(PlayerPawn(Owner), Self, MoverTrackerCollection);
	}
	else if (MoverTrackerCollection.Team == 1)
	{
		BlueController = Spawn(class'BTP_Suicide_Controller', Owner);
		BlueController.Init(PlayerPawn(Owner), Self, MoverTrackerCollection);
	}
	else
	{
		Log("[BTPog/Suicide] Received MoverTrackerCollection with invalid team " $ MoverTrackerCollection.Team $ "from the client");
	}
}

simulated function ReplicateMoverTrackerCollectionToClient(BTP_Suicide_Structs.MoverTrackerCollection MoverTrackerCollection)
{
	ClientConfig.UpdateMoverTrackerCollection(MoverTrackerCollection);
}

function BTP_Suicide_Controller GetController()
{
	switch (PlayerPawn(Owner).PlayerReplicationInfo.Team)
	{
		case 0: return RedController;
		case 1: return BlueController;
		default: return None;
	}
}

function ExecuteCommand(String MutateString)
{
	local BTP_Suicide_Controller Controller;

	Controller = GetController();
	if (Controller == None)
	{
		ClientMessage("Please try again once initialization has finished");
		return;
	}

	Controller.ExecuteCommand(MutateString);
}

function ClientMessage(string Message)
{
    PlayerPawn(Owner).ClientMessage("[BTPog/Suicide] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}