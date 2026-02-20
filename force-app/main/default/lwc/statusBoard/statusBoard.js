import { LightningElement ,track,api} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import statusBoard from '@salesforce/apex/StatusBoard.getRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class StatusBoard extends LightningElement {
    @api isLoading = false;
     @track columns = [
        { key: 'Draft', status: 'Draft', label: 'Draft', items: [] },
        { key: 'Create', status: 'Created', label: 'Create', items: [] },
        { key: 'Succeeded', status: 'Succeeded', label: 'Succeeded', items: [] },
        { key: 'Failed', status: 'Failed', label: 'Failed', items: [] }
    ];
    connectedCallback(){
        this.fetchstatusBoardRecords();
        console.log('columns in connectedCallback==');
    }
    fetchstatusBoardRecords(){
        statusBoard()
            .then(result=>{
                this.columns[0].items = result.filter(record=>record.Status__c === 'Draft');
                this.columns[1].items = result.filter(record=>record.Status__c === 'Created');
                this.columns[2].items = result.filter(record=>record.Status__c === 'Succeeded');
                this.columns[3].items = result.filter(record=>record.Status__c === 'Failed');
                console.log('columns==='+JSON.stringify(this.columns));
                console.log('result==='+JSON.stringify(result));
            })
            .catch(
                error=>{
                    console.error('error==='+JSON.stringify(error));
                }
            );
    }
    handleDragStart(event){
        const dragRecordId = event.target.dataset.id;
        const status = event.target.dataset.status;
        console.log('Drag Start Record Id=='+dragRecordId);
        console.log('Drag Start Status=='+status);
        event.dataTransfer.setData('text/plain', JSON.stringify({ dragRecordId, status }));
    }
    handleDragOver(event){
        event.preventDefault();
        console.log('Drag Over Event');
    }
    async handleDrop(event){
        this.isLoading = true;
        event.preventDefault();
        const targetStatus = event.currentTarget.dataset.status;
        if (!targetStatus) 
        {
            this.isLoading = false;
            return;
        }
        console.log('Drop Target Status=='+targetStatus);
        const data = event.dataTransfer.getData('text/plain');
        console.log('Dropped Data=='+data);
        if (!data){
            this.isLoading = false;
            return;
        }
        let payload;
        try { payload = JSON.parse(data); } catch(e){ return; }
        const recordId = payload.dragRecordId;
        const fromStatus = payload.status;
        if (fromStatus === targetStatus) 
        {
            this.isLoading = false;
            return;
        }
        console.log('handleDrop Record Id=='+recordId);
        try{
            console.log('Updating record status...');
            await this.updateRecordStatus(recordId, targetStatus);
            //this.showToast('Success', `Record updated to ${targetStatus}`, 'success');
            console.log('Record status updated successfully.');
            this.fetchstatusBoardRecords();
            this.isLoading = false;
            this.showToast('Success', `Record updated to ${targetStatus}`, 'success');
        }
        catch(error){
            console.error('Error updating record status=='+JSON.stringify(error));
        }
    }
    updateRecordStatus(recordId, newStatus) {
        // use lightning/uiRecordApi updateRecord
        const fields = {
            Id: recordId,
            Status__c: newStatus
        };
        const recordInput = { fields };
        return updateRecord(recordInput);
    }
    showToast(title, message, variant='info') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}