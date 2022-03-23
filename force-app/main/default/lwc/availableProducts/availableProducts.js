import { LightningElement,wire,api } from 'lwc';
import getAvailableProducts from '@salesforce/apex/AvailableProductsCtrl.getAvailableProducts';
import addProducts from '@salesforce/apex/AvailableProductsCtrl.addProducts';
import getOrderStatus from '@salesforce/apex/AvailableProductsCtrl.getOrder';
import PRODUCT_ADD_SUCCESS_MESSAGE from '@salesforce/label/c.ADD_PRODUCT_SUCCESS_MESSAGE';
import ADD_PRODUCT_WARNING_MESSAGE from '@salesforce/label/c.ADD_PRODUCT_WARNING_MESSAGE';
import WARNING_STATUS from '@salesforce/label/c.WARNING_STATUS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish,MessageContext,APPLICATION_SCOPE } from 'lightning/messageService';
import addOrderItemEvent from '@salesforce/messageChannel/addOrderItemEvent__c';
//Available Product Table Columns
const availableItemsColumns = [{label: 'Name', fieldName: 'Name', sortable: "true"},
                               {label: 'List Price', fieldName: 'UnitPrice', type: 'Currency',sortable: "true"}];
// Order status on page load
const ORDER_STATUS = 'Activated';

export default class AvailableProducts extends LightningElement {
        //custom label
        labels ={
            PRODUCT_ADD_SUCCESS_MESSAGE,
            ADD_PRODUCT_WARNING_MESSAGE,
            WARNING_STATUS	
        };
    columns = availableItemsColumns;
    @api recordId;
    error;
    isActivated = false //it is used to verify the order status on page load
    isHideColumnCheckbox = false;
    isProductsAvailable = false;
    availableItemList = []; //is it used to keep available table data
    selectedProducts = [];
    @wire(MessageContext) messageContext;
    //sorting attributes
    sortBy;
    sortDirection;
    //pagination attributes
    rowNumberOffset;
    recordsToDisplay = [];

    @wire(getAvailableProducts,{ordId: '$recordId'})
    wiredavailableItemData({ data, error }){
        if(data){
            let productTableData = JSON.parse( JSON.stringify( data ) );
            let i = 1;
            productTableData = productTableData.map( row => {
                row.rowNumber = ''+ i++;
                return { ...row, Name: row.Product2.Name};
            })
            this.availableItemList = productTableData;
            this.error = undefined;
            this.isProductsAvailable = true;

        }
        else if(error){
            this.availableItemList = undefined;
            this.error = error;
            this.isProductsAvailable = true;

        }
    }
    handlePaginatorChange(event){
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
        let prodTable = JSON.parse(JSON.stringify(this.recordsToDisplay));
        //return the value sorted in the field
        let key_Value = (val) =>{
            return val[fieldName];
        }
        //checking reverse direction 
        let isReverse = direction === 'asc'?1:-1;
        //sorting data
        prodTable.sort((x,y) =>{
            x = key_Value(x) ? key_Value(x) : '';
            y = key_Value(y) ? key_Value(y) : ''; // handling null values
            //soritng values based on direction
            return isReverse * ((x>y)-(y>x));
        });
        //set the sorted data into table
        this.recordsToDisplay = prodTable;
    }
    connectedCallback(){
        this.getOrderStatusOnLoad();
    }

    // hide Add Products and multi select checkbox from Add Product table when order status is Activated
    getOrderStatusOnLoad(){
        getOrderStatus({orderId: this.recordId})
        .then(result =>{
            if(result.Status === ORDER_STATUS){
                this.isActivated = true;
                this.isHideColumnCheckbox = true;
            }
            else{
                this.isActivated = false;
                this.isHideColumnCheckbox = false;
            }
        }).catch(error =>{
            console.log('error is ------>'+JSON.parse( JSON.stringify( error ) ));
        });
    }
    getSelectedProducts(event){
        this.selectedProducts = event.detail.selectedRows;
    }
    addSelectedProducts(event){
        let orderId = this.recordId;
        let selectedProductsList = this.selectedProducts;
        let priceBookList = [];

        if(selectedProductsList.length == 0){
            this.notifyToUser(this.labels.WARNING_STATUS,this.labels.ADD_PRODUCT_WARNING_MESSAGE);
        }
        else{
            selectedProductsList.forEach(selectedProduct => {
                let pBEntry = {'sobjecttype':'PricebookEntry'};
                pBEntry.Id = selectedProduct.Id;
                pBEntry.UnitPrice = selectedProduct.UnitPrice;
                priceBookList.push(pBEntry);
            });
            // call apex method
            addProducts({priceBookList:priceBookList,OrderId:orderId})
            .then(result =>{
                this.notifyToUser(result,this.labels.PRODUCT_ADD_SUCCESS_MESSAGE);
                publish(this.messageContext,addOrderItemEvent);
            }).catch( error =>{console.log('Warning!')});
        }
    }

    notifyToUser(status,message){
        const notifyEvent = new ShowToastEvent({
            message: message,
            variant: status,
        });
        this.dispatchEvent(notifyEvent);
    }
}