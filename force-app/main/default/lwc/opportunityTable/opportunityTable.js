import { LightningElement,wire,track } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import OPPORTUNITY_OBJ from '@salesforce/schema/Opportunity';

export default class OpportunityTable extends LightningElement {
    @wire(getListUi,({objectApiName: OPPORTUNITY_OBJ, listViewApiName: 'AllOpportunities'}))
    opportunities;

    columns = [
        {label: 'Name', fieldName: 'Name'},
        {label: 'Amount', fieldName: 'Amount', type: 'currency'},
        {label: 'Stage', fieldName: 'StageName'},
        {label: 'Close Date', fieldName: 'CloseDate', type: 'date'}
    ];

    get opportunityList(){
        if(this.opportunities.data) {
            return this.opportunities.data.records.records.map( record => {
                return {
                    Id: record.id,
                    Name: record.fields.Name.value,
                    Amount: record.fields.Amount.value,
                    StageName: record.fields.StageName.value,
                    CloseDate: record.fields.CloseDate.value
                }
            });
        }
    }
}