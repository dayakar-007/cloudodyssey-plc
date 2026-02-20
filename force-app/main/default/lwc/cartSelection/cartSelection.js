import { LightningElement ,api} from 'lwc';

export default class CartSelection extends LightningElement {
    @api cartreference = '';
    @api cartname = '';
    handleCartClick(){
        
        const cartSelected = new CustomEvent('cartselected',{
            detail:this.cartreference
        });
        this.dispatchEvent(cartSelected);
        
    }

}