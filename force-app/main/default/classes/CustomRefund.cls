public without sharing class CustomRefund {
    
    @AuraEnabled(cacheable=true)
    public static Decimal availableToRefundAmount(Id returnOrderId) {        
        ReturnOrder returnOrder = [SELECT Id, Change_Order__c FROM ReturnOrder WHERE Id = :returnOrderId];
        List<Refund> returnOrderRefundRecords = [SELECT Id, Amount, Return_Order__c FROM Refund WHERE Return_Order__c = :returnOrderId];
        Order changeOrder = [SELECT Id, TotalAmount FROM Order WHERE Id = :returnOrder.Change_Order__c LIMIT 1];
        Decimal amountOnChangeOrder = -changeOrder.TotalAmount;
        Decimal amountRefundded = 0.0;
        if (!returnOrderRefundRecords.isEmpty()) {
            for (Refund refund : returnOrderRefundRecords) {
                amountRefundded += refund.Amount;
            }
        }
        Decimal result = amountOnChangeOrder - amountRefundded;
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> amountHandler(Decimal amount, Id returnOrderId) {
        ReturnOrder returnOrderRecord = [SELECT ID,OrderSummaryId FROM ReturnOrder WHERE Id = :returnOrderId LIMIT 1];
        Payment payment = [SELECT Id, AccountId,OrderPaymentSummaryId FROM Payment WHERE OrderPaymentSummaryId IN 
                          (SELECT Id FROM OrderPaymentSummary WHERE OrderSummaryId = :returnOrderRecord.OrderSummaryId) LIMIT 1];
        ConnectApi.ReferencedRefundResponse response = refundAmount(returnOrderId, amount, payment.Id, payment.AccountId);
        Map<String, Object> responcejson = new Map<String, Object>();
        if (response.error == null) {
            ConnectApi.RefundResponse refundResponse = response.refund;
            System.debug('==> Refund Number: ' + refundResponse.refundNumber);

            responcejson.put('refund', refundResponse);
            responcejson.put('refundResponce', refundResponse.refundNumber);

            Refund refundRecord = [SELECT Id, Return_Order__c FROM Refund WHERE RefundNumber = :refundResponse.refundNumber LIMIT 1];
            System.debug('==> Retrieved Refund record to update Return_Order__c: ' + refundRecord);

            refundRecord.Return_Order__c = returnOrderId;
            refundRecord.OrderPaymentSummaryId  = payment.OrderPaymentSummaryId;
            update refundRecord;
            ReturnOrder returnOrder = new ReturnOrder();
            returnOrder.Id = returnOrderId;
            //returnOrder.isAmountRefunded__c = true;
            update returnOrder;

            System.debug('==> Updated Refund with Return_Order__c: ' + returnOrderId);
        } else {
            System.debug('==> Refund failed with error: ' + response.error);
            responcejson.put('paymentStatus', false);
        }

        System.debug('==> Final response JSON: ' + responcejson);
        return responcejson;
    }

    public static ConnectApi.ReferencedRefundResponse refundAmount(Id returnOrderId, Decimal amount, String paymentID, String accountId) {
        System.debug('==> refundAmount called with returnOrderId: ' + returnOrderId + ', amount: ' + amount + ', paymentID: ' + paymentID + ', accountId: ' + accountId);

        ConnectApi.ReferencedRefundRequest refundRequest = new ConnectApi.ReferencedRefundRequest();
        refundRequest.amount = amount;
        refundRequest.accountId = accountId;
        refundRequest.effectiveDate = Datetime.now();
        refundRequest.comments = 'Payment Refund Initiated';
        System.debug('==> Created refundRequest: ' + refundRequest);
        System.debug('DML Statements used: ' + Limits.getDmlStatements() + ' / ' + Limits.getLimitDmlStatements());
        ConnectApi.ReferencedRefundResponse response = ConnectApi.Payments.refund(refundRequest, paymentID);
        System.debug('==> Received response from Payments.refund(): ' + response);

        return response;
    }
}