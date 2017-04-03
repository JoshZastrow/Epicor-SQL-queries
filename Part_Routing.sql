--Sample code
SELECT
  [User],
  Activity,
  STUFF(
      (SELECT DISTINCT ',' + PageURL
       FROM TableName
       WHERE [User] = a.[User] AND Activity = a.Activity
       FOR XML PATH (''))
      , 1, 1, '') AS URLList
FROM TableName AS a
GROUP BY [User], Activity

SELECT J.JobNum, J.PartNum, J.ProdQty, J.JobFirm, Routing.Router
FROM ERP.JobHead J
INNER JOIN
  (
SELECT
     [PartNum],
     STUFF(
         (SELECT '-' + a0.ResourceGrpID
          FROM  (
                SELECT P.PartNum, P.ResourceGrpID FROM ERP.PartOpDtl P WHERE (AltMethod = '' AND BaseMethodOverridden = 0)
                --ORDER BY P.PartNum, P.OprSeq ASC
                )a0
          WHERE a0.PartNum = a.PartNum
          FOR XML PATH (''))
          , 1, 1, '')  AS Router
FROM ERP.PartOpr AS a
           ) as Routing ON J.PartNum = Routing.PartNum
WHERE J.JobClosed = 0 AND J.JobReleased = 1