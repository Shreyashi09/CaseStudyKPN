@isTest
public class OrderProductsCtrlTest {
   @IsTest
   static void getOrderItemsList(){
       
       Test.startTest();
       //System.runAs(contextuser){
        Account acc = TestDataFactory.createAccount();
        Contract con = TestDataFactory.createContract(acc.Id);
        PricebookEntry pB = TestDataFactory.createPricebookEntry();
        Order ord = TestDataFactory.createOrder(acc.Id,con.Id,pB.Id);
           List<OrderItem> ordList = OrderProductsCtrl.getOrderItemsList(ord.Id);
        system.debug('ordList size from test class------>'+ordList.size());
       //}
       Test.stopTest();
   } 
}
