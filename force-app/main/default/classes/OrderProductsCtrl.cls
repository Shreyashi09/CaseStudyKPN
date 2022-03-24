/**
 * description       : This class is for orderProducts
 * author            : Shreyashi Sarkar
 * last modified on  : 03-24-2022
 * last modified by  : Shreyashi Sarkar
**/
public with sharing class OrderProductsCtrl {
    @AuraEnabled public static Order order {get;set;}
    @AuraEnabled public static String response {get;set;}

    @AuraEnabled
    public static List<OrderItem> getOrderItemsList(String ordId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
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
        order= phInstance.getOrder(orderId);
        return order;
    }
}