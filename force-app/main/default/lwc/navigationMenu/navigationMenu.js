import { LightningElement ,wire,api,track} from 'lwc';
import getCategoryIdByName from '@salesforce/apex/CategoryController.getCategoryIdByName';
import getActiveCategories from '@salesforce/apex/CategoryController.getActiveCategories';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NavigationMenu extends NavigationMixin(LightningElement) {
        categoryList=[];
     @wire(getActiveCategories)
     wiredCategories({data,error})
     {
        if(data)
        {
            console.log(data);
            this.categoryList = data;
            console.log('categoryies',data);
        }
     }
    handleCategoryClick=(event)=>
    {
        event.preventDefault();
        console.log(event);
        const categoryName = event.currentTarget.dataset.name;
        getCategoryIdByName({categoryName}).
            then((categoryId)=>{
                if (!categoryId) {
                    this.showError(`Category not found: ${categoryName}`);
                    return;
                }
                const url = `/category/${categoryName}/${categoryId}`;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: { url }
                });

            })
        console.log(categoryName);
    }
}