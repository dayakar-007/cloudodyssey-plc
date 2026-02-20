import { LightningElement,track } from 'lwc';

export default class Cart extends LightningElement {
    @track cartMadal = false;
    handleCartClick()
    {
        console.log('Cart Clicked');
        this.cartMadal = true;
    }
}