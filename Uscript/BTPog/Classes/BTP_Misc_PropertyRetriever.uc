class BTP_Misc_PropertyRetriever extends Info;

var PlayerPawn PlayerPawn;
var String ActorName;
var String PropertyName;

var Actor Actor;
var String Property;

function Init(PlayerPawn aPlayerPawn, String FullPropertyName)
{
    PlayerPawn = aPlayerPawn;
    ActorName = class'BTP_Misc_Utils'.static.GetStringPart(FullPropertyName, 0, ".");
    PropertyName = class'BTP_Misc_Utils'.static.GetStringPart(FullPropertyName, 1, ".");
}

function String GetProperty()
{
	if (Actor == None)
        Actor = GetActor();

    if (Actor != None && Property == "")
        Property = Actor.getPropertyText(PropertyName);

    return Property;
}

function Actor GetActor()
{
	local Actor TempActor;

	if (ActorName == "")
		return None;

	foreach AllActors(class'Actor', TempActor)
    {
		if (TempActor.Owner == PlayerPawn && GetObjectClassName(TempActor) ~= ActorName)
            return TempActor;
	}
    return None;
}

function string GetObjectClassName(Object Object)
{
	local String Result;
	local Int Index;
	
	if (Object != None)
    {
		Result = String(Object.class);
		Index = Instr(Result, ".");
		if (Index >= 0)
        {
			Result = Mid(Result, Index + 1);
		}
	}
	
	return Result;
}