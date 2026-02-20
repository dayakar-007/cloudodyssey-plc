import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountListPage extends NavigationMixin(LightningElement) {
    handleBackToHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'Home'
            }
        });
    }
}