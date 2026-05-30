import { LightningElement,wire,track,api } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import OPP_OBJ from '@salesforce/schema/Opportunity';

export default class OpportunityTableWithSortingAndPagination extends LightningElement {
    @wire(getListUi, {objectApiName: OPP_OBJ, listViewApiName: 'AllOpportunities'})
    opportunities;

    @track sortBy = 'Name';
    @track sortDirection = 'asc';
    @track pageSize = 10;
    @track currentPage = 1;
    columns = [
        {
            label:'Name', fieldName:'Name', sortable:true
        },
        {
            label: 'Amount', fieldName:'Amount', type:'currency', sortable:true
        },
        {
            label:'Stage', fieldName:'StageName', sortable:true
        },
        {
            label: 'Close Date', fieldName:'CloseDate', type:'Date', sortable:true
        }
    ];

    get opportunityList(){
        return this.opportunities.data ? this.opportunities.data.records.records : [];
    }

    get sortedOpportunityList(){
        let sorted = [...this.opportunityList];
        sorted.sort((a,b) => {
            let aValue = a.fields[this.sortBy].value;
            let bValue = b.fields[this.sortBy].value;

            if(aValue < bValue) return this.sortDirection === 'asc' ? -1 : 1;
            if(aValue > bValue) return this.sortDirection === 'asc' ? 1 : -1;

            return 0;
        });
        return sorted;
    }

    get displayedOpportunities(){
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        console.log('>>>> '+this.sortedOpportunityList.slice(start,end));
        return this.sortedOpportunityList.slice(start,end).map( record => {
            return {
                'id': record.id,
                'Name': record.fields.Name.value,
                'Amount': record.fields.Amount.value,
                'StageName':record.fields.StageName.value,
                'CloseDate': record.fields.CloseDate.value
            };
        });
    }

    get totalPages(){
        return Math.ceil(this.sortedOpportunityList.length / this.pagesize);
    }

    get isFirstPage(){
        return this.currentPage === 1;
    }

    get isLastPage(){
        return this.currentPage === this.totalPages;
    }

    handleSort(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.currentPage = 1;
    }

    handlePrevious(){
        if(this.currentPage > 1){
            this.currentPage--;
        }
    }

    handleNext(){
        if(this.currentPage < this.totalPages){
            this.currentPage++;
        }
    }
}