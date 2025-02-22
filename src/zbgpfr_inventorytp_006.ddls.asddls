@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forInventory'
@ObjectModel.sapObjectNodeType.name: 'ZBGPFInventory_006'
define root view entity ZBGPFR_InventoryTP_006
  as select from ZBGPFI_Inventory_006 as Inventory
{
  key UUID,
  InventoryID,
  ProductID,
  @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
  Quantity,
  QuantityUnit,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  Price,
  CurrencyCode,
  Remark,
  NotAvailable,
  BgpfStatus,
  BgpgProcessName,
  ApplLogHandle,
  @Semantics.user.createdBy: true
  CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CreatedAt,
  @Semantics.user.lastChangedBy: true
  LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LocalLastChangedAt
  
}
