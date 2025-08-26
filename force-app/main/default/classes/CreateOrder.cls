public class CreateOrder {
    Exchange_Cart__c exchangeCart;
	public CreateOrder(Exchange_Cart__c exchangeCart)
    {
        this.exchangeCart = exchangeCart;
    }
    public void submitCartToExchangeOrder()
    {
		ConnectApi.PaymentInfoInputRepresentation paymentInfoInputRepresentation = new ConnectApi.PaymentInfoInputRepresentation();
		paymentInfoInputRepresentation.lastPaymentGatewayLogId = exchangeCart.lastPayment_Gateway_Log_Id__c;
		paymentInfoInputRepresentation.paymentAuthorizationId = exchangeCart.Payment_Authorization__c;
		paymentInfoInputRepresentation.paymentMethodId = exchangeCart.Payment_Method_Id__c;
        List<ConnectApi.PaymentInfoInputRepresentation> listPaymentInfoInputRepresentation = new List<ConnectApi.PaymentInfoInputRepresentation>();
		listPaymentInfoInputRepresentation.add(paymentInfoInputRepresentation);
        ConnectApi.SubmitCartToExchangeOrderInputRepresentation submitCartToExchangeOrderInputRepresentation = new ConnectApi.SubmitCartToExchangeOrderInputRepresentation();
		submitCartToExchangeOrderInputRepresentation.exchangeCartId = exchangeCart.Exchange_Cart_Id__c;
		submitCartToExchangeOrderInputRepresentation.orderSummaryId = exchangeCart.Order_Summary_ID__c;
		submitCartToExchangeOrderInputRepresentation.referenceId = exchangeCart.Return_Order_ID__c;
		submitCartToExchangeOrderInputRepresentation.reservationType = exchangeCart.reservationType__c;
		submitCartToExchangeOrderInputRepresentation.paymentInfoList  = listPaymentInfoInputRepresentation;
		System.debug('SubmitCartToExchangeOrderOutputRepresentation: ' +submitCartToExchangeOrderInputRepresentation );
		try {
    		ConnectApi.SubmitCartToExchangeOrderOutputRepresentation output =
        	ConnectApi.Exchanges.submitCartToExchangeOrder(submitCartToExchangeOrderInputRepresentation);
    		System.debug('SubmitCartToExchangeOrderOutputRepresentation: ' + output);
		} catch (ConnectApi.ConnectApiException ex) {
    		System.debug('ConnectApiException: ' + ex.getMessage());
   		}
    }
}