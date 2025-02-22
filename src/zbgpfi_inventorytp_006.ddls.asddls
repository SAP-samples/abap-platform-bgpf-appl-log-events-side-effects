@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forInventory'
define root view entity ZBGPFI_InventoryTP_006
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZBGPFR_InventoryTP_006 as Inventory
{
  key UUID,
  InventoryID,
  ProductID,
  Quantity,
  QuantityUnit,
  Price,
  CurrencyCode,
  Remark,
  NotAvailable,
  BgpfStatus,
  BgpgProcessName,
  ApplLogHandle,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
