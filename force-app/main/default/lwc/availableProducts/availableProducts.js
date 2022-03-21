import { LightningElement,wire,api } from 'lwc';
import getAvailableProducts from '@salesforce/apex/AvailableProductsCtrl.getAvailableProducts';
import addProducts from '@salesforce/apex/AvailableProductsCtrl.addProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish,MessageContext,APPLICATION_SCOPE } from 'lightning/messageService';
import addOrderItemEvent from '@salesforce/messageChannel/addOrderItemEvent__c';
//Available Product Table Columns
const availableItemsColumns = [{label: 'Name', fieldName: 'Name', sortable: "true"},
                               {label: 'List Price', fieldName: 'UnitPrice', type: 'Currency',sortable: "true"}];
export default class AvailableProducts extends LightningElement {
    columns = availableItemsColumns;
    @api recordId;
    error;
    isProductsAvailable = false;
    availableItemList = []; //is it used to keep available table data
    selectedProducts = [];
    @wire(MessageContext) messageContext;
    //  sorting attributes
    sortBy;
    sortDir;
    @wire(getAvailableProducts,{ordId: '$recordId'})
    wiredavailableItemData({ data, error }){
        if(data){
            let productTableData = JSON.parse( JSON.stringify( data ) );
            productTableData = productTableData.map( row => {
                return { ...row, Name: row.Product2.Name, Family: row.Product2.Family };
            })
            this.availableItemList = productTableData;
            console.log(productTableData);
            this.error = undefined;
            this.isProductsAvailable = true;

        }
        else if(error){
            this.availableItemList = undefined;
            this.error = error;
            this.isProductsAvailable = true;

        }
    }
    //sorting funstions
    performColumnSorting(event){
        this.sortBy = event.detail.fieldName;
        this.sortDir = event.detail.sortDir;
        this.sortData(this.sortBy,this.sortDir);
    }
    // sortData function --- used for sorting 
    sortData(fieldName,direction){
        let prodTable = JSON.parse(JSON.stringify(this.availableItemList));
        //return the value sorted in the field
        let key_value = (val) =>{
            return val[fieldName];
        }
        //checking reverse direction 
        let isReverse = direction === 'asc'?1:-1;
        //sorting data
        prodTable.sort((x,y) =>{
            x = key_value(x) ? key_value(x): '';
            y = key_value(y) ? key_value(y): ''; // handling null values
            //soritng values based on direction
            return isReverse * ((x>y)-(y>x));
        });
        //set the sorted data into table
        this.availableItemList = prodTable;
    }
    connectedCallback(){
        //this.getAvailableProductsTableData();
    }
    getAvailableProductsTableData(){
        let tableData = [];
        getAvailableProducts({ordId : this.recordId})
        .then(result =>{
            if(result.length > 0){
                result.forEach(item =>{
                    let dataToTable = {}
                    dataToTable.Name = item.Product2.Name;
                    dataToTable.UnitPrice = item.UnitPrice;
                    tableData.push(dataToTable);
                })
            }
            this.availableItemList = tableData;
            this.error = undefined;
            this.isProductsAvailable = true;
        }).catch(error =>{
            this.availableItemList = undefined;
            this.error = error;
            this.isProductsAvailable = true;
        });
    }
    getSelectedProducts(event){
        this.selectedProducts = event.detail.selectedRows;
        console.log('selected products ------->'+this.selectedProducts);
    }
    addSelectedProducts(event){
        console.log('from addSelectedProducts-------->')
        let orderId = this.recordId;
        let selectedProductsList = this.selectedProducts;
        let priceBookList = [];
        console.log('from addSelectedProducts-------->'+selectedProductsList.length);

        if(selectedProductsList.length == 0){
            console.log('no products to be added');
            this.notifyToUser('WARNING','PLEASE SELECT AT LEAST ONE PRODUCT');
        }
        else{
            console.log('from else----->');
            selectedProductsList.forEach(selectedProduct => {
                let pBEntry = {'sobjecttype':'PricebookEntry'};
                pBEntry.Id = selectedProduct.Id;
                pBEntry.UnitPrice = selectedProduct.UnitPrice;
                priceBookList.push(pBEntry);
            });
            console.log('priceBookList----->'+priceBookList.length);

            // call apex method
            addProducts({priceBookList:priceBookList,OrderId:orderId})
            .then(result =>{
                console.log('items added'+result);
                this.notifyToUser('SUCCESS','SELECTED PRODUCTS ARE ADDED');
                const payload = {recordId: event.target}
                // console.log('this.messageContext-------->'+this.messageContext);
                // console.log('this.addOrderItemEvent-------->'+addOrderItemEvent);
                publish(this.messageContext,addOrderItemEvent,payload);
                console.log('after publish ---->');
            }).catch( error =>{
                console.log('error------>'+error);
                this.notifyToUser('ERROR','SORRY THERE IS AN ISSUE');
            });
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