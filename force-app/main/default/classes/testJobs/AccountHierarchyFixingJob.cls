public without sharing class AccountHierarchyFixingJob extends ChainableJob {

    public Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('Starting AccountHierarchyFixingJob');
        return Database.getQueryLocator([
            SELECT Id, Name, Site, ParentId
            FROM Account
            WHERE Site LIKE 'Acme%'
        ]);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        System.debug('Executing AccountHierarchyFixingJob');
        for (Account account : scope) {
            account.Name = account.Name.replace('Test Account', 'Acct');
        }
        update scope;
    }
}