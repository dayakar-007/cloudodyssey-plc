trigger ExchangeCartTrigger on Exchange_Cart__c (after update) {
	if(Trigger.isAfter && Trigger.isUpdate)
    {
        ExchangeCartTriggerHandler.submitCartHandler(Trigger.new);
    }
}