class BTP_Suicide_ClientConfig extends Object perobjectconfig dependson(BTP_Suicide_Structs);

var config array<BTP_Suicide_Structs.MoverTrackerCollection> MoverTrackerCollections;

function BTP_Suicide_Structs.MoverTrackerCollection GetMoverTrackerCollection(string MapName, byte Team)
{
    local int Index;
    if (FindMoverTrackerCollection(MapName, Team, Index))
    {
        return MoverTrackerCollections[Index];
    }
    else
    {
        return class'BTP_Suicide_Structs'.static.CreateEmptyMoverTrackerCollection(MapName, Team);
    }
}

function UpdateMoverTrackerCollection(BTP_Suicide_Structs.MoverTrackerCollection MoverTrackerCollection)
{
    local int Index;
	if (!FindMoverTrackerCollection(MoverTrackerCollection.Map, MoverTrackerCollection.Team, Index))
		MoverTrackerCollections.Insert(Index, 1);
    MoverTrackerCollections[Index] = MoverTrackerCollection;
    SaveConfig();
}

function bool FindMoverTrackerCollection(string MapName, byte Team, out int Index)
{
    local int F, C;

	MapName = Caps(MapName);
	F = 0;
	C = MoverTrackerCollections.Length - 1;
    
	while (F <= C)
    {
		Index = F + ((C - F) / 2);
		if ((Caps(MoverTrackerCollections[Index].Map) $ string(MoverTrackerCollections[Index].Team)) < (MapName $ string(Team)))
			F = ++Index;
		else if ((Caps(MoverTrackerCollections[Index].Map) $ string(MoverTrackerCollections[Index].Team)) > (MapName $ string(Team)))
			C = Index-1;
		else {
            return true;
        }
	}

	return false;
}

static function BTP_Suicide_ClientConfig Create()
{
    local Object Obj;
    local BTP_Suicide_ClientConfig ClientConfig;

	Obj = new (none, 'BTPog_Suicide') class'Object';
	ClientConfig = new (Obj, 'Stopwatch_ClientConfig') class'BTP_Suicide_ClientConfig';
	ClientConfig.SaveConfig();

    return ClientConfig;
}
