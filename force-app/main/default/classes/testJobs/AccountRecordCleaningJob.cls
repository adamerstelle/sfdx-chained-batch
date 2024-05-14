public without sharing class AccountRecordCleaningJob extends ChainableJob {

    public Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('Starting AccountRecordCleaningJob');
        return Database.getQueryLocator([
            SELECT Id, Name 
            FROM Account
            WHERE Site LIKE 'Acme%'
        ]);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        System.debug('Executing AccountRecordCleaningJob');
        for (Account account : scope) {
            account.Name = account.Name.replace('Test Account', 'Acct');
        }
        update scope;
    }
}