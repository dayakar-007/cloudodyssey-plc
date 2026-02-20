public without sharing class StatusBoard {
    @AuraEnabled
    public static List<Status_Board__c> getRecords() {
        return [SELECT ID,Name,Status__c FROM Status_Board__c LIMIT 20];
    }
}