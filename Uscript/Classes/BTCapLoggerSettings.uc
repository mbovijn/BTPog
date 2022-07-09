class BTCapLoggerSettings extends Object config (BTPog) perobjectconfig;

var config int TicksPerFPSCalculation; // Amount of ticks to take into account when calculating FPS

function ValidateConfig()
{
	if (TicksPerFPSCalculation < 1 || TicksPerFPSCalculation > 200) {
		Log("[BTPog/BTCapLogger] TicksPerFPSCalculation is set to an invalid value. Resetting..");
		TicksPerFPSCalculation = 10;
   }
}

defaultproperties
{
	TicksPerFPSCalculation=10
}
