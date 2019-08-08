@isTest
public with sharing class TestContactsListController {
   
     @testSetup
    static void initializeController(){
        ContactsListController contactListController = new ContactsListController();
        contactListController.newFirstName = 'newFirstName';
        List<Contact> contactList = new List<Contact>();
        for (integer i = 0; i <= 20 ; i++){
            contactList.add(new Contact(FirstName = 'FirstNameTest ', 
                                        LastName = 'LastNameTest ' + i));                            
        }    	
        insert contactList;
    }
    
    @isTest static void getContactTest(){
        ContactsListController contactListController = new ContactsListController();
        List<Contact> contacts = new List<Contact>();
        Test.startTest();
        contacts = contactListController.getContact();
        Test.stopTest();
        System.assertNotEquals(null, contacts.size());
    }
    
    @isTest static void getContactLevelTest(){
        ContactsListController contactListController = new ContactsListController();
        List<SelectOption> contactLevelOld = new List<SelectOption>();
        List<SelectOption> contactLevel = new List<SelectOption>();
    	contactLevel.add(new SelectOption('Primary', 'Primary'));
        contactLevel.add(new SelectOption('Secondary', 'Secondary'));
        contactLevel.add(new SelectOption('Tertiary', 'Tertiary'));
        Test.startTest();
        contactLevelOld = contactListController.getContactLevel();
        Test.stopTest();
        System.assertEquals(contactLevel, contactLevelOld);
    }
    
    @isTest static void totalPagesTest(){
        ContactsListController contactListController = new ContactsListController();
        Test.startTest();
        //Integer totalPages = contactListController.TotalPages();
        Test.stopTest();
        //System.debug('total page = ' + totalPages);
    }
}
