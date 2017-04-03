Select ERP.PartOpr.PartNum, ERP.PartOpr.RevisionNum,ERP.PartOpr.OprSeq,ERP.PartOpr.OpCode, ERP.PartOpDtl.ResourceGrpID
from ERP.PartOpr
  INNER JOIN ERP.PartOpDtl
    ON ERP.PartOpr.Company = ERP.PartOpDtl.Company
    AND ERP.PartOpr.PartNum = ERP.PartOpDtl.PartNum
    AND ERP.PartOpr.RevisionNum = ERP.PartOpDtl.RevisionNum
    AND ERP.PartOpr.OprSeq = ERP.PartOpDtl.OprSeq
    AND ERP.PartOpr.AltMethod = ERP.PartOpDtl.AltMethod
