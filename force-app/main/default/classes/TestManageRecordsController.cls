@isTest
public with sharing class TestManageRecordsController {

    //public TestManageRecordsController() {
    //}

    @testSetup
    static void initializeController(){
        List<Contact> contactList = new List<Contact>();
        for (integer i = 0; i <= 20 ; i++){
            contactList.add(new Contact(FirstName = 'FirstNameTest '+ i, 
                                        LastName = 'LastNameTest ' + i));                            
        }    	
        insert contactList;        

    }

    @isTest static void getContactsCountTest(){
        Integer countContact = 0 ;
        Test.startTest();
        countContact = ManageRecordsController.getContactsCount('');
        Test.stopTest();
        System.assertNotEquals(0, countContact);
    }

    @isTest static void getContactsSeachKeyCountTest(){
        Integer countContact = 0 ;
        Test.startTest();
        countContact = ManageRecordsController.getContactsCount('FirstNameTest 20');
        Test.stopTest();
        System.assertEquals(1, countContact);
    }

    @isTest static void deleteContactTest(){
        Contact newCon = new Contact(FirstName = 'FirstNameTest ', 
                                LastName = 'LastNameTest ');
        insert newCon;
        Test.startTest();
        String result = ManageRecordsController.deleteContact(newCon.Id);
        Test.stopTest();
        System.assertEquals('SUCCESS', result);
    }

    @isTest static void getContactsListTest(){
        Test.startTest();
        List<Contact> resultContacts = ManageRecordsController.getContactsList(1,1,1, 'FirstNameTest', 'Name' , ' ASC ');
        Test.stopTest();
        System.assertEquals(1, resultContacts.size());
    }

    @isTest static void createContactTest(){
        Account newAcc = new Account(Name = 'AccountTest');
        insert newAcc;
        Contact newCon = new Contact(FirstName = 'FirstNameTest', 
                                LastName = 'LastNameTest',
                                Email = 'email@tut.com',
                                Contact_Level__c = 'Primary',
                                AccountId = newAcc.Id);
        
        Test.startTest();
        Contact returnContact = ManageRecordsController.createContact('FirstNameTest','LastNameTest',
                                                            'email@tut.com', 'Primary','AccountTest' );
        Test.stopTest();
        System.assertEquals(newCon.Email, returnContact.Email);
        System.assertEquals(newCon.Contact_Level__c, returnContact.Contact_Level__c);
        System.assertEquals(newAcc.Name, returnContact.Account.Name);
    }

    
}
