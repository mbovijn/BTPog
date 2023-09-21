class BTP_Stats_ClientConfig extends Object perobjectconfig dependson(BTP_Stats_Structs);

var config bool IsActive;
var config bool IsDebugging;

function BTP_Stats_Structs.ClientConfigDto GetClientConfig()
{
    local BTP_Stats_Structs.ClientConfigDto ClientConfigDto;

    ClientConfigDto.IsActive = IsActive;
    ClientConfigDto.IsDebugging = IsDebugging;
    
    return ClientConfigDto;
}

defaultproperties
{
	IsActive=False
	IsDebugging=False
}
