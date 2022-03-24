/**
 * description       : TestDataFactory creates all test records
 * author            : Shreyashi Sarkar
 * last modified on  : 03-24-2022
 * last modified by  : Shreyashi Sarkar
**/
@isTest
public class TestDataFactory {
	// create test data for account
    public static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        return acc;
    }
    // create test data for Contract
    public static Contract createContract(String accId){
        Contract testContract = new Contract();
        testContract.AccountId = accId;
        testContract.Status = 'Draft';
        testContract.StartDate = Date.newInstance(2022, 03, 20);
        testContract.ContractTerm = 40;
        insert testContract;
        testContract.Status = 'Activated'; // to activate the Order, contractor status should be Activated
        update testContract;
        return testContract;
    }
    //create test data for Product2
    public static Product2 createProduct2(){
        Product2 testProduct =  new Product2();
        testProduct.Name = 'Test Product';
        testProduct.Description = 'This is used for test class';
        testProduct.ProductCode = 'Test1234';
        testProduct.isActive = true;
        insert testProduct;
        return testProduct;
    }
    //create standard pricebook
    public static PricebookEntry createPricebookEntry(){
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Product2 prod2 = createProduct2();
        PricebookEntry priceBook = new PricebookEntry();
        priceBook.Pricebook2Id = stdPriceBookRecId;
        priceBook.Product2Id=prod2.Id;
        priceBook.UnitPrice=2000;
        priceBook.IsActive=true;
        priceBook.UseStandardPrice = false;
        insert priceBook;
        return priceBook;
    }
    // create test data for Order
    public static Order createOrder(String accId,String conId){
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Order ord = new Order();
        ord.AccountId = accId;
        ord.ContractId = conId;
        ord.Status = 'Draft';
        ord.EffectiveDate = Date.newInstance(2022, 03, 20);
        ord.Pricebook2Id = stdPriceBookRecId;
        insert ord;
        return ord;
    }
}