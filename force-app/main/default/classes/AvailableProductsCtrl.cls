/**
 * description       : Controller class of the LWC availableProducts
 * author            : Shreyashi Sarkar
 * last modified on  : 03-24-2022
 * last modified by  : Shreyashi Sarkar
**/
public with sharing class AvailableProductsCtrl {
    @AuraEnabled public static Order order {get;set;}
    @AuraEnabled public static String status {get;set;}

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String ordId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        List<PricebookEntry> existingPriceBookList = new List<PricebookEntry>();
        existingPriceBookList = phInstance.getPBListFromOrder(ordId);
        List<PricebookEntry> priceBookList = phInstance.getPBList(ordId);
        existingPriceBookList.addAll(priceBookList);
        return existingPriceBookList;
    }
    @AuraEnabled
    public static string addProducts(List<PricebookEntry> priceBookList,String OrderId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        status = phInstance.addProducts(priceBookList,OrderId);
        return status;
    }
    @AuraEnabled
    public static Order getOrder(String orderId){
        ProductsHelper phInstance = ProductsHelper.getInstance();
        order= phInstance.getOrder(orderId);
        return order;
    }
}