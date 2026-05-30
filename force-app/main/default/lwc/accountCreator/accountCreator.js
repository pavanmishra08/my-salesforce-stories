import { LightningElement,api } from 'lwc';
import ACCOUNT_OBJ from '@salesforce/schema/Account';
import NAME from '@salesforce/schema/Account.Name';
import TYPE from '@salesforce/schema/Account.Type';
import INDUSTRY from '@salesforce/schema/Account.Industry';
import PHONE from '@salesforce/schema/Account.Phone';

export default class AccountCreator extends LightningElement {
    objectApiName = ACCOUNT_OBJ;
    fields = [NAME,TYPE,INDUSTRY,PHONE];
    showError;
    errorMessage;

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        if(!fields.Name){
            this.showError = true;
            this.errorMessage = 'Account Name is required';
            return;
        }
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    handleError(event){
        this.showError = true;
        this.errorMessage = event.detail.body.message;
    }

    handleSuccess(event){
        this.showSuccess = true;
        this.showError = false;
        this.template.querySelector('lightning-record-form').reset();
    }
}