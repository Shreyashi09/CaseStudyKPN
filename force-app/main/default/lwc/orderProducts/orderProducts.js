import { LightningElement,wire,api } from 'lwc';
import getOrderItems from '@salesforce/apex/OrderProductsCtrl.getOrderItemsList';
import updateStatus from '@salesforce/apex/OrderProductsCtrl.updateStatus';
import getOrderStatus from '@salesforce/apex/OrderProductsCtrl.getOrder';
import ORDER_ACTIVATION_SUCCESS_MESSAGE from '@salesforce/label/c.ORDER_ACTIVATION_SUCCESS_MESSAGE';
import ERROR_MESSAGE from '@salesforce/label/c.ERROR_MESSAGE';
import ERROR_STATUS from '@salesforce/label/c.ERROR_STATUS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import message service feature
import { subscribe,APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import addOrderItemEvent from '@salesforce/messageChannel/addOrderItemEvent__c';
//Order Item Table Columns
const orderItemColumns= [{label: 'Name', fieldName: 'Name', sortable: "true"},
                        {label: 'Unit Price', fieldName: 'UnitPrice', type: 'Currency',sortable: "true"},
                        {label: 'Quantity', fieldName: 'Quantity', type: 'Number',sortable: "true"},
                        {label: 'Total Price', fieldName: 'TotalPrice', type: 'Currency',sortable: "true"}];
const ORDER_STATUS = 'Activated';
export default class OrderProducts extends LightningElement {
    labels ={
        ORDER_ACTIVATION_SUCCESS_MESSAGE,
        ERROR_MESSAGE,
        ERROR_STATUS
    };
    columns = orderItemColumns;
    @api recordId;
    error;
    orderItemList = [];
    subscription = null;
    isOrderItemsAvailable = false;
    isActivated = false;
    //sorting attributes
    sortDirection;
    sortBy;
    //pagination attributes
    rowNumberOffset;
    recordsToDisplay = [];
    eventClone={};

    // to get the message context
    @wire(MessageContext) messageContext;    
    connectedCallback(){
        this.subscribeToMessageChannel();
        this.getOrderItemsTableData();
        this.getStatus();
    }
    // function for Activate button
    getActivated(){
        updateStatus({orderId: this.recordId})
        .then(result =>{
            this.notifyToUser(result,this.labels.ORDER_ACTIVATION_SUCCESS_MESSAGE);
            window.location.reload(); // refresh the page
        }).catch(error =>{
            this.notifyToUser(this.labels.ERROR_STATUS,this.labels.ERROR_MESSAGE);
        });
    }
    //hide Actiate button if ORDER status == 'Activated
   getStatus(){
        getOrderStatus({orderId: this.recordId})
        .then(result =>{
            if(result.Status === ORDER_STATUS){
                this.isActivated = true;
            }
            else{
                this.isActivated = false;
            }
        }).catch(error =>{
            console.log('error is ------>'+JSON.parse( JSON.stringify( error ) ));
        });
    }
    
   getOrderItemsTableData(){
        console.log('from getordertable method');
        let tableData = [];
        getOrderItems({ordId: this.recordId})
        .then(result => {
            if(result.length > 0){
                let i = 1;
                result.forEach(orderItem => {
                    let orderItemTable = {}
                    orderItemTable.Name = orderItem.Product2.Name;
                    orderItemTable.UnitPrice = orderItem.UnitPrice;
                    orderItemTable.Quantity = orderItem.Quantity;
                    orderItemTable.TotalPrice = orderItem.TotalPrice;
                    orderItemTable.rowNumber = ''+ i++;
                    tableData.push(orderItemTable);
                });
            }
            this.orderItemList = tableData;
            this.error = undefined;
            this.isOrderItemsAvailable = true;
        }).catch(error =>{
            this.orderItemList = undefined;
            this.error = error ;
            this.isOrderItemsAvailable = true;
        });
    }
    handlePaginatorChange(event){
        this.eventClone = Object.assign(this.eventClone, event);
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }
    //sorting funstions
    performColumnSorting(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy,this.sortDirection);
    }
    // sortData function --- used for sorting 
    sortData(fieldName,direction){
        let oiTable = JSON.parse(JSON.stringify(this.recordsToDisplay));
        //return the value sorted in the field
        let key_Value = (val) =>{
            return val[fieldName];
        }
        //checking reverse direction 
        let isReverse = direction === 'asc'?1:-1;
        //sorting data
        oiTable.sort((x,y) =>{
            x = key_Value(x) ? key_Value(x) : '';
            y = key_Value(y) ? key_Value(y) : ''; // handling null values
            //soritng values based on direction
            return isReverse * ((x>y)-(y>x));
        });
        //set the sorted data into table
        this.recordsToDisplay = oiTable;
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
        }
    }

    handleMessage(){
        this.isOrderItemsAvailable = false;
        this.getOrderItemsTableData();
        handlePaginatorChange(this.eventClone);
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