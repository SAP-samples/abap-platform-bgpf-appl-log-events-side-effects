@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Basic Interface View forInventory'
define view entity ZBGPFI_Inventory_006
  as select from ZBGPF_INVEN_006 as Inventory
{
  key UUID as UUID,
  INVENTORY_ID as InventoryID,
  PRODUCT_ID as ProductID,
  @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
  QUANTITY as Quantity,
  QUANTITY_UNIT as QuantityUnit,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  PRICE as Price,
  CURRENCY_CODE as CurrencyCode,
  REMARK as Remark,
  NOT_AVAILABLE as NotAvailable,
  BGPF_STATUS as BgpfStatus,
  BGPG_PROCESS_NAME as BgpgProcessName,
  APPL_LOG_HANDLE as ApplLogHandle,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  @Semantics.user.lastChangedBy: true
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt
  
}
