import { LightningElement,wire,track } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import CONTACT_OBJ from '@salesforce/schema/Contact';

export default class ListOfContactsWithSearch extends LightningElement {
    @wire( getListUi,{ objectApiName : CONTACT_OBJ,listViewApiName:'AllContacts' })
    contacts;

    @track
    searchTerm;

    get contactList(){
        if(!this.contacts.data) return [];
        let records = this.contacts.data.records.records;
        if(this.searchTerm){
            records = records.filter( contact => contact.fields.Name.value.toLowerCase().includes(this.searchTerm));
        }
        return records;
    }

    handleOnChange(event){
        this.searchTerm = event.target.value;
    }
}