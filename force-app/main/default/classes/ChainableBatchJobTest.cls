@IsTest
public class ChainableBatchJobTest {

    @TestSetup
    private static void setupData() {
        TestDataSetup.setupData();
    }

    @IsTest 
    private static void testChainableBatchJob() {
        // arrange

        // act
        Test.startTest();
            ChainableBatchJob.createNew('Test Batch Job')
                .withSendingNotifications()
                .continuingOnError()
                .withJob(new AccountRecordCleaningJob())
                    .withJobName('Account Record Cleaning Testing Job')
                    .andThen()
                .startChain();
        Test.stopTest();

        // assert
        List<Account> results = [
            SELECT Id, Name 
            FROM Account
        ];

        for (Account result : results) {
            System.assertEquals(false, result.Name.contains('Acme'), 'Acme should have been replaced');
        }
    }

    @IsTest
    private static void shouldDemonstrateFluentInterface() {
        // arrange
        ChainableBatchJob sut = ChainableBatchJob.createNew('Test Batch Job')
            .withSendingNotifications()
            .withBatchSize(100)
            .withDelayOfMinutes(0)
            .withFilter('Site LIKE "Acme%"')
            .withJob(new AccountRecordCleaningJob())
                .withBatchSize(50)
                .continuingOnError()
                .andThen()
            .withJob(new ContactRecordCleaningJob())
                .withBatchSize(300)
                .andThen()
            .withJob(new AccountHierarchyFixingJob())
                .andThen();

        // act
        sut.startChain();

        // assert
    }
}