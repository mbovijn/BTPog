class BTP_CapLogger_ServerConfig extends Object config (BTPog) perobjectconfig;

var config int TicksPerFPSCalculation; // Amount of ticks to take into account when calculating FPS
var config String IdPropertyToLog;
// Should all caps, during the playtime of a map, be put into a single file, or do we want a file per cap?
// If all caps are bundled into a single file, the file will only get closed when the match is over, so the
// data can't be read until the match is over.
var config bool FilePerCap;
var config bool IsDebugging;
var config int MaxZoneCheckpoints;
var config int MaxTrackedLocations;
var config float TrackedLocationPeriod;

function ValidateConfig()
{
	if (TicksPerFPSCalculation < 1 || TicksPerFPSCalculation > 200)
	{
		Log("[BTPog/CapLogger] TicksPerFPSCalculation is set to an invalid value. Resetting..");
		TicksPerFPSCalculation = 10;
	}

	if (MaxZoneCheckpoints < 0 || MaxZoneCheckpoints > 1000)
	{
		Log("[BTPog/CapLogger] MaxZoneCheckpoints is set to an invalid value. Resetting..");
		MaxZoneCheckpoints = 100;
	}

	if (MaxTrackedLocations < 0 || MaxTrackedLocations > 1000)
	{
		Log("[BTPog/CapLogger] MaxTrackedLocations is set to an invalid value. Resetting..");
		MaxTrackedLocations = 100;
	}

	if (TrackedLocationPeriod < 0.1 || TrackedLocationPeriod > 10)
	{
		Log("[BTPog/CapLogger] TrackedLocationPeriod is set to an invalid value. Resetting..");
		TrackedLocationPeriod = 5;
	}
}

defaultproperties
{
	TicksPerFPSCalculation=10
	IdPropertyToLog=""
	FilePerCap=False
	IsDebugging=False
	MaxZoneCheckpoints=100
	MaxTrackedLocations=100
	TrackedLocationPeriod=5
}
