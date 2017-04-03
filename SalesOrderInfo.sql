SELECT DISTINCT 
       CONCAT(MONTH(Rel.NeedByDate), '-',YEAR(Rel.NeedByDate)) AS 'Sales Month',
       C.CustID AS "Customer",
       CONCAT(Rel.OrderNum ,' / ' , Rel.OrderLine ,' / ' , Rel.OrderRelNum) AS "Order",
       Rel.PartNum AS "Part",
       SO.ProdCode AS "ProdCode",
       Rel.ReqDate AS "Due",
       CONVERT(INT, Rel.OurReqQty - Rel.SellingStockShippedQty) AS "QTY Owed",
       CONVERT(INT, P.OnhandQty) AS "Stock",
       SO.DocUnitPrice AS "$/Per",
       --ROUND(Rel.OurReqQty * SO.DocUnitPrice, 2) AS "ExtPrice",
       Routing.Router AS "Method"

FROM Erp.OrderRel Rel

LEFT JOIN Erp.OrderHed O ON
Rel.Company = O.Company AND
Rel.OrderNum = O.OrderNum

INNER JOIN ERP.Customer C ON
O.Company = C.Company AND O.CustNum = C.CustNum

LEFT JOIN Erp.OrderDtl SO ON
Rel.Company = SO.Company AND
Rel.OrderNum = SO.OrderNum AND
Rel.OrderLine = SO.OrderLine

LEFT JOIN (SELECT Pb.Company, Pb.PartNum, Sum(Pb.OnHandQty) AS [OnhandQty]
           FROM ERP.PartBin Pb
           WHERE Pb.WarehouseCode = 'FGI' OR Pb.WarehouseCode = 'BROMONT'
           GROUP BY Pb.Company, Pb.PartNum
           ) P ON
Rel.Company = P.Company AND
Rel.PartNum = P.PartNum

LEFT JOIN (
SELECT
     [PartNum],
     STUFF(
         (SELECT '-' + a0.ResourceGrpID
          FROM  (
                SELECT P.PartNum, P.ResourceGrpID 
		FROM ERP.PartOpDtl P 
		WHERE (AltMethod = '' AND BaseMethodOverridden = 0)
                --ORDER BY P.PartNum, P.OprSeq ASC
                ) a0
          WHERE a0.PartNum = a.PartNum
          FOR XML PATH ('')
	  )
          , 1, 1, '')  AS Router
FROM ERP.PartOpr AS a
           ) as Routing ON Rel.PartNum = Routing.PartNum
WHERE Rel.OpenRelease = 'True' AND (Rel.OurReqQty - Rel.SellingStockShippedQty) > 0

ORDER BY Rel.ReqDate ASC, Rel.PartNum ASC
