CLASS lsc_zbgpfr_inventorytp_006 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zbgpfr_inventorytp_006 IMPLEMENTATION.

  METHOD save_modified.

    DATA : inventories         TYPE STANDARD TABLE OF zbgpf_inven_006,
           inventory           TYPE                   zbgpf_inven_006,
           events_to_be_raised TYPE TABLE FOR EVENT ZBGPFR_InventoryTP_006~QuantityUpdated.

    DATA update_inventory_2 TYPE STRUCTURE FOR CHANGE zbgpfr_inventorytp_006\\inventory.
    DATA update_inventories_2 TYPE TABLE FOR CHANGE ZBGPFR_InventoryTP_006\\Inventory.


    IF update-inventory IS NOT INITIAL.
      LOOP AT update-inventory ASSIGNING FIELD-SYMBOL(<update_inventory>).

        "check if a process via bgpf shall be started
        IF     <update_inventory>-BgpfStatus          = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo
           AND <update_inventory>-%control-BgpfStatus = if_abap_behv=>mk-on.


          TRY.

              DATA(bgpf_process_name) = zbgpfcl_calc_inventory_006=>run_via_bgpf( i_rap_bo_entity_key = <update_inventory>-%key ).

              update_inventory_2-%control-BgpgProcessName = if_abap_behv=>mk-on.
              update_inventory_2-bgpgprocessname = bgpf_process_name.
              update_inventory_2-%key = <update_inventory>-%key.
              APPEND update_inventory_2 TO update_inventories_2.

            CATCH cx_bgmc INTO DATA(bgpf_exception).
              "handle exception

              update_inventory_2-%control-remark = if_abap_behv=>mk-on.
              update_inventory_2-remark = bgpf_exception->get_text(  ).
              update_inventory_2-%key = <update_inventory>-%key.
              APPEND update_inventory_2 TO update_inventories_2.

          ENDTRY.

        ENDIF.

        "the quantity is updated via BGPF
        IF <update_inventory>-%control-Quantity = if_abap_behv=>mk-on.

          CLEAR events_to_be_raised.
          APPEND INITIAL LINE TO events_to_be_raised.
          events_to_be_raised[ 1 ] = CORRESPONDING #( <update_inventory> ).

          RAISE ENTITY EVENT zbgpfr_inventorytp_006~QuantityUpdated FROM events_to_be_raised.

        ENDIF.
      ENDLOOP.

    ENDIF.

    "Code needed if an unmanaged save is used

    IF create-inventory IS NOT INITIAL.
      inventories = CORRESPONDING #( create-inventory MAPPING FROM ENTITY ).
      INSERT zbgpf_inven_006 FROM TABLE @inventories.
    ENDIF.

    IF update IS NOT INITIAL.
      CLEAR inventories.
      UPDATE zbgpf_inven_006 FROM TABLE @update-inventory
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY. .
    ENDIF.

    IF update_inventory_2 IS NOT INITIAL.
      UPDATE zbgpf_inven_006 FROM TABLE @update_inventories_2
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY.
    ENDIF.

    IF delete IS NOT INITIAL.
      LOOP AT delete-inventory INTO DATA(inventory_delete).
        DELETE FROM zbgpf_inven_006  WHERE uuid = @inventory_delete-uuid.
        DELETE FROM zbgpfinve00d_006 WHERE uuid = @inventory_delete-uuid.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_inventory DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Inventory
        RESULT result,
      calculateinventoryid FOR DETERMINE ON SAVE
        IMPORTING
          keys FOR  Inventory~CalculateInventoryID ,
      reCalculateInventory FOR MODIFY
        IMPORTING keys FOR ACTION Inventory~reCalculateInventory.

*    CONSTANTS :
*      BEGIN OF bgpf_state,
*        unknown         TYPE int1 VALUE IS INITIAL,
*        erroneous       TYPE int1 VALUE 1,
*        new             TYPE int1 VALUE 2,
*        running         TYPE int1 VALUE 3,
*        successful      TYPE int1 VALUE 4,
*        started_from_bo TYPE int1 VALUE 99,
*      END OF bgpf_state.

ENDCLASS.

CLASS lhc_inventory IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD calculateinventoryid.
    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
      ENTITY Inventory
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities).
    DELETE entities WHERE InventoryID IS NOT INITIAL.
    CHECK entities IS NOT INITIAL.
    "Dummy logic to determine object_id
    SELECT MAX( inventory_id ) FROM zbgpf_inven_006 INTO @DATA(max_object_id).
    "Add support for draft if used in modify
    "SELECT SINGLE FROM FROM ZBGPFINVE00D_006 FIELDS MAX( InventoryID ) INTO @DATA(max_orderid_draft). "draft table
    "if max_orderid_draft > max_object_id
    " max_object_id = max_orderid_draft.
    "ENDIF.
    MODIFY ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
      ENTITY Inventory
        UPDATE FIELDS ( InventoryID )
          WITH VALUE #( FOR entity IN entities INDEX INTO i (
          %tky          = entity-%tky
          InventoryID     = max_object_id + i
    ) ).
  ENDMETHOD.

  METHOD reCalculateInventory.

    READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
         ENTITY Inventory
         FIELDS ( BgpfStatus )
         WITH CORRESPONDING #( keys )
       RESULT DATA(inventories).

    LOOP AT inventories ASSIGNING FIELD-SYMBOL(<inventory>) .
      CASE <inventory>-BgpfStatus.
        WHEN zbgpfcl_calc_inventory_006=>bgpf_state-unknown .
          <inventory>-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo.
        WHEN zbgpfcl_calc_inventory_006=>bgpf_state-successful .
          <inventory>-BgpfStatus = zbgpfcl_calc_inventory_006=>bgpf_state-started_from_bo.
        WHEN OTHERS.
          "do nothing
      ENDCASE.
    ENDLOOP.

    MODIFY ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
      ENTITY Inventory
        UPDATE FIELDS ( BgpfStatus )
        WITH CORRESPONDING #( inventories ).

*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*
*      READ ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
*       ENTITY Inventory
*         ALL FIELDS "( Quantity QuantityUnit )
*         WITH VALUE #( ( %tky = CORRESPONDING #( <key>-%tky ) ) )
*       RESULT DATA(inventories).
*
*      DELETE inventories WHERE BgpfStatus = skip_bgpf_status_running .
*      CHECK inventories IS NOT INITIAL.
*
*      MODIFY ENTITIES OF ZBGPFR_InventoryTP_006 IN LOCAL MODE
*        ENTITY Inventory
*          UPDATE FROM VALUE #( FOR <s_salooon> IN inventories ( %tky        = CORRESPONDING #( <s_salooon> )
*                                                                Quantity = <s_salooon>-Quantity + 10
*                                                                %control    = VALUE #( Quantity = if_abap_behv=>mk-on ) ) )
*          REPORTED DATA(lt_reported).
*
*    ENDLOOP.
*
*    " not ok but for demo only one cinema is affected
*    reported = CORRESPONDING #( DEEP lt_reported ) .

  ENDMETHOD.

ENDCLASS.
