--Query of yesertdays labor notes in Epicor ERP system. If Today is monday (assuming no labor on sunday) pulls from Friday


IF EXISTS ((SELECT * FROM ERP.LaborDtl WHERE Labordtl.ClockinDate = dateADD(day, -1, Convert(DAte, getdate()))))
    BEGIN
      SELECT DATENAME(weekday, L.CLOCKINDATE), j.PartNum, l.JobNum, l.OprSeq, L.OprSeq,L.LaborType, E.Name, L.DspClockInTime, L.DspClockOutTime, L.LaborQty, L.LaborNote
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
      SELECT DATENAME(weekday, L.CLOCKINDATE),j.PartNum, l.JobNum, l.OprSeq, L.OprSeq,L.LaborType, E.Name, L.DspClockInTime, L.DspClockOutTime, L.LaborQty, L.LaborNote
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
