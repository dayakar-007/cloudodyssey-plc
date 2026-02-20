// BUG-0002-Dayakar connect
public without sharing class Cart {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getOrgInfo(String storeName,String currentUserId)
    {
        system.debug('storeName'+storeName);
        system.debug('currentUserId'+currentUserId);
        system.debug('storeName.substring(1)'+storeName.substring(1));
        storeName = storeName.substring(1);
        WebStore store =[SELECT ID FROM WebStore where Name = :storeName LIMIT 1];
        User user = [SELECT ContactId ,AccountId  from user where Id =: currentUserId LIMIT 1];
        Map<String,String> orgInfo = new Map<String,String>();
        orgInfo.put('webstore',store.Id);
        orgInfo.put('contactId',user.ContactId);
        orgInfo.put('accountId',user.AccountId);
        return orgInfo;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getCarts() {
        List<Cart_Configuration__mdt> cart_metadata = [SELECT Label, DeveloperName FROM Cart_Configuration__mdt];
        Map <String, String> cartMap = new Map<String, String>();
        for (Cart_Configuration__mdt cartConfig : cart_metadata) {
            cartMap.put((String)cartConfig.DeveloperName, (String)cartConfig.Label);
        }
        return cartMap;
    }
    @AuraEnabled
    public static String addProductToCart(
        String productID,
    Integer quantity,
    String cartReference,
    Id webStore,
    Id userId,
    String accountId
    ) {
        System.debug('--- [addProductToCart] Method Start ---');
        System.debug('Input => productID: ' + productID);
        System.debug('Input => quantity: ' + quantity);
        System.debug('Input => cartReference: ' + cartReference);
        System.debug('Input => webStore: ' + webStore);
        System.debug('Input => userId: ' + userId);
        System.debug('Input => accountId: ' + accountId);

        // BUG-001: avoid invalid ConnectApi calls when required cart inputs are missing.
        if (String.isBlank(productID) || quantity == null || quantity <= 0 || webStore == null || userId == null || String.isBlank(accountId)) {
            System.debug('[addProductToCart] Invalid input. Skipping cart operation.');
            return 'invalid cart input';
        }
        
        Id cartId;
        List<WebCart> cart = [
        SELECT Id 
        FROM WebCart 
        WHERE Status = 'Active' 
        AND Cart_reference__c = :cartReference 
        AND WebStoreId = :webStore 
        AND OwnerId = :userId
    ];
        
        System.debug('Queried WebCart count: ' + cart.size());
        
        if (cart.size() == 0) {
            System.debug('[addProductToCart] No active cart found. Creating a new one...');
            ConnectApi.CartInput input = new ConnectApi.CartInput();
            input.currencyIsoCode = 'INR';
            input.effectiveAccountId = accountId;
            
            List<SObject> webCartList = new List<SObject>();
            WebCart webCart = new WebCart();
            webCart.Cart_reference__c = cartReference;
            input.customFields = webCartList;
            
            if (cartReference != 'Primary') {
                input.isSecondary = true;
                System.debug('[addProductToCart] Marking cart as Secondary.');
            }
            
            try {
                ConnectApi.CartSummary cartSummary = ConnectApi.CommerceCart.createCart(webStore, input);
                cartId = cartSummary.cartId;
                System.debug('[addProductToCart] Cart created successfully. CartId: ' + cartId);
                
                update new WebCart(Id = cartSummary.cartId, Cart_reference__c = cartReference);
                System.debug('[addProductToCart] WebCart record updated with Cart_reference__c = ' + cartReference);
                
                // Call itemToCart for the new cart
                itemToCart(productID, cartId, quantity, accountId, webStore);
                
                System.debug('--- [addProductToCart] Method End ---');
                return 'new cart created';
            } catch (Exception e) {
                System.debug('[addProductToCart] Exception while creating cart: ' + e.getMessage());
                System.debug('[addProductToCart] StackTrace: ' + e.getStackTraceString());
            }
        } else {
            cartId = cart[0].Id;
            System.debug('[addProductToCart] Existing cart found. CartId: ' + cartId);
            
            // Call itemToCart for the existing cart
            itemToCart(productID, cartId, quantity, accountId, webStore);
            
            System.debug('--- [addProductToCart] Method End ---');
            return 'already cart created';
        }
        
        System.debug('--- [addProductToCart] Method End with No Return ---');
        return 'cart creation failed';
    }
    
    @AuraEnabled
    public static void itemToCart(
        Id productId,
    Id webCartId,
    Integer quantity,
    Id accountId,
    Id webStoreId
    ) {
        System.debug('--- [itemToCart] Method Start ---');
        System.debug('Input => AccountId: ' + accountId);
        System.debug('Input => WebCartId: ' + webCartId);
        System.debug('Input => ProductId: ' + productId);
        System.debug('Input => WebStoreId: ' + webStoreId);
        System.debug('Input => Quantity: ' + quantity);

        if (productId == null || webCartId == null || quantity == null || quantity <= 0 || accountId == null || webStoreId == null) {
            System.debug('[itemToCart] Invalid input. Skipping addItemToCart call.');
            return;
        }
        
        ConnectApi.CartItemInput input = new ConnectApi.CartItemInput();
        input.productId = productId;
        input.quantity = String.valueOf(quantity);
        input.type = ConnectApi.CartItemType.Product;
        
        
        ConnectApi.CartItem item = ConnectApi.CommerceCart.addItemToCart(
            webStoreId,
        accountId,
        webCartId,
        input
            );
        //System.debug('[itemToCart] Product successfully added to cart. CartItemId: ' + item.id);
        System.debug('--- [itemToCart] Method End ---');
    }
    
}
}
