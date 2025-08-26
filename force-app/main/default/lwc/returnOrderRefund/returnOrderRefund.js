import { LightningElement, track, api } from 'lwc';
import availableToRefundAmount from '@salesforce/apex/CustomRefund.availableToRefundAmount';
import amountHandler from '@salesforce/apex/CustomRefund.amountHandler';
export default class ReturnOrderRefund extends LightningElement {
    @track selectedRefund = '';
    @track avaliableToRefund = 0.0;
    @track isLoading = false;
    @track showSuccess = false;
    @track amountSelected = 0.0;
    @track showAmountEntered = false;
    @api recordId;

    refundOptions = [
        { label: 'Normal Refund', value: 'normal' },
        { label: 'Custom Refund', value: 'custom' }
    ];

    connectedCallback() {
        console.log('connectedCallback - recordId:', this.recordId);
        availableToRefundAmount({ returnOrderId: this.recordId })
            .then(result => {
                console.log('Available Refund Amount:', result);
                this.avaliableToRefund = result;
            })
            .catch(error => {
                console.error('Error fetching refund amount:', error);
            });
    }

    handleRefundChange(event) {
        this.selectedRefund = event.detail.value;
        this.showAmountEntered = this.selectedRefund ==='custom';
        if(this.showAmountEntered==='custom')
        {
            this.amountSelected = 0.0;
        }
        console.log('Selected Amount',this.amountSelected);
        
        console.log('showAmountEntered:', this.showAmountEntered);    
        console.log('Selected Refund Policy:', this.selectedRefund);
    }
    handleAmountChange(event) {
        const value = parseFloat(event.target.value);
    
        if (value > this.avaliableToRefund) {
            this.amountSelected = this.avaliableToRefund;
        }else {
            this.amountSelected = value;
        }

    // Optionally update the input value to reflect correction
        event.target.value = this.amountSelected;

        console.log('Validated Amount Selected:', this.amountSelected);
    }
    handleClick() {
        console.log('Selected Refund:', this.selectedRefund);
        this.isLoading = true;
        this.showSuccess = false;
        const totalRefundableAmount  = this.selectedRefund === 'custom' ? this.amountSelected : this.avaliableToRefund;
        amountHandler({ amount: totalRefundableAmount, returnOrderId: this.recordId})
        .then((result)=>{
            console.log('Result:', result);
            this.isLoading = false;
            this.showSuccess = true;
        }).catch((error)=>{
            console.log('Error:', error);
            this.isLoading = false;
            this.showSuccess = true;
        });
    }
    get isValidAmount() {
        return !(this.avaliableToRefund !==0.0 && this.amountSelected <= this.avaliableToRefund);
    }

}