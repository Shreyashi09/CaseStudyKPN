import { LightningElement, api, track} from 'lwc';

const recordsPerPage = [5,10,25,50,100];
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden'; //visibility keeps the component space, but display:none doesn't
export default class PaginationCustom extends LightningElement {
    @api showPagination; //Show/hide pagination; valid values are true/false
    @api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array 
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumber; //Page number
    @track controlPagination = showIt;
    @track controlPrevious = hideIt; //Controls the visibility of Previous page button
    @track controlNext = showIt; //Controls the visibility of Next page button
    recordsToDisplay = []; //Records to be displayed on the page

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        if(this.pageSizeOptions && this.pageSizeOptions.length > 0) 
            this.pageSize = this.pageSizeOptions[0];
        else{
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
        this.controlPagination = this.showPagination === false ? hideIt : showIt;
        this.setRecordsToDisplay();
    }

    handleRecordsPerPage(event){
        this.pageSize = event.target.value;
        this.setRecordsToDisplay();
    }
    handlePageNumberChange(event){
        if(event.keyCode === 13){
            this.pageNumber = event.target.value;
            this.setRecordsToDisplay();
        }
    }
    previousPage(){
        this.pageNumber = this.pageNumber-1;
        this.setRecordsToDisplay();
    }
    nextPage(){
        this.pageNumber = this.pageNumber+1;
        this.setRecordsToDisplay();
    }
    setRecordsToDisplay(){
        this.recordsToDisplay = [];
        if(!this.pageSize)
            this.pageSize = this.totalRecords;

        this.totalPages = Math.ceil(this.totalRecords/this.pageSize);

        this.setPaginationControls();

        for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
            if(i === this.totalRecords) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
    }
    setPaginationControls(){
        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPages === 1){
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }else if(this.totalPages > 1){
           this.controlPrevious = showIt;
           this.controlNext = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumber <= 1){
            this.pageNumber = 1;
            this.controlPrevious = hideIt;
        }else if(this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
            this.controlNext = hideIt;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if(this.controlPagination === hideIt){
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }
    }
}