import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getReturnOrderLineItems from '@salesforce/apex/CustomRefund.getReturnOrderLineItems';
import handleRefundSubmit from '@salesforce/apex/CustomRefund.handleRefundSubmit';
import { refreshApex } from '@salesforce/apex';


export default class RefundAmountSelection extends NavigationMixin(LightningElement) {
    @track discounts = [];
    @track totalAmount = 0;
    @track isButtonDisabled = true;
    @track refundSuccess = false;
    @track refundRecordId;
    @track refundNumber;
    @track isLoading = false;
     recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId || currentPageReference.state.c__recordId;
            console.log('Record Id:', this.recordId);
        }
    }

    connectedCallback() {
        console.log('  callback recordId:', this.recordId);
        if (this.recordId) {
             refreshApex(this.loadReturnOrderLineItems());
        }
    }

    async loadReturnOrderLineItems() {
        try {
            console.log('⚡ Fetching data for recordId:', this.recordId);
            const data = await getReturnOrderLineItems({ returnOrderId: this.recordId });
            console.log('✅ Data received:', JSON.stringify(data));

            this.discounts = data.map((item, index) => {
                const availableToRefund = item.totalwithtax - item.refundedAmount;
                return {
                    ...item,
                    availableToRefund,
                    maxRefund: availableToRefund,
                    rangeOverflowMessage: `Maximum amount allowed is ₹${availableToRefund}`,
                    discountValue: null,
                    returnOrder: this.recordId
                };
            });

            console.log('🎯 Final discounts array:', JSON.stringify(this.discounts));
        } catch (error) {
            console.error('❌ Error fetching line items:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    handleValueChange(event) {
        const recordId = event.target.dataset.id;
        let enteredValue = event.target.value;

        this.discounts = this.discounts.map(item => {
            if (item.id === recordId) {
                const availableToRefund = item.totalwithtax - item.refundedAmount;
                return {
                    ...item,
                    discountValue: enteredValue,
                    availableToRefund,
                    maxRefund: availableToRefund,
                    rangeOverflowMessage: `Maximum amount allowed is ₹${availableToRefund}`,
                    returnOrder: this.recordId
                };
            }
            return item;
        });

        this.calculateTotal();
        this.validateInputs();
    }

   calculateTotal() {
    this.totalAmount = this.discounts.reduce((sum, item) => {
        const val = Number(item.discountValue);
        if (!isNaN(val)) {
            return sum + val;
        }
        return sum;
    }, 0);

    console.log('💰 Total Entered Refund:', this.totalAmount);
}

validateInputs() {
    let allRowsValid = true;
    let hasAtLeastOneValue = false;

    for (let item of this.discounts) {
        const value = item.discountValue;
        console.log('refund value',value);
        // Case 1: Empty value (invalid)
        if (value === null || value === undefined || value === '') {
            allRowsValid = false;
            continue;
        }

        const num = Number(value);

        // Case 2: Not a number, or out of range (invalid)
        if (isNaN(num) || num < 0 || num > item.maxRefund) {
            allRowsValid = false;
        } else {
            hasAtLeastOneValue = true;
        }
    }

    // Button disabled if any invalid OR any empty field exists
    this.isButtonDisabled = !(allRowsValid && hasAtLeastOneValue) || this.totalAmount == 0;
}





    handleSubmit() {
        this.isLoading = true;
            console.log('Submitting refund with discounts:');
        handleRefundSubmit({ refundList: this.discounts })
            .then(result => {
                this.refundSuccess = true;
                if(result.status === 'success'){
                    this.showToast('Success', result, 'success');
                    this.refundRecordId = result.Refund_ID;
                    this.refundNumber = result.Refund_Number;
                    this.isLoading = false;
                }
                else{
                    this.isLoading = false;
                    this.showToast('Error', result, 'error');
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body.message, 'error');
            });
        
    }
    disconnectedCallback() {
        console.log('Disconnected callback called');
         refreshApex(this.loadReturnOrderLineItems());
        console.log('Apex refresh called in disconnectedCallback');
    
    }
    handleNavigateToRefund() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.refundRecordId,
                objectApiName: 'Refund', // update with your object API name
                actionName: 'view'
            }
        });
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    
}