class BTCapLoggerAbstract extends Info abstract;

struct StatsAnalysis
{
    var float PC1;
    var float PC5;
    var float PC25;
    var float PC50;
    var float PC100;
    var int NumberOfDataPoints;
};

struct LogData
{
	var String UniqueId;
	var float CapTime;
	var StatsAnalysis DodgeBlock;
	var StatsAnalysis DodgeDoubleTap;
	var StatsAnalysis DodgeAfterLanding;
	var StatsAnalysis TimeBetweenDodges;
	var StatsAnalysis FPS;
	var StatsAnalysis Ping;
	var float ClientCapTimeDelta;
	var String ClientEngineVersion;
	var int SpawnCount;
	var String Renderer;
	var String HardwareID;
	var String CustomID;
	var String ZoneCheckpoints;
};