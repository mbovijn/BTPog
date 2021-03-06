class BTCapLoggerFile extends BTCapLoggerAbstract;

var StatLogFile LogFile;

function Tick(float DeltaTime)
{
	if (Level.Game.bGameEnded || (Level.NextURL != "" && Level.NextSwitchCountdown < 0.5))
		CloseLogFile();
}

function InitLogFile()
{
	LogFile = Spawn(class'StatLogFile');
    LogFile.SetTimer(0.0, False);

	LogFile.StatLogFile = "../Logs/BTPog."$GetAbsoluteTime()$"."$GetMap()$".tmp.csv";
	LogFile.StatLogFinal = "../Logs/BTPog."$GetAbsoluteTime()$"."$GetMap()$".csv";
	LogFile.OpenLog();

    LogFile.FileLog("Timestamp,Map,PlayerName,IP,HWID,EngineVersion,Renderer,SpawnCount,CapTime,ClientCapTime,"
		$"DodgeBlock_1PC,DodgeBlock_5PC,DodgeBlock_25PC,DodgeBlock_50PC,DodgeBlock_100PC,DodgeBlock_Count,"
		$"DodgeDoubleTap_1PC,DodgeDoubleTap_5PC,DodgeDoubleTap_25PC,DodgeDoubleTap_50PC,DodgeDoubleTap_100PC,DodgeDoubleTap_Count,"
		$"DodgeAfterLanding_1PC,DodgeAfterLanding_5PC,DodgeAfterLanding_25PC,DodgeAfterLanding_50PC,DodgeAfterLanding_100PC,DodgeAfterLanding_Count,"
		$"TimeBetweenDodges_1PC,TimeBetweenDodges_5PC,TimeBetweenDodges_25PC,TimeBetweenDodges_50PC,TimeBetweenDodges_100PC,TimeBetweenDodges_Count,"
		$"FPS_1PC,FPS_5PC,FPS_25PC,FPS_50PC,"
		$"Ping_1PC,Ping_5PC,Ping_25PC,Ping_50PC");
}

function CloseLogFile()
{
	if (LogFile != None)
	{
		Log("[BTPog/BTCapLogger] Closing the BTCapLogger file "$LogFile.StatLogFinal);

		LogFile.StopLog();
        LogFile.Destroy();
        LogFile = None;
	}
}

function LogCap(
	PlayerPawn PlayerPawn,
	float CapTime,
	StatsAnalysis DodgeBlock,
	StatsAnalysis DodgeDoubleTap,
	StatsAnalysis DodgeAfterLanding,
	StatsAnalysis TimeBetweenDodges,
	StatsAnalysis FPS,
	StatsAnalysis Ping,
	float ClientCapTimeDelta,
	String ClientEngineVersion,
	int SpawnCount,
	String Renderer,
	String HardwareID
)
{
	if (LogFile == None) InitLogFile();

	LogFile.FileLog(
		GetAbsoluteTimeISO8601()$","$
        GetMap()$","$
		Replace(PlayerPawn.PlayerReplicationInfo.PlayerName, ",", "")$","$
		GetPlayerIP(PlayerPawn)$","$
		HardwareID$","$
		ClientEngineVersion$","$
		Renderer$","$
		SpawnCount$","$
		class'Utils'.static.FloatToString(CapTime, 3)$","$
		class'Utils'.static.FloatToDeltaString(ClientCapTimeDelta, 3)$","$
		StatsAnalysisToDetailedString(DodgeBlock, 3)$","$
		StatsAnalysisToDetailedString(DodgeDoubleTap, 3)$","$
        StatsAnalysisToDetailedString(DodgeAfterLanding, 3)$","$
		StatsAnalysisToDetailedString(TimeBetweenDodges, 3)$","$
		StatsAnalysisToString(FPS, 0)$","$
		StatsAnalysisToString(Ping, 0)
	);

    LogFile.FileFlush();
}

function string Replace(string Source, string Search, string Replace)
{
	local int Position;
	
	Position = InStr(Source, Search);
	if (Position >= 0) {
		Source = Left(Source, Position) $ Replace $ Mid(Source, Position + Len(Search));
	}
	
	return Source;
}

function string StatsAnalysisToString(StatsAnalysis Analysis, int Decimals)
{
	return class'Utils'.static.FloatToString(Analysis.PC1, Decimals)$","$
		class'Utils'.static.FloatToString(Analysis.PC5, Decimals)$","$
		class'Utils'.static.FloatToString(Analysis.PC25, Decimals)$","$
		class'Utils'.static.FloatToString(Analysis.PC50, Decimals);
}

function string StatsAnalysisToDetailedString(StatsAnalysis Analysis, int Decimals)
{
	return StatsAnalysisToString(Analysis, Decimals)$","$
		class'Utils'.static.FloatToString(Analysis.PC100, Decimals)$","$
		class'Utils'.static.FloatToString(Analysis.NumberOfDataPoints, 0);
}


function string GetMap()
{
    return Left(string(Level), InStr(string(Level), "."));
}

function string GetAbsoluteTimeISO8601()
{
	local string AbsoluteTime;

	AbsoluteTime = string(Level.Year);

	if (Level.Month < 10)
		AbsoluteTime = AbsoluteTime$"-0"$Level.Month;
	else
		AbsoluteTime = AbsoluteTime$"-"$Level.Month;

	if (Level.Day < 10)
		AbsoluteTime = AbsoluteTime$"-0"$Level.Day;
	else
		AbsoluteTime = AbsoluteTime$"-"$Level.Day;
	
	if (Level.Hour < 10)
		AbsoluteTime = AbsoluteTime$"T0"$Level.Hour;
	else
		AbsoluteTime = AbsoluteTime$"T"$Level.Hour;

	if (Level.Minute < 10)
		AbsoluteTime = AbsoluteTime$":0"$Level.Minute;
	else
		AbsoluteTime = AbsoluteTime$":"$Level.Minute;

	if (Level.Second < 10)
		AbsoluteTime = AbsoluteTime$":0"$Level.Second;
	else
		AbsoluteTime = AbsoluteTime$":"$Level.Second;

	if (Level.Millisecond < 10)
		AbsoluteTime = AbsoluteTime$".00"$Level.Millisecond;
	else if (Level.Millisecond < 100)
		AbsoluteTime = AbsoluteTime$".0"$Level.Millisecond;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Millisecond;

	return AbsoluteTime;
}

function string GetAbsoluteTime()
{
	local string AbsoluteTime;

	AbsoluteTime = string(Level.Year);

	if (Level.Month < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Month;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Month;

	if (Level.Day < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Day;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Day;

	if (Level.Hour < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Hour;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Hour;

	if (Level.Minute < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Minute;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Minute;

	if (Level.Second < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Second;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Second;

	if (Level.Millisecond < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Millisecond;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Millisecond;

	return AbsoluteTime;
}

function string GetPlayerIP(PlayerPawn PlayerPawn)
{
	local string Address;
	Address = PlayerPawn.GetPlayerNetworkAddress();
	return Left(Address, Instr(Address, ":"));
}
