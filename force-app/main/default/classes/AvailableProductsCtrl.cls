public with sharing class AvailableProductsCtrl {
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
        return phInstance.addProducts(priceBookList,OrderId);
    }

}