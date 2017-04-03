--List of Jobs with part numbers, and a MoM production string
SELECT
     [PartNum], [JobNum], [ProdQty], 
     STUFF(
       (SELECT ' | ' + (RG.Description + CAST(a0.OpComplete as NVARCHAR(20)) )
        FROM  (
               SELECT J.Company, JD.JobNum, JD.OpDtlSeq, O.OprSeq, O.OpCode, O.OpComplete, JD.ResourceGrpID
	       FROM ERP.JobOpDtl JD
                    INNER JOIN ERP.JobHead J
                         ON JD.Company = J.Company AND JD.JobNum = J.JobNum
                    INNER JOIN ERP.JobOper O                         
			ON JD.Company = O.Company AND JD.JobNum = O.JobNum AND JD.OprSeq = O.OprSeq AND JD.AssemblySeq = O.AssemblySeq
                    WHERE J.JobFirm = 'TRUE' AND J.JobClosed = 'FALSE' AND J.JobComplete = 'FALSE'
               	    GROUP BY J.Company, O.OprSeq,JD.OpDtlSeq, JD.JobNum, O.OpCode, O.OpComplete, JD.ResourceGrpID
                ) a0
	LEFT JOIN ERP.ResourceGroup as RG 
		ON a0.Company = RG.Company AND a0.ResourceGrpID = RG.ResourceGrpID
          WHERE a0.JobNum = a.JobNum
          FOR XML PATH (''))
          , 1, 1, '')  AS Router
FROM ERP.JobHead AS a 
WHERE a.JobReleased = 1 AND a.JobClosed = 0 AND a.Company = 'HEM'

