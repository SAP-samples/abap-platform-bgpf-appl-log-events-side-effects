@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forInventory'
@ObjectModel.semanticKey: [ 'InventoryID' ]
@Search.searchable: true
define root view entity ZBGPFC_InventoryTP_006
  provider contract TRANSACTIONAL_QUERY
  as projection on ZBGPFR_InventoryTP_006 as Inventory
{
  key UUID,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  InventoryID,
  ProductID,
  @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
  Quantity,
  @Semantics.unitOfMeasure: true
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_UnitOfMeasure', 
      element: 'UnitOfMeasure'
    }, 
    useForValidation: true
  } ]
  QuantityUnit,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  Price,
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Currency', 
      element: 'Currency'
    }, 
    useForValidation: true
  } ]
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
