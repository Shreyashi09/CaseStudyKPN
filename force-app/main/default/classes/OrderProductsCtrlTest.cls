@isTest
public class OrderProductsCtrlTest {
    @TestSetup
    static void createCommonTestRecords(){
        Account testAccount = TestDataFactory.createAccount();
        Contract testContract = TestDataFactory.createContract(testAccount.Id);
        PricebookEntry testPriceBook = TestDataFactory.createPricebookEntry();
        Order testOrder = TestDataFactory.createOrder(testAccount.Id,testContract.Id);
        Product2 testProduct = TestDataFactory.createProduct2();
        //insert Order Item
        OrderItem item1 = new OrderItem();
        item1.OrderId = testOrder.Id;
        item1.Product2Id = testProduct.Id;
        item1.Quantity = 1;
        item1.PricebookEntryId = testPriceBook.Id;
        item1.UnitPrice = 200;
        insert item1;
    }
   @IsTest
   static void getOrderItemsList(){
        Order ord = [SELECT ID FROM ORDER LIMIT 1];
        List<OrderItem> ordList = OrderProductsCtrl.getOrderItemsList(ord.Id);
        system.assertEquals(1,ordList.size(),'PASS');
   } 
   @isTest
   static void updateStatus(){
    Test.startTest();
    Order ord = [SELECT ID FROM ORDER LIMIT 1];
    String result = OrderProductsCtrl.updateStatus(ord.Id);
    system.assertEquals('Success',result,'PASS');
    Test.stopTest();
   }
    @isTest
    static void getOrder(){
    Order ord = [SELECT ID FROM ORDER LIMIT 1];
    Order existingOrder = OrderProductsCtrl.getOrder(ord.Id);
    system.assertEquals('Draft',existingOrder.Status,'PASS');
   }
}