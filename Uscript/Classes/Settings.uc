class Settings extends Info config (BTPog);

var config bool IsDebugging;

var config bool IsBTStatsEnabled;
var config bool IsBTStopwatchEnabled;
var config bool IsBTSuicideEnabled;
var config bool IsBTZeroPingDodgeEnabled;
var config bool IsBTCapLoggerEnabled;

function PreBeginPlay()
{
    SaveConfig();
}

defaultproperties
{
    IsDebugging=False
    IsBTStatsEnabled=True
    IsBTStopwatchEnabled=True
    IsBTSuicideEnabled=True
    IsBTZeroPingDodgeEnabled=True
    IsBTCapLoggerEnabled=True
}
