--Query of yesterday's labor notes in Epicor ERP system. If Today is monday (assuming no labor on sunday) pulls from Friday


IF EXISTS ((SELECT * FROM ERP.LaborDtl WHERE Labordtl.ClockinDate = dateADD(day, -1, Convert(DAte, getdate()))))
    BEGIN
      SELECT
        DATENAME(weekday, L.CLOCKINDATE),
        j.PartNum,
        l.JobNum,
        L.OprSeq,
        L.LaborType as 'Setup/Prod',
        E.Name, L.DspClockInTime AS 'Start',
        L.DspClockOutTime AS 'End',
        L.LaborQty AS 'Qty',
        L.LaborNote
      FROM ERP.LaborDtl AS l
        INNER JOIN erp.EmpBasic AS e
          ON l.company = e.company AND
             l.EmployeeNum = e.EmpID
        INNER JOIN  erp.JobHead AS j
          ON l.Company = j.Company AND
             l.JobNum = j.JobNum
        WHERE L.ClockInDate = dateADD(DAY, -1, CONVERT(DATE,GETDATE())) AND
              lABORTYPE <> 'I'
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
        L.LaborNote
        FROM ERP.LaborDtl AS l
        INNER JOIN erp.EmpBasic AS e
          ON l.company = e.company AND
             l.EmployeeNum = e.EmpID
        INNER JOIN  erp.JobHead AS j
          ON l.Company = j.Company AND
             l.JobNum = j.JobNum
        WHERE L.ClockInDate = dateADD(DAY, -3, CONVERT(DATE,GETDATE())) AND
              l.Labortype <> 'I'
    END
