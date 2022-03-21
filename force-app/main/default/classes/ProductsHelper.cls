public class ProductsHelper {
    public static ProductsHelper getInstance(){
        return new ProductsHelper();
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
            statusStr = 'Activated';
        }
        catch (Exception e) {
            statusStr =e.getMessage();
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
           // existingItemList.add(ordItem.Product2.Name);
           //existingItemList.add(ordItem.Product2Id);
           existingItemList.add(ordItem.PricebookEntryId);
        }
        String pBListQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Id IN :existingItemList AND Pricebook2.name=\'Standard\' WITH SECURITY_ENFORCED';
        //String pBListQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Product2.Name IN :existingItemList AND Pricebook2.name=\'Standard Price Book\'  WITH SECURITY_ENFORCED';
        return Database.query(pBListQuery);
    }
    public List<PricebookEntry> getPBList(String orderRecordId){
        List<OrderItem> existingProducts = getOrderItemsFromOrder(orderRecordId);
        Set<String> existingItemList = new Set<String>();
        for(OrderItem ordItem : existingProducts){
            // existingItemList.add(ordItem.Product2.Name);
            //existingItemList.add(ordItem.Product2Id);
            existingItemList.add(ordItem.PricebookEntryId);
         }
        //String priceBookEntryQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Product2.Name NOT IN :existingItemList AND Pricebook2.name=\'Standard Price Book\'  WITH SECURITY_ENFORCED';
        String priceBookEntryQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Id NOT IN :existingItemList AND Pricebook2.name=\'Standard\' WITH SECURITY_ENFORCED';
        return Database.query(priceBookEntryQuery);
    }
    public String addProducts(List<PricebookEntry> priceBookList,String OrderId){
        List<OrderItem> existingItems = getOrderItemsFromOrder(OrderId);
        List<OrderItem> itemsToBeAdded = new List<OrderItem>();
        Map<Id,OrderItem> itemsByPB = new Map<Id,OrderItem>();
        String status = '';
        try {
            for(OrderItem item : existingItems){
                itemsByPB.put(item.PricebookEntryId,item);
                //itemsByPB.put(item.Product2Id,item);
            }
            if(priceBookList.size() > 0){
                for(PricebookEntry pB : priceBookList){
                    if(itemsByPB.keySet().contains(pB.Id)){
                        //orderItem.Quantity = 1+ itemsByPB.get(pB.Id).Quantity;
                        itemsByPB.get(pB.Id).Quantity ++;
                        //orderItem.PricebookEntryId = itemsByPB.get(pB.Id).Id;
                        system.debug('existing item---->');
                        itemsToBeAdded.add(itemsByPB.get(pB.Id));
                        continue;
                    }
                    OrderItem orderItem = new OrderItem();
                    orderItem.OrderId = OrderId;
                    orderItem.UnitPrice = pB.UnitPrice;
                    orderItem.PricebookEntryId = pB.Id;
                    //orderItem.Product2Id = pB.Id;
                    orderItem.Quantity = 1;
                    // for existing Oreder Items for an Order
                    
                    itemsToBeAdded.add(orderItem);
                }
            }
            system.System.debug('itemsToBeAdded----------->'+itemsToBeAdded);
            if(itemsToBeAdded.size() > 0){
                Database.Upsert(itemsToBeAdded);
                status = 'Success';
            }
        }
        catch (Exception e) {
            system.debug('error------->'+e.getMessage());
            status = 'Error';
            throw new AuraHandledException(e.getMessage());
        }  
        return status; 
    }
    public Boolean getOrderStatus(String orderId){
        Boolean isOrderActive;
        Order ord = [SELECT ID,STATUS FROM ORDER WHERE ID= :orderId WITH SECURITY_ENFORCED];
        system.debug('Order from getOrderStatus method ------->'+orderId);
        if((ord != null) && (ord.Status == 'Activated'))
        isOrderActive = true;
        else 
        isOrderActive = false;
        return isOrderActive;
    }
}