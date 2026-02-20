import { LightningElement,api } from 'lwc';
export default class StatusTracker extends LightningElement {       
    
    @api currentStage = 3; 
    steps = [1, 2, 3, 4, 5];


}