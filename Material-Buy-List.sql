With 
[OnHand] AS 
    (SELECT 
        [PartBin].[Company] as [PartBin_Company],
        [PartBin].[PartNum] as [PartBin_PartNum],
        (sum(partbin.OnhandQty)) as [Calculated_TotalOnHand]
    FROM Erp.PartBin as PartBin
    INNER JOIN Erp.Part as Part on 
        PartBin.Company = Part.Company
    AND PartBin.PartNum = Part.PartNum
    AND ( Part.TypeCode = 'P'  )

    GROUP BY [PartBin].[Company],
        [PartBin].[PartNum]),

[MaterialDemand] AS 
    (SELECT 
        [JobMtl].[Company] as [JobMtl_Company],
        [JobMtl].[PartNum] as [JobMtl_PartNum],
        (JobMtl.RequiredQty - JobMtl.IssuedQty) as [Calculated_MaterialNeed],
        [JobMtl].[ReqDate] as [JobMtl_ReqDate],
        (sum(MaterialNeed) over(Partition by JobMtl.PartNum order by JobMtl.ReqDate)) as [Calculated_cumDemand]
    FROM Erp.JobMtl as JobMtl
    INNER JOIN Erp.JobHead as JobHead on 
        JobMtl.Company = JobHead.Company
    AND JobMtl.JobNum = JobHead.JobNum
    AND ( JobHead.JobFirm = True AND JobHead.JobCompLEFTe = False  )

    WHERE (JobMtl.ReqDate < DATEADD (month, 6, GETDATE()) AND JobMtl.IssuedComplete = False))

SELECT 
    [MaterialDemand].[JobMtl_PartNum] as [JobMtl_PartNum],
    (min(MaterialDemand.JobMtl_ReqDate)) as [Calculated_NextReqDate],
    (min(MaterialDemand.Calculated_cumDemand) - avg(OnHand.Calculated_TotalOnHand)) as [Calculated_minNeed],
    (max(MaterialDemand.Calculated_cumDemand) - avg(OnHand.Calculated_TotalOnHand)) as [Calculated_TotalNeed]
FROM  MaterialDemand  as MaterialDemand
LEFT OUTER JOIN  OnHand  as OnHand on 
    MaterialDemand.JobMtl_Company = OnHand.PartBin_Company
AND MaterialDemand.JobMtl_PartNum = OnHand.PartBin_PartNum

WHERE OnHand.Calculated_TotalOnHand < MaterialDemand.Calculated_cumDemand

GROUP BY [MaterialDemand].[JobMtl_PartNum]
