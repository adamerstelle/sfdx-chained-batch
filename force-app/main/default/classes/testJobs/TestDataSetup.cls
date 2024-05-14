public with sharing class TestDataSetup {
    public static void setupData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) { // creating 20 Companies
            for(Integer j = 0; j < 10; j++) { // with 10 sub-accounts each
                accounts.add(new Account(Name = 'Test Account ' + j, Site = 'Acme ' + i));
            }
        }
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(
                            LastName = 'Test Contact ' + i,
                            Department = 'Acme ' + Integer.valueof((Math.random() * 20)), // Stores Company Name
                            Title = 'Test Account ' + Integer.valueof((Math.random() * 10)) // Stores Account Name
                        )
            );
        }
        insert contacts;
    }
}