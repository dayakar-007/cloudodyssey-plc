public without sharing class CategoryController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> getActiveCategories() {
        System.debug('=== [CategoryController.getActiveCategories] START ===');
        
        List<ProductCategory> categoriesList = [
            SELECT Id, Name 
            FROM ProductCategory 
            WHERE IsNavigational = :true
        ];

        System.debug('Fetched Categories Count: ' + categoriesList.size());
        System.debug('Fetched Categories: ' + categoriesList);
        
        if (categoriesList.isEmpty()) {
            return null;
        }

        System.debug('=== [CategoryController.getActiveCategories] END ===');
        return categoriesList;
    }

    @AuraEnabled(cacheable=true)
    public static Id getCategoryIdByName(String categoryName) {
        System.debug('=== [CategoryController.getCategoryIdByName] START ===');
        System.debug('Input Parameter - categoryName: ' + categoryName);
        
        List<ProductCategory> categoryRecords = [
            SELECT Id 
            FROM ProductCategory 
            WHERE Name = :categoryName
            LIMIT 1
        ];

        if (categoryRecords.isEmpty()) {
            System.debug('No category found for name: ' + categoryName);
            return null;
        }

        Id categoryId = categoryRecords[0].Id;
        System.debug('Found Category Id: ' + categoryId);

        System.debug('=== [CategoryController.getCategoryIdByName] END ===');
        return categoryId;
    }
    //connected app changes
}