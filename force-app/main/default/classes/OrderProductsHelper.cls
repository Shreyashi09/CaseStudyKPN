public class OrderProductsHelper {
    public static List<OrderItem> getOrderItems(String orderRecordId){
        String orderItemQuery = 'SELECT Id,Product2.Name,UnitPrice,Quantity,TotalPrice from OrderItem WHERE ORDERID =: orderRecordId WITH SECURITY_ENFORCED';
        return Database.query(orderItemQuery);
    }
    public static List<OrderItem> getOrderItemsFromOrder(String orderRecordId){
        String itemsFromOrderQuery = 'SELECT Product2Id,Product2.Name from OrderItem WHERE ORDERID =: orderRecordId WITH SECURITY_ENFORCED';
        return Database.query(itemsFromOrderQuery);
    }
    public static List<PricebookEntry> getPBListFromOrder(String orderRecordId){
        List<OrderItem> existingProducts = getOrderItemsFromOrder(orderRecordId);       
        Set<String> existingItemList = new Set<String>();
        for(OrderItem productName : existingProducts){
            existingItemList.add(productName.Product2.Name);
        }
        String pBListQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Product2.Name IN :existingItemList AND Pricebook2.name=\'Standard Price Book\'  WITH SECURITY_ENFORCED';
        return Database.query(pBListQuery);
    }
    public static List<PricebookEntry> getPBList(String orderRecordId){
        List<OrderItem> existingProducts = getOrderItemsFromOrder(orderRecordId);
        Set<String> existingItemList = new Set<String>();
        for(OrderItem productName : existingProducts){
            existingItemList.add(productName.Product2.Name);
        }
        String priceBookEntryQuery = 'SELECT ID,Product2.Name,UnitPrice FROM PricebookEntry WHERE Product2.Name NOT IN :existingItemList AND Pricebook2.name=\'Standard Price Book\'  WITH SECURITY_ENFORCED';
        return Database.query(priceBookEntryQuery);
    }

}