public with sharing class OrderProductsCtrl {
    @AuraEnabled public static Order order {get;set;}
    @AuraEnabled public static String response {get;set;}

    @AuraEnabled
    public static List<OrderItem> getOrderItemsList(String ordId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        system.debug('from order ctrl and ord id ---------->'+ordId);
        return phInstance.getOrderItemsFromOrder(ordId);
    }
    @AuraEnabled
    public static String updateStatus(String orderId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        response = phInstance.updateStatus(orderId);
        return response;
    }
    @AuraEnabled
    public static Order getOrder(String orderId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        system.debug('from getOrder method -------->'+phInstance.getOrder(orderId));
        order= phInstance.getOrder(orderId);
        return order;
    }
}