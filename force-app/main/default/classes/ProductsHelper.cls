/**
 * description       : Helper class contains all DML functions
 * author            : Shreyashi Sarkar
 * last modified on  : 03-24-2022
 * last modified by  : Shreyashi Sarkar
**/
public class ProductsHelper {
    private static ProductsHelper instance = null;
    public static ProductsHelper getInstance(){
        if(instance == null){
            instance = new ProductsHelper();
        }
        return instance;
    }
    public String updateStatus(String orderId){
        String statusStr = '';
        Order ord = [SELECT ID,STATUS FROM ORDER WHERE ID= :orderId WITH SECURITY_ENFORCED];
        List<OrderItem> itemList = getOrderItemsFromOrder(orderId);
        List<OrderItem> updatedItemList = new List<OrderItem>();
        try{
            //update Order Status
            if(ord != null){
                ord.Status = 'Activated';
               update ord;
            }
            // Update related order items status
            for(OrderItem item : itemList){
                item.Status__c = 'Activated';
                updatedItemList.add(item);
            }
            if(updatedItemList.size() > 0){
                Database.update(updatedItemList);
            }
            statusStr = 'Success';
        }
        catch (Exception e) {
            statusStr ='Error';
            throw new AuraHandledException(e.getMessage());
        } 
        return statusStr;
    }
    public List<OrderItem> getOrderItemsFromOrder(String orderRecordId){
        String itemsFromOrderQuery = 'SELECT Id,Status__c,UnitPrice,TotalPrice,PricebookEntryId,Product2Id,Product2.Name,Quantity from OrderItem WHERE ORDERID =: orderRecordId WITH SECURITY_ENFORCED';
        return Database.query(itemsFromOrderQuery);
    }
    public List<PricebookEntry> getPBListFromOrder(String orderRecordId){
        List<OrderItem> existingProducts = getOrderItemsFromOrder(orderRecordId);       
        Set<String> existingItemList = new Set<String>();
        for(OrderItem ordItem : existingProducts){
           existingItemList.add(ordItem.PricebookEntryId);
        }
        String pBListQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Id IN :existingItemList AND Pricebook2.name=\'Standard\' WITH SECURITY_ENFORCED';
        return Database.query(pBListQuery);
    }
    public List<PricebookEntry> getPBList(String orderRecordId){
        List<OrderItem> existingProducts = getOrderItemsFromOrder(orderRecordId);
        Set<String> existingItemList = new Set<String>();
        for(OrderItem ordItem : existingProducts){
            existingItemList.add(ordItem.PricebookEntryId);
         }
        String priceBookEntryQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Id NOT IN :existingItemList AND Pricebook2.name=\'Standard\' WITH SECURITY_ENFORCED';
        return Database.query(priceBookEntryQuery);
    }
    public String addProducts(List<PricebookEntry> priceBookList,String OrderId){
        List<OrderItem> existingItems = getOrderItemsFromOrder(OrderId);
        List<OrderItem> itemsToBeAdded = new List<OrderItem>();
        Map<Id,OrderItem> itemsByPB = new Map<Id,OrderItem>();
        String status = '';
        try {
            // when new order with zero Order Item
            if(existingItems.size() ==0){
                Order orderNew = getOrder(OrderId);
                if(orderNew.Pricebook2Id == null){
                    PricebookEntry pbe = [SELECT Pricebook2Id FROM PricebookEntry where pricebook2.name = 'Standard' WITH SECURITY_ENFORCED LIMIT 1];     
                    orderNew.Pricebook2Id = pbe.Pricebook2Id;
                }
                update orderNew;
            }
            
            for(OrderItem item : existingItems){
                itemsByPB.put(item.PricebookEntryId,item);
            }
            if(priceBookList.size() > 0){
                for(PricebookEntry pB : priceBookList){
                    if(itemsByPB.keySet().contains(pB.Id)){
                        itemsByPB.get(pB.Id).Quantity ++;
                        itemsToBeAdded.add(itemsByPB.get(pB.Id));
                        continue;
                    }
                    OrderItem orderItem = new OrderItem();
                    orderItem.OrderId = OrderId;
                    orderItem.UnitPrice = pB.UnitPrice;
                    orderItem.PricebookEntryId = pB.Id;
                    orderItem.Quantity = 1;                    
                    itemsToBeAdded.add(orderItem);
                }
            }
            if(itemsToBeAdded.size() > 0){
                Database.Upsert(itemsToBeAdded);
                status = 'Success';
            }
        }
        catch (Exception e) {
            status = 'Error';
            throw new AuraHandledException(e.getMessage());
        }  
        return status; 
    }
    public Order getOrder(String orderId){
        Order ord = [SELECT ID,STATUS,Pricebook2Id FROM ORDER WHERE ID= :orderId WITH SECURITY_ENFORCED];
        return ord;
    }
}