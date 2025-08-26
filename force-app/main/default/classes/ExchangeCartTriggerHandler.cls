public class ExchangeCartTriggerHandler {
    public static void submitCartHandler(List<Exchange_Cart__c> exchangeCarts)
    {
        List<Exchange_Cart__c> sucessExchangeCarts = new List<Exchange_Cart__c>();
        for(Exchange_Cart__c exchangeCart:exchangeCarts){
            if(exchangeCart.status__c =='Payment success')
            {
                sucessExchangeCarts.add(exchangeCart);
				CreateOrder createOrder = new CreateOrder(exchangeCart);
				createOrder.submitCartToExchangeOrder();
            }
        }
    }

}