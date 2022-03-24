/**
 * description       : Test class is for AvailableProductsCtrl
 * author            : Shreyashi Sarkar
 * last modified on  : 03-24-2022
 * last modified by  : Shreyashi Sarkar
**/
@isTest
public class AvailableProductsCtrlTest {
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
       	//create test data for Product2 and PriceBook for addPrdoucts method.
        Product2 testProductNew =  new Product2();
        testProductNew.Name = 'Test New Product';
        testProductNew.Description = 'This is used for addProducts method';
        testProductNew.ProductCode = 'Test1010';
        testProductNew.isActive = true;
        insert testProductNew;

        Id stdNewPriceBookRecId = Test.getStandardPricebookId();
        PricebookEntry priceBookNew = new PricebookEntry();
        priceBookNew.Pricebook2Id = stdNewPriceBookRecId;
        priceBookNew.Product2Id=testProductNew.Id;
        priceBookNew.UnitPrice=2020;
        priceBookNew.IsActive=true;
        priceBookNew.UseStandardPrice = false;
        insert priceBookNew;
    
    }
    @isTest
    static void addProductsWithExistingOrderItem(){
        Test.startTest();
        PricebookEntry pB = [SELECT ID FROM PricebookEntry LIMIT 1];
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        pbList.add(pB);
        Order ord = [SELECT ID FROM ORDER LIMIT 1];
        String result = AvailableProductsCtrl.addProducts(pbList,ord.Id);
        system.assertEquals('Success',result,'PASS');
        Test.stopTest();
    }
    @isTest
    static void addProducts(){
        Test.startTest();
        PricebookEntry pB = [SELECT ID,UnitPrice FROM PricebookEntry WHERE UnitPrice= 2020 LIMIT 1];
        List<PricebookEntry> pbList = new List<PricebookEntry>();
        pbList.add(pB);
        Order ord = [SELECT ID FROM ORDER LIMIT 1];
        String result = AvailableProductsCtrl.addProducts(pbList,ord.Id);
        system.assertEquals('Success',result,'PASS');
        Test.stopTest();
    }
    @isTest
    static void getAvailableProducts(){
        Order ord = [SELECT ID FROM ORDER LIMIT 1];
        List<PricebookEntry> pbList = AvailableProductsCtrl.getAvailableProducts(ord.Id);
        system.assertEquals(0,pbList.size(),'PASS');
    }
    @isTest
    static void getOrder(){
        Order ord = [SELECT ID FROM ORDER LIMIT 1];
        Order existingOrder = AvailableProductsCtrl.getOrder(ord.Id);
        system.assertEquals('Draft',existingOrder.Status,'PASS');
    }
}