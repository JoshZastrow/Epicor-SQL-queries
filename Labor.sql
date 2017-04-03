

IF EXISTS ((SELECT * FROM ERP.LaborDtl WHERE Labordtl.ClockinDate = dateADD(day, -1, Convert(DAte, getdate()))))
    BEGIN
      SELECT l.ClockinDate as 'Date', 
        DATENAME(weekday, L.CLOCKINDATE) as 'Weekday',
        j.PartNum,
        l.JobNum,
        L.OprSeq,
        L.LaborType as 'Setup/Prod', R.Description as 'Machine ID',
        E.Name, L.DspClockInTime AS 'Start',
        L.DspClockOutTime AS 'End',
        L.LaborQty AS 'Qty',
        L.LaborNote AS 'Machinist Notes',
        jo.ProdStandard AS 'Est. Rate'
      FROM ERP.LaborDtl AS l
        INNER JOIN erp.EmpBasic AS e
          ON l.company = e.company AND
             l.EmployeeNum = e.EmpID
        INNER JOIN  erp.JobHead AS j
          ON l.Company = j.Company AND
             l.JobNum = j.JobNum
        INNER JOIN   ERP.JobOpDtl AS jo
            ON l.Company = jo.Company AND
             l.JobNum = jo.JobNum AND
             l.OprSeq = jo.OprSeq
        INNER JOIN ERP.Resource AS R 
            ON l.company = R.company AND
             l.ResourceID = R.ResourceID

        WHERE L.ClockInDate = dateADD(DAY, -1, CONVERT(DATE,GETDATE())) AND
              lABORTYPE <> 'I' AND
              e.Name <> 'Michael Rallo' AND
              e.Name <> 'Peter Austin' AND
              l.ResourceID <> '' AND
              l.DspClockInTime <> ''

      END
ELSE
    BEGIN
      SELECT
        DATENAME(weekday, L.CLOCKINDATE),
        j.PartNum,
        l.JobNum,
        l.OprSeq,
        L.LaborType as 'Setup/Prod',
        E.Name, L.DspClockInTime AS 'Start',
        L.DspClockOutTime AS 'End',
        L.LaborQty AS 'Qty',
        L.LaborNote AS 'Machinist Notes',
        jo.ProdStandard AS 'Est. Rate'
      
        FROM ERP.LaborDtl AS l
        INNER JOIN erp.EmpBasic AS e
          ON l.company = e.company AND
             l.EmployeeNum = e.EmpID
        INNER JOIN  erp.JobHead AS j
          ON l.Company = j.Company AND
             l.JobNum = j.JobNum
        INNER JOIN   ERP.JobOpDtl AS jo
          ON l.Company = jo.Company AND
             l.JobNum = jo.JobNum AND
             l.OprSeq = jo.OprSeq
        WHERE L.ClockInDate = dateADD(DAY, -3, CONVERT(DATE,GETDATE())) AND
              l.Labortype <> 'I' AND
              e.Name <> 'Michael Rallo' AND
              e.Name <> 'Peter Austin'
    END