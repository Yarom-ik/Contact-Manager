public with sharing class ContactsListController {
    public String sortingColumn = 'Name'; // sorted first column
	public String sortingOrder = ' ASC '; // sorted first ASC
	public String column = sortingColumn; // first column sorting
 
	public String query = 'SELECT Id, Name, Email, Contact_Level__c, AccountId, OwnerId, CreatedById, CreatedDate ' +
                      'FROM Contact ' +
                      'ORDER BY ' + sortingColumn + sortingOrder +' LIMIT 10000';
 
    //add new Contact field
    public String newFirstName {get; set;}
    public String newLastName {get; set;}
    public String newEmail {get; set;}
    public String newContactLevel {get; set;}
    public String newAccount {get; set;}
    
    //get ContactLevel listOptions
    public List<SelectOption> getContactLevel(){
        
        List<SelectOption> ContactLevel = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Contact_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
           System.debug('----> ' + f.getLabel() +' '+  f.getValue());
           ContactLevel.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        
        return ContactLevel;
    }
    
	public void sortByName() {
		sortingColumn = 'Name';
		sortingOrder();
	}
	public void sortByEmail() {
		sortingColumn = 'Email';
		sortingOrder();
	}
	public void sortByContactLevel() {
		sortingColumn = 'Contact_Level__c';
		sortingOrder();
	}
	public void sortByAccountId() {
		sortingColumn = 'AccountId';
		sortingOrder();
	}
	public void sortByOwnerId() {
		sortingColumn = 'OwnerId';
		sortingOrder();
	}
	public void sortByCreatedById() {
		sortingColumn = 'CreatedById';
		sortingOrder();
	}
	public void sortByCreatedDate() {
		sortingColumn = 'CreatedDate';
		sortingOrder();
	}
 

	public void sortingOrder() {
		if (sortingColumn == column) {
			sortingOrder = (sortingOrder == ' ASC ') ? ' DESC ' : ' ASC ';
		} else {
			sortingOrder = ' ASC ';
			column = sortingColumn;
		}
	
		query = 'SELECT Id, Name, Email, Contact_Level__c, AccountId, OwnerId, CreatedById, CreatedDate ' +
	        'FROM Contact ' +
	      	'ORDER BY ' + sortingColumn + sortingOrder + ' LIMIT 10000';	
		setList = new ApexPages.StandardSetController(Database.query(query));
        
	}
 
   // Пишем поиск Search
	public String SearchContactKeyword {get; set;}        // получаем текст который мы вводим в поле поиска
		public void search(){
			if (SearchContactKeyword !=' ') {
				String searchWorld = '\'%' + SearchContactKeyword + '%\''; // *+текст+*
				query = 'SELECT Id, Name, Email, Contact_Level__c, AccountId, OwnerId, CreatedById, CreatedDate ' +
		        	'FROM Contact ' +
		        	'WHERE FirstName like ' + searchWorld + ' OR LastName like ' + searchWorld + ' ' +      
		        	'ORDER BY ' + sortingColumn +' '+ sortingOrder;

				setList = new ApexPages.StandardSetController(Database.query(query));
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '"Search field cannot be empty !"'));
            }
		}
    
    public string SelectedContactId { get; set; }
    public void  DeleteContact(){
        if (SelectedContactId == null) { return; } // если НЕТ ссылки
	// находим ID записи учетной записи по запросу
	System.debug('---->'+ SelectedContactId);
	Contact tobeDeleted = null;
	for (Contact a : [SELECT Id FROM Contact])
		if (a.Id == SelectedContactId) {
			tobeDeleted = a;
			break;
		}
 
	if (tobeDeleted != null) { 
        Delete tobeDeleted; 
    } // если найдена запись учетной записи, удалите ее
 
		setList = new ApexPages.StandardSetController(Database.query(query));
    	getContact();
    }


	public ApexPages.StandardSetController setList {
		get {
			if (setList == null) { // проверка на наличие экземпляра контроллера
				setList = new ApexPages.StandardSetController(Database.query(query));
			}
        	Integer sizePage = 10;
		
			setList.setPageSize(sizePage); // количество записей/страница
			return setList;
		} set;
	}

	public Integer PageNumber {
		get { 
			this.PageNumber = setList.getPageNumber();
			return this.PageNumber;
		}
		set { 
			setList.setPageNumber(value); //
		}
	}
	public Integer TotalPages { 
		get {
			if (setList.getResultSize() <= 10)
				this.TotalPages = 1;
			if (Math.Mod ( setList.getResultSize(),setList.getPageSize() ) == 0)
				this.TotalPages = ( setList.getResultSize()/setList.getPageSize() );
			else this.TotalPages = ( setList.getResultSize()/setList.getPageSize() )+1;
			return totalpages;
		}
		set;
	}
    public Integer TotalRecords { // 
		get {				
			return setList.getResultSize ();
		}
		set;
		}

	
	public List<Contact> getContact() {
		return (List<Contact>) setList.getRecords();
	}
    
    //popup
	public boolean displayPopup {get;set;} 
  	public void closePopup(){
        displayPopup   = false; 
    	setList = new ApexPages.StandardSetController(Database.query(query));
    	getContact();
	} 
    public void showPopup(){ 
        displayPopup = true; 
    } 
    
    //Save new Contact
    public String save(){
        if (newAccount != null){
            try{
                Account newAcc = new Account(Name = newAccount);
                insert newAcc;
                
                Contact newCon = new Contact(FirstName = newFirstName, LastName = newLastName, Email = newEmail, 
                                             Contact_Level__c = newContactLevel, AccountId = newAcc.Id);
                insert newCon;
            }
            catch(DMLException e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new contact'));
                return null;
            }
        }else{
            try{
                Contact newCon = new Contact(FirstName = newFirstName, LastName = newLastName, Email = newEmail, 
                                             Contact_Level__c = newContactLevel);
                insert newCon;
            }
            catch(DMLException e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new contact'));
                return null;
            }
        }
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'New contact "'+newFirstName+' '+newLastName+'" successfully created'));
        setList = new ApexPages.StandardSetController(Database.query(query));
    	getContact();
        return null;
    }

 
}
