import { LightningElement, api } from 'lwc';

export default class PaginatorBottom extends LightningElement {
  // Api considered as a reactive public property.  
  @api totalrecords;
  @api currentpage;
  @api pagesize;
  // Following are the private properties to a class.  
  lastpage = false;
  firstpage = false;
  // getter  
  get showFirstButton() {
    if (this.currentpage === 1) {
      return true;
    }
    return false;
  }
  // getter  
  get showLastButton() {
    if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage) {
      return true;
    }
    return false;
  }
  //Fire events based on the button actions  
  handlePrevious() {
    this.dispatchEvent(new CustomEvent('previous'));
  }
  handleNext() {
    this.dispatchEvent(new CustomEvent('next'));
  }
  handleFirst() {
    this.dispatchEvent(new CustomEvent('first'));
  }
  handleLast() {
    this.dispatchEvent(new CustomEvent('last'));
  }
}