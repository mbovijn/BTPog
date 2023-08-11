class BTP_Stopwatch_ClientConfig extends Object config (BTPog) perobjectconfig;

var config int PrecisionDecimals;

function ValidateConfig()
{
    if (PrecisionDecimals < 0 || PrecisionDecimals > 3) {
        Log("[BTPog/Stopwatch] PrecisionDecimals needs to be a value between 0 and 3. Resetting..");
        PrecisionDecimals = 2;
    }
}

defaultproperties
{
    PrecisionDecimals=2
}
