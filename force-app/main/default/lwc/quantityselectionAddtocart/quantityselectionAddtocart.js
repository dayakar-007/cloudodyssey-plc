import { LightningElement,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import getCarts from '@salesforce/apex/Cart.getCarts';
import getOrgInfo from '@salesforce/apex/Cart.getOrgInfo';
import path from '@salesforce/community/basePath';
import addProductToCart from '@salesforce/apex/Cart.addProductToCart';
export default class QuantityselectionAddtocart extends LightningElement {
    @track isLoading = false;
    @track addCart = false;
    userId = Id;
    @track quantity =1;
    contactID = '';
    accountID = '';
    webstoreId = '';
    productId = '';
    @track carts=[];
    @wire(getCarts)
    wiredCart({data,error})
    {
        if(data){
            console.log(data);
            this.carts = Object.keys(data).map(key => {
                return { key: key, value: data[key] };
            });
            console.log(this.carts[0].key);
        }
        if(error){
            console.log(error);
        }
    }
    connectedCallback(){
        this.fecthProductId();
        getOrgInfo({ storeName: path, currentUserId: this.userId })
    .then(result => {
        this.webstoreId = result.webstore;
        this.contactID = result.contactId;
        this.accountID = result.accountId;
        console.log(this.webstoreId);
        console.log(this.contactID);
    })
    .catch(error => {
        console.error('Error in getOrgInfo:', error);
        // optional: show toast to user
    });
    
        
    }
    fecthProductId(){
        const url = window.location.href;
        this.productId = url.substring(url.lastIndexOf('/') + 1);
        console.log(this.productId);
    }
    handleIncrement(){
        this.quantity++;
    }
    handleDecrement(){
        this.quantity--;
    }
    get isDecrementDisabled(){
        return this.quantity === 1;
    }
    get isIncrementDisabled(){
        return this.quantity === 10;
    }
    get CartSelectionstatus(){
        return this.addCart;
    }
    handleAddToCart(){
        this.addCart = true;
    }
    closeCartSelection(){
        this.addCart = false;
    }
    addProductsToCart(event){
        this.isLoading = true;
        const cartReference = event.detail;
        console.log('addProductsToCart');
        console.log(cartReference);
        addProductToCart({
    productID: this.productId,
    quantity: this.quantity,
    cartReference: cartReference,
    webStore: this.webstoreId,
    userId: this.userId,
    accountId: this.accountID
})
.then(result => {
    console.log('>>> Apex addProductToCart executed successfully:', result);
    this.addCart = false;
    this.isLoading = false;
    this.dispatchEvent(
            new ShowToastEvent({
                title: 'Product Added to Cart',
                message: `SKU: ${this.productId}, Quantity: ${this.quantity}, Added to Cart: ${cartReference}`,
                variant: 'success',
                mode: 'dismissable'
            })
        );
})
.catch(error => {
    console.error('>>> Error calling addProductToCart:', error);
    this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error Adding Product',
                message: error.body ? error.body.message : 'Unknown error occurred',
                variant: 'error',
                mode: 'sticky'
            })
        );
});

    }

}