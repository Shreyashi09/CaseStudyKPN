public with sharing class OrderProductsCtrl {
    
    @AuraEnabled
    public static List<OrderItem> getOrderItemsList(String ordId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        system.System.debug('from order ctrl and ord id ---------->'+ordId);
        return phInstance.getOrderItemsFromOrder(ordId);
    }
    @AuraEnabled
    public static String updateStatus(String orderId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        return phInstance.updateStatus(orderId);
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getOrderStatus(String orderId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        return phInstance.getOrderStatus(orderId);
    }
}