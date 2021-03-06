class BTCapLoggerBucketedStats extends BTCapLoggerAbstract;

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
        Log("[BTPog/BTCapLogger] Index "$Index$" is invalid");
        return;
    }

    Buckets[Index].Value = Value;
    Buckets[Index].Count++;
    TotalCount++;
}

function StatsAnalysis Analyze()
{
    local StatsAnalysis StatsAnalysis;
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
