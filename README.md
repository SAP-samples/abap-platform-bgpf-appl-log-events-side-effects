[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/abap-platform-bgpf-appl-log-events-side-effects)](https://api.reuse.software/info/github.com/SAP-samples/abap-platform-bgpf-appl-log-events-side-effects)

# How to use BGPF and events for side effects in ABAP RESTful programming model   
<!--- Register repository https://api.reuse.software/register, then add REUSE badge:
[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/REPO-NAME)](https://api.reuse.software/info/github.com/SAP-samples/REPO-NAME)
-->

## Description

In this repository you will find a simple RAP business object that simulates an inventory application. Since the calculation of inventories is a long running process this process is started asynchronously using the background processing framework (BGPF).

In the following animation check out the field **Quantitity**. When the button of the action that starts the calculation the process to caluclate the inventory of that product the UI is automatically updated after the entity itself has been updated.  

![Inventory App](../../blob/main/images/bgpf_side_effects.gif)

So when pressing the button *Calculate inventory* on the Fiori UI of our RAP application an action `reCalculateInventory` is being executed which simply updates the field `BgpfStatus. 

<pre>action reCalculateInventory;</pre>

This way we can check in the `save_modifed( )` method of our local saver class whether the *Calculate Inventory* button has been pressed. The asynchronous process is conveniently started within the `save_modifed( )` method using a class with a static method that takes the key of the updated entity of our RAP BO as a parameter

<pre>
 DATA(bgpf_process_name) = zbgpfcl_calc_inventory_006=>run_via_bgpf( i_rap_bo_entity_key = update_inventory-%key ).
</pre>

The background process is registered and being executed immediatley after the RAP framework has performed the COMMIT WORK statement.

When the background process finishes, it updates the entity of our RAP business objects using an EML call.  

<pre>
      MODIFY ENTITIES OF ZBGPFR_InventoryTP_006  
             ENTITY Inventory  
               UPDATE FIELDS ( Quantity )  
               WITH update  
               REPORTED DATA(reported_ready)  
               FAILED DATA(failed_ready).  
 </pre>

Again in the `save_modified( )` method we check that the field `Quantity` has been updated. And if yes this raises the event `QuantityUpdated`.  

<pre>
       IF <update_inventory>-%control-Quantity = if_abap_behv=>mk-on.  
          CLEAR events_to_be_raised.  
          APPEND INITIAL LINE TO events_to_be_raised.  
          events_to_be_raised[ 1 ] = CORRESPONDING #( <update_inventory> ).  
          RAISE ENTITY EVENT zbgpfr_inventorytp_006~QuantityUpdated FROM events_to_be_raised.  
       ENDIF.  
</pre>

In the behavior definition we only have to specify a side effect for events which will cause a read request for the field `Quantity`. As a result the field `Quantity` will be updated in the UI immediately once the long running process that calculates the inventory has finished. The end user is notified via a small popup.  

<pre>
  // side effect events
  event QuantityUpdated for side effects;

  side effects
  {
    event QuantityUpdated affects field ( Quantity );
  } 
</pre>

To get things working you have to make sure that the event is published via the behavior definition of your projection layer.   

The projection behavior has to allow on business object level the use of side effects and on entity level the use of the event itself (and in our case the use of the action as well).

<pre>
use draft;  
use side effects;  
define behavior for ZBGPFC_InventoryTP_006 alias Inventory  
use etag  

{ 
  use action reCalculateInventory;  
  use event QuantityUpdated;  
  ...   
</pre>

## Requirements

- **BGPF** is available for private cloud and on premise SAP S/4HANA Systems as of release 2023
- **Event Driven Side Effects** are currently only available in SAP BTP ABAP Environment and SAP S/4HANA public cloud ABAP Environment. We plan to make this available for on premise and private cloud systems as of release 2025 

## Download and Installation

Check out the following tutorial [Import Content from abapGit Repository into the BTP ABAP Environment](https://community.sap.com/t5/technology-blogs-by-members/import-content-from-abapgit-repository-into-the-btp-abap-environment/ba-p/13559990).   

## Known Issues

none

## How to obtain support
[Create an issue](https://github.com/SAP-samples/<repository-name>/issues) in this repository if you find a bug or have questions about the content.
 
For additional support, [ask a question in SAP Community](https://answers.sap.com/questions/ask.html).

## Contributing
If you wish to contribute code, offer fixes or improvements, please send a pull request. Due to legal reasons, contributors will be asked to accept a DCO when they create the first pull request to this project. This happens in an automated fashion during the submission process. SAP uses [the standard DCO text of the Linux Foundation](https://developercertificate.org/).

## License
Copyright (c) 2024 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSES/Apache-2.0.txt) file.
