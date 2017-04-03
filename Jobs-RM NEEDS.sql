/* Returns Jobs that require material for which we have quantity on hand
    Criteria are as follows:
      Jobs without labor transactions on them (Job Splits from Cutover Jobs falls in this category)
      Jobs not from Cutover (these jobs suspected to still have matl demand when there is none)
      Jobs without any record of issued material
      Jobs who's required material qty is less than material quantity on hand

*/

SELECT  count(JOB_RM.JobNum),
        JOB_RM.PartNum,
        JOB_RM.JobNum

--From Jobs with no labor activity
FROM (SELECT
        JobHead.JobNum,
        JobHead.PartNum,
        RM.PartNum as 'MtlPartNum',
        Cast(RM.RequiredQty as INT) as 'RequiredQty',
        RM.UOM as 'UOM'

      --From Jobs with Material needs
      FROM Erp.JobHead
      INNER JOIN (

                  SELECT
                    JobMtl.Company,
                    JobMtl.JobNum,
                    JobMtl.RequiredQty,
                    JobMtl.PartNum,
                    sum(PartBin.OnhandQty) AS 'Total on hand',
                    JobMtl.BaseUOM         AS 'UOM'

                  --From Jobs with material on hand
                  FROM Erp.JobMtl
                    INNER JOIN Erp.PartBin
                       ON JobMtl.Company = PartBin.Company
                      AND JobMtl.PartNum = PartBin.PartNum
                  --Jobs in need of Raw Material
                  WHERE JobMtl.IssuedComplete = 0
                  --If we have enough material in stock
                  GROUP BY JobMtl.Company,
                           JobMtl.JobNum,
                           JobMtl.PartNum,
                           JobMtl.BaseUOM,
                           JobMtl.RequiredQty
                  HAVING sum(PartBin.OnhandQty) > JobMtl.RequiredQty
                  ) AS [RM]
        ON JobHead.Company = RM.Company
        AND JobHead.JobNum = RM.JobNum

      where JobHead.JobFirm = 1
      and JobHead.CreatedBy <> 'sbevets1') AS [JOB_RM]

FULL JOIN ERP.LaborDtl
  ON JOB_RM.JobNum = LaborDtl.JobNum
  --just jobs that have no laborDtl (is null)
  WHERE LaborDtl.JobNum IS NULL
  GROUP BY JOB_RM.JobNum,JOB_RM.PartNum
  HAVING COUNT(JOB_RM.JobNum)>0


