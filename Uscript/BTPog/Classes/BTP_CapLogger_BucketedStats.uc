class BTP_CapLogger_BucketedStats extends Info dependson(BTP_CapLogger_Structs);

struct Bucket
{
    var float Value;
    var int Count;
};

var Bucket Buckets[1024];
var int TotalCount;

function AddValue(int Index, float Value)
{
    if (Index < 0 || Index >= ArrayCount(Buckets))
    {
        // When a player joins a server, his/her FPS/Ping could have invalid values
        return;
    }

    Buckets[Index].Value = Value;
    Buckets[Index].Count++;
    TotalCount++;
}

function BTP_CapLogger_Structs.StatsAnalysis Analyze()
{
    local BTP_CapLogger_Structs.StatsAnalysis StatsAnalysis;
    local int BucketIndex, TotalCounter;

    for (BucketIndex = 0; BucketIndex < ArrayCount(Buckets); BucketIndex++)
    {
        if (Buckets[BucketIndex].Count > 0)
        {
            if (TotalCounter == 0)
                StatsAnalysis.PC1 = Buckets[BucketIndex].Value;
        
            if (TotalCounter <= int(TotalCount*0.05) && int(TotalCount*0.05) < (TotalCounter + Buckets[BucketIndex].Count))
                StatsAnalysis.PC5 = Buckets[BucketIndex].Value;
            
            if (TotalCounter <= int(TotalCount*0.25) && int(TotalCount*0.25) < (TotalCounter + Buckets[BucketIndex].Count))
                StatsAnalysis.PC25 = Buckets[BucketIndex].Value;
            
            if (TotalCounter <= int(TotalCount*0.50) && int(TotalCount*0.50) < (TotalCounter + Buckets[BucketIndex].Count))
                StatsAnalysis.PC50 = Buckets[BucketIndex].Value;
            
            if (TotalCounter <= TotalCount && TotalCount < (TotalCounter + Buckets[BucketIndex].Count))
                StatsAnalysis.PC100 = Buckets[BucketIndex].Value;

            TotalCounter += Buckets[BucketIndex].Count;
        }
    }

    StatsAnalysis.NumberOfDataPoints = TotalCount;

    return StatsAnalysis;
}
