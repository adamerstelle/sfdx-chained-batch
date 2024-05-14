public without sharing class ContactRecordCleaningJob extends ChainableJob {

    public Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('Starting ContactRecordCleaningJob');
        return Database.getQueryLocator([
            SELECT Id, LastName, Department, Title 
            FROM Contact
            WHERE Department LIKE 'Acme%'
        ]);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        System.debug('Executing ContactRecordCleaningJob');
        for (Account account : scope) {
            account.Name = account.Name.replace('Test Account', 'Acct');
        }
        update scope;
    }
}