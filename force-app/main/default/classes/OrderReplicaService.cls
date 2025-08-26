public class OrderReplicaService {
    public static void createReplicaOrder(String orderNumber) {
        Order originalOrder = findOrderRecord(orderNumber);
		Id replicaOrderId = createReplicaOrder(originalOrder);
		//Id paymentGroupId = createPaymentGroup(replicaOrderId);
    }

    public static Order findOrderRecord(String orderNumber) {
        Order originalOrder = [
            SELECT Id, OrderNumber
            FROM Order
            WHERE Id = :orderNumber OR OrderNumber = :orderNumber
            LIMIT 1
        ];

        if (originalOrder == null) {
            originalOrder = [
                SELECT Id, OrderNumber, OrderReferenceNumber
                FROM Order
                WHERE Id IN (
                    SELECT OriginalOrderId
                    FROM OrderSummary
                    WHERE Id = :orderNumber OR OrderNumber = :orderNumber
                )
                LIMIT 1
            ];
        }
        return originalOrder;
    }
	public static Id createReplicaOrder(Order originalOrder)
    {
        Order replicaOrder = new Order();
		replicaOrder.AccountId = originalOrder.AccountId;
		replicaOrder.Pricebook2Id = originalOrder.Pricebook2Id;
        //replicaOrder.BillingAddress = originalOrder.BillingAddress;
        replicaOrder.BillingCity = originalOrder.BillingCity;
        replicaOrder.BillingCountry = originalOrder.BillingCountry;
        replicaOrder.BillingCountryCode = originalOrder.BillingCountryCode;
		replicaOrder.BillingEmailAddress = originalOrder.BillingEmailAddress;
		replicaOrder.BillingGeocodeAccuracy = originalOrder.BillingGeocodeAccuracy;
		replicaOrder.BillingLatitude = originalOrder.BillingLatitude;
		replicaOrder.BillingLongitude = originalOrder.BillingLongitude;
        replicaOrder.BillingState = originalOrder.BillingState;
        replicaOrder.BillingStateCode = originalOrder.BillingStateCode;
		replicaOrder.BillingPhoneNumber = originalOrder.BillingPhoneNumber;
        replicaOrder.BillingPostalCode = originalOrder.BillingPostalCode;
		replicaOrder.BillingStreet = originalOrder.BillingStreet;
        replicaOrder.BillToContactId = originalOrder.BillToContactId;
		replicaOrder.ContractId = originalOrder.ContractId;
		replicaOrder.CurrencyIsoCode  = originalOrder.CurrencyIsoCode;
		replicaOrder.Description = originalOrder.Description;
		replicaOrder.Name = originalOrder.Name;
        replicaOrder.OrderReferenceNumber = originalOrder.OrderReferenceNumber;
		replicaOrder.ShippingCity = originalOrder.ShippingCity;
        replicaorder.ShippingCountry = originalOrder.ShippingCountry;
		replicaorder.ShippingCountryCode = originalOrder.ShippingCountryCode;
		replicaorder.ShippingGeocodeAccuracy = originalOrder.ShippingGeocodeAccuracy;
		replicaorder.ShippingLatitude = originalOrder.ShippingLatitude;
		replicaorder.ShippingLongitude = originalOrder.ShippingLongitude;
		replicaorder.ShippingPostalCode = originalOrder.ShippingPostalCode;
		replicaorder.ShippingState = originalOrder.ShippingState;
		replicaorder.ShippingStateCode = originalOrder.ShippingStateCode;
		replicaorder.ShippingStreet = originalOrder.ShippingStreet;
		replicaorder.Status = 'Draft';
        Insert replicaOrder;
        return replicaOrder.Id;
    }
	public static Id createPaymentGroup(ID replicaOrderId)
    {
        PaymentGroup paymentGroup = new PaymentGroup();
		paymentGroup.SourceObjectId = replicaOrderId;
        insert paymentGroup;
        return paymentGroup.Id;
    }
	public static Id createPaymenthod(Id accountID,Id orderSummaryID)
    {
        OrderPaymentSummary  paymentSummary = [SELECT Id,PaymentMethod.AccountId FROM OrderPaymentSummary WHERE OrderSummaryId =: orderSummaryID][0];
		CardPaymentMethod cardPaymentMethod = new CardPaymentMethod();
		cardPaymentMethod.AccountId = paymentSummary.PaymentMethod.AccountId;
		cardPaymentMethod.PaymentGatewayId = '';
        return '';
    }
}