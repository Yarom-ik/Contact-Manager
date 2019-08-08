public with sharing class ManageRecordsController {

    @AuraEnabled(cacheable = false)  
    public static List<Contact> getContactsList(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString, String sortingColumn, String sortingOrder) {  
      String searchKey = '%' + searchString + '%'; 

      String query = 'SELECT Id, Name, Email, Contact_Level__c, Account.Name, Owner.Name, CreatedBy.Name, CreatedDate FROM Contact ';  
      if (searchString != null && searchString != '') {  
        query += ' where FirstName like \'%' + searchString + '%\' OR LastName like \'%' + searchString + '%\' ';  
      }
      if (sortingColumn != null) {
        query += ' Order by '+ sortingColumn + sortingOrder +' ';
      } 
      query +=  ' limit ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1));
      System.System.debug('getContactsList = ');  
      return Database.query(query);  
    }     

    @AuraEnabled(cacheable = false)  
    public static Integer getContactsCount(String searchString) {  
     String query = 'select count() from Contact ';  
      if (searchString != null && searchString != '') {  
        query += ' where FirstName like \'%' + searchString + '%\' OR LastName like \'%' + searchString + '%\'';  
      } 
      System.System.debug('getContactsCount = '+ Database.countQuery(query));
      return Database.countQuery(query);
    }       

    @AuraEnabled 
    public static String deleteContact(String contactId) {  
     System.System.debug('deleteContact = '+ contactId); 
     try{
        delete [SELECT Id FROM Contact WHERE Id=:contactId];
        return 'SUCCESS';
     }
     catch(Exception ex){
        throw new AuraHandledException(ex.getMessage());
     }     
   } 

   @AuraEnabled
    public static Contact createContact(String firstName, String lastName, String email, String contactLevel, String account) {
      Contact newCon = null;
      try{
        if (account != null){
          Account newAcc = new Account(Name = account);
          insert newAcc;                
          newCon = new Contact(FirstName = firstName, LastName = lastName, Email = email, 
                              Contact_Level__c = contactLevel, AccountId = newAcc.Id);
          insert newCon;
            
        }else{         
          newCon = new Contact(FirstName = firstName, LastName = lastName, Email = email, 
                              Contact_Level__c = contactLevel);
        insert newCon;
        }
      } catch(Exception ex){
          throw new AuraHandledException(ex.getMessage());
        }
      String query = 'SELECT Id, Name, Email, Contact_Level__c, Account.Name, Owner.Name, CreatedBy.Name, CreatedDate FROM Contact WHERE Id =\'' + newCon.id + '\' limit 1';
      System.System.debug('Query' + query);
      return Database.query(query); 
    }    
}
