CLASS zbgpfcl_calc_inventory_006 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES if_bgmc_operation .
    INTERFACES if_bgmc_op_single_tx_uncontr.
    INTERFACES if_bgmc_op_single .

    TYPES: BEGIN OF ts_rap_bo_entity_key,
             uuid TYPE sysuuid_x16,
           END OF ts_rap_bo_entity_key.

    CLASS-METHODS run_via_bgpf
      IMPORTING i_rap_bo_entity_key             TYPE ts_rap_bo_entity_key
      RETURNING VALUE(r_process_monitor_string) TYPE string
      RAISING   cx_bgmc.

    CLASS-METHODS run_via_bgpf_tx_uncontrolled
      IMPORTING i_rap_bo_entity_key             TYPE   ts_rap_bo_entity_key
      RETURNING VALUE(r_process_monitor_string) TYPE string
      RAISING   cx_bgmc.

    METHODS constructor
      IMPORTING i_rap_bo_entity_key TYPE ts_rap_bo_entity_key.

    CONSTANTS :
      BEGIN OF bgpf_state,
        unknown         TYPE int1 VALUE IS INITIAL,
        erroneous       TYPE int1 VALUE 1,
        new             TYPE int1 VALUE 2,
        running         TYPE int1 VALUE 3,
        successful      TYPE int1 VALUE 4,
        started_from_bo TYPE int1 VALUE 99,
      END OF bgpf_state.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA inventory_uuid TYPE ts_rap_bo_entity_key-uuid.
    CONSTANTS wait_time_in_seconds TYPE i VALUE 5.



ENDCLASS.



CLASS zbgpfcl_calc_inventory_006 IMPLEMENTATION.

  METHOD constructor.
    inventory_uuid = i_rap_bo_entity_key-uuid.
  ENDMETHOD.

  METHOD if_bgmc_op_single~execute.

    DATA update TYPE TABLE FOR UPDATE ZBGPFR_InventoryTP_006\\Inventory.
    DATA update_line TYPE STRUCTURE FOR UPDATE ZBGPFR_InventoryTP_006\\Inventory .

    WAIT UP TO  wait_time_in_seconds SECONDS.

    READ ENTITIES OF ZBGPFR_InventoryTP_006
             ENTITY Inventory
             ALL FIELDS
             WITH VALUE #( ( %is_draft = if_abap_behv=>mk-off
                             %key-uuid = inventory_uuid
                            )  )
             RESULT DATA(entities)
             FAILED DATA(failed).

    IF entities IS NOT INITIAL.

      LOOP AT entities INTO DATA(entity).

        update_line-%is_draft = if_abap_behv=>mk-off.
        update_line-uuid = entity-uuid.
        update_line-Quantity = entity-Quantity + 10.

        APPEND update_line TO update.

      ENDLOOP.

      MODIFY ENTITIES OF ZBGPFR_InventoryTP_006
             ENTITY Inventory
               UPDATE FIELDS ( Quantity )
               WITH update
               REPORTED DATA(reported_ready)
               FAILED DATA(failed_ready).

    ENDIF.
  ENDMETHOD.

  METHOD if_bgmc_op_single_tx_uncontr~execute.
    "implement if uncontrolled behavior is needed, e.g. commit work statements
  ENDMETHOD.

  METHOD run_via_bgpf.
    TRY.
        DATA(process_monitor) = cl_bgmc_process_factory=>get_default( )->create(
                                              )->set_name( |Calculate inventory data|
                                              )->set_operation(  NEW zbgpfcl_calc_inventory_006( i_rap_bo_entity_key = i_rap_bo_entity_key )
                                              )->save_for_execution( ).

        r_process_monitor_string = process_monitor->to_string( ).

      CATCH cx_bgmc INTO DATA(lx_bgmc).



    ENDTRY.
  ENDMETHOD.

  METHOD run_via_bgpf_tx_uncontrolled.
    TRY.
        DATA(process_monitor) = cl_bgmc_process_factory=>get_default( )->create(
                                              )->set_name( |Calculate inventory data|
                                              )->set_operation_tx_uncontrolled(  NEW zbgpfcl_calc_inventory_006( i_rap_bo_entity_key = i_rap_bo_entity_key )
                                              )->save_for_execution( ).

        r_process_monitor_string = process_monitor->to_string( ).

      CATCH cx_bgmc INTO DATA(lx_bgmc).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
