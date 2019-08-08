import { LightningElement, track, api, wire } from 'lwc';
import getContactsList from '@salesforce/apex/ManageRecordsController.getContactsList';
import getContactsCount from '@salesforce/apex/ManageRecordsController.getContactsCount';
import deleteContact from '@salesforce/apex/ManageRecordsController.deleteContact';
import createContact from '@salesforce/apex/ManageRecordsController.createContact';

import Contact_Level_FIELD from '@salesforce/schema/Contact.Contact_Level__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { NavigationMixin } from 'lightning/navigation';

export default class RecordList extends NavigationMixin(LightningElement) {
  @track contacts;
  @track error;
  @api currentpage;
  @api pagesize;
  @track searchKey;
  totalpages;
  localCurrentPage = null;
  isSearchChangeExecuted = false;

  @api sortingColumn = 'Name';
  @api sortingOrder = ' ASC ';
  @api contactId = ' ';

  @track firstName;
  @track lastName;
  @track email;
  @track contactLevel = "Primary";
  @track account;

  @track bShowModal = false;

  handleChange(event) {
    if (this.sortingOrder === ' ASC ') {
      this.sortingOrder = ' DESC ';
    } else {
      this.sortingOrder = ' ASC ';
    }
    this.sortingColumn = event.target.title;

    this.isSearchChangeExecuted = false;
    this.currentpage = 1;
  }

  deleteRecord(event) {
    this.contactId = event.target.dataset.recordid;

    // eslint-disable-next-line no-alert
    if (window.confirm('Are you sure to DELETE?'))
      deleteContact({ contactId: this.contactId })
        // eslint-disable-next-line no-unused-vars
        .then((response) => {
          this.contacts = this.contacts.filter((con) => con.Id !== this.contactId);
          this.error = undefined;
          this.totalrecords--;
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Contact deleted',
              variant: 'success',
            }),
          );

        })
        .catch((error) => {
          this.error = error;
          this.contacts = undefined;
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error delete contact',
              message: error.body.message,
              variant: 'error',
            }),
          );
        });
  }

  handleKeyChange(event) {
    if (this.searchKey !== event.target.value) {
      this.isSearchChangeExecuted = false;
      this.searchKey = event.target.value;
      this.currentpage = 1;
    }
  }
  renderedCallback() {
    if (this.isSearchChangeExecuted && (this.localCurrentPage === this.currentpage)) {
      return;
    }
    this.isSearchChangeExecuted = true;
    this.localCurrentPage = this.currentpage;
    getContactsCount({ searchString: this.searchKey })
      .then(recordsCount => {
        this.totalrecords = recordsCount;
        if (recordsCount !== 0 && !isNaN(recordsCount)) {
          this.totalpages = Math.ceil(recordsCount / this.pagesize);
          getContactsList({ pagenumber: this.currentpage, numberOfRecords: recordsCount, pageSize: this.pagesize, searchString: this.searchKey, sortingColumn: this.sortingColumn, sortingOrder: this.sortingOrder })
            .then(contactList => {
              this.contacts = contactList;
              this.error = undefined;
            })
            .catch(error => {
              this.error = error;
              this.contacts = undefined;
            });
        } else {
          this.contacts = [];
          this.totalpages = 1;
          this.totalrecords = 0;
        }
        const event = new CustomEvent('recordsload', {
          detail: recordsCount
        });
        this.dispatchEvent(event);
      })
      .catch(error => {
        this.error = error;
        this.totalrecords = undefined;
      });
  }

  handleRowAction() {
    this.bShowModal = true; // display modal window
  }

  // to close modal window set 'bShowModal' tarck value as false
  closeModal() {
    this.bShowModal = false;
  }

  handleInputChange(event) {
    // eslint-disable-next-line no-console
    console.log('label values --->>' + event.target.label);
    if (event.target.label === 'FirstName') {
      this.firstName = event.target.value;
    }
    if (event.target.label === 'LastName') {
      this.lastName = event.target.value;
    }
    if (event.target.label === 'Email') {
      this.email = event.target.value;
    }
    if (event.target.label === 'Contact Level') {
      this.contactLevel = event.detail.value;
    }
    if (event.target.label === 'Account') {
      this.account = event.target.value;
    }
  }

  saveModal() { 
    const allValid = [...this.template.querySelectorAll('lightning-input')]
      .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
    if (!allValid) {
      // eslint-disable-next-line no-alert
      alert('Please update the invalid form entries and try again.');
      return;
    }

    if (this.lastName == null || this.email == null) {
      return;
    }
    createContact({ firstName: this.firstName, lastName: this.lastName, email: this.email, contactLevel: this.contactLevel, account: this.account })
      .then(result => {
        this.contacts.push(result);
        this.totalrecords++;
        //this.message = result;
        this.error = undefined;
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.account = '';
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Contact created',
            variant: 'success',
          }),
        );
        // eslint-disable-next-line no-console
        console.log(JSON.stringify(result));
        // eslint-disable-next-line no-console
        console.log("result", this.message);
      })
      .catch(error => {
        this.message = undefined;
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error creating record',
            message: error.body.message,
            variant: 'error',
          }),
        );
        // eslint-disable-next-line no-console
        console.log("error", JSON.stringify('oshibka ' + this.error));
      });
  }

  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  objectInfo;

  @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Contact_Level_FIELD })
  ContactLevelPicklistValues;

  navigateToContactView(event) {
    this.contactId = event.target.dataset.recordid;
    // eslint-disable-next-line no-console
    console.log('ID= ' + this.contactId);

    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.contactId,
        objectApiName: 'Contact', // objectApiName is optional
        actionName: 'view'
      }
    });
  }

}