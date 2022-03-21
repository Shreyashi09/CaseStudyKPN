import { LightningElement,wire,api } from 'lwc';
import getOrderItems from '@salesforce/apex/OrderProductsCtrl.getOrderItemsList';
import updateStatus from '@salesforce/apex/OrderProductsCtrl.updateStatus';
import getStatus from '@salesforce/apex/OrderProductsCtrl.getOrderStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import ORDER_STATUS from '@salesforce/schema/Order.Status';
//import message service feature
import { subscribe,APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import addOrderItemEvent from '@salesforce/messageChannel/addOrderItemEvent__c';
//Order Item Table Columns
const orderItemColumns= [{label: 'Name', fieldName: 'Name', sortable: "true"},
                        {label: 'Unit Price', fieldName: 'UnitPrice', type: 'Currency',sortable: "true"},
                        {label: 'Quantity', fieldName: 'Quantity', type: 'Number',sortable: "true"},
                        {label: 'Total Price', fieldName: 'TotalPrice', type: 'Currency',sortable: "true"}];
const orderStatus = 'Draft';
const field = [ORDER_STATUS];
export default class OrderProducts extends LightningElement {
    columns = orderItemColumns;
    @api recordId;
    error;
    orderItemList = [];
    subscription = null;
    isOrderItemsAvailable = false;
    isActivated = false;
    ordStatus;
    // to get the message context
    @wire(MessageContext) messageContext;
    /*@wire(getRecord,{recordId: '$recordId',fields: [ORDER_STATUS]})
    order;
    get status(){
        return getFieldValue(this.order.data,ORDER_STATUS);
    }
    set status(val){
        this.ordStatus = val;
    }*/
   
    connectedCallback(){
        this.subscribeToMessageChannel();
        this.getOrderItemsTableData();
        // checking the order status
        //getStatus();
    }
    // function for Activate button
    getActivated(){
        updateStatus({orderId: this.recordId})
        .then(result =>{
            let status = result;
            this.isActivated = true;
            console.log('from then block ----- status ->'+status);
            this.notifyToUser('SUCCESS','Order is Activated now');
            // refresh the page
           // window.location.reload();
        }).catch(error =>{
            console.log('error is ------>'+error.message);
            this.isActivated = false;
            this.notifyToUser(error.message,'ERROR');
        });
    }
    //hide Actiate button if ORDER status == 'Activated
    /*getStatus(){
        getOrderStatus({orderId: this.recordId})
        .then(result =>{
            this.isActivated = true;
            console.log('data from status ----->'+JSON.parse( JSON.stringify( result ) ));
        }).catch(error =>{
            console.log('error is ------>'+JSON.parse( JSON.stringify( error ) ));
        });
    }
   /* @wire(getOrderStatus,{ordId: '$recordId'})
    order({data,error}){
        if(data){
            console.log('data from status ----->'+JSON.parse( JSON.stringify( data ) ));
            this.isActivated = true;
        }
        else if(error){
            //this.isActivated = false;
            console.log('from error blcok');
        }
    }*/
    getOrderItemsTableData(){
        console.log('from getordertable method');
        let tableData = [];
        getOrderItems({ordId: this.recordId})
        .then(result => {
            if(result.length > 0){
                result.forEach(orderItem => {
                    let orderItemTable = {}
                    //dataToTable.Id = orderItem.Id;
                    orderItemTable.Name = orderItem.Product2.Name;
                    orderItemTable.UnitPrice = orderItem.UnitPrice;
                    orderItemTable.Quantity = orderItem.Quantity;
                    orderItemTable.TotalPrice = orderItem.TotalPrice;
                    tableData.push(orderItemTable);
                });
            }
            this.orderItemList = tableData;
            console.log('from result block------>'+this.orderItemList);
            this.error = undefined;
            this.isOrderItemsAvailable = true;
        }).catch(error =>{
            console.log('from catch block------>');
            this.orderItemList = undefined;
            this.error = error ;
            this.isOrderItemsAvailable = true;
        });
    }
    // listen and handle the addOrderItemEvent
    subscribeToMessageChannel() {
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                addOrderItemEvent,
                (message) => this.handleMessage(),
                {scope : APPLICATION_SCOPE}
            );
            console.log('Inside Subscribe if statment');
        }
        console.log('Inside Subscribe if never executed');
    }
    handleMessage(){
        console.log('Finally handling the message');
        this.isOrderItemsAvailable = false;
        this.getOrderItemsTableData();
        this.isOrderItemsAvailable = true;
    }
    notifyToUser(status,message){
        const notifyEvent = new ShowToastEvent({
            message: message,
            variant: status,
        });
        this.dispatchEvent(notifyEvent);
    }
}