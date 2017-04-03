SELECT PartTran.JobNum, PartTran.PartNum, WareHouseCode, BinNum

from ERP.PartTran
  WHERE PartTran.TranType = 'STK-MTL'
