public abstract class ChainableJob implements Database.Batchable<SObject>, Database.Stateful {
    private String jobName;
    private String jobClassName = ChainableBatchJob.getClassName(this);

    private ChainableBatchJob chainedBatchJob;
    private Integer batchSize;
    private Integer delayOfMinutes;
    private String filter;

    // these are positive only flags, so we need to initialize them to false
    private Boolean continueOnError = false;
    private Boolean sendNotification = false;

    /**
     * Methods to make our ChainableBatchJob work
     */
    public ChainableJob setChainableBatchJob(ChainableBatchJob chainedBatchJob) {
        this.chainedBatchJob = chainedBatchJob;
        return this;
    }

    public void start() {
        if(jobName == null) {
            jobName = jobClassName;
        }
        String batchJobName = jobName + ' ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss');

        System.debug('Scheduling BatchJob ' + batchJobName + '(of class: ' + jobClassName + ') with delay of ' + delayOfMinutes + ' minutes and batch size of ' + batchSize);
        System.scheduleBatch(this, jobName, delayOfMinutes, batchSize);
    }

    public virtual void finish(Database.BatchableContext context) {
        System.debug('Within ChainableJob ' + jobName + ' finishing.');
        AsyncApexJob apexJob = [
            SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob 
            WHERE Id =: context.getJobId()
        ];
        String jobStatus =jobName + ' job processed ' + apexJob.TotalJobItems + ' batches with '+ apexJob.NumberOfErrors + ' failures. \n All Batch jobs have been completed.';
        System.debug(jobStatus);

        if(sendNotification) {
            // send notification that a particular job in the batch is done

            System.debug('Building email for notification that Job is complete');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[] {apexJob.CreatedBy.Email};
            mail.setToAddresses(toAddress);
            mail.setSubject('Apex Job status is ' + apexJob.Status);
            mail.setPlainTextBody(jobStatus);
            try {
                System.debug('Sending email notification that Job is complete');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } 
            catch (Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
            }
        }

        if(!continueOnError && apexJob.NumberOfErrors > 0) {
            throw new ChainableJobException(jobName + ' job failed with ' + apexJob.NumberOfErrors + ' failures, and our ChainableJob is set to stop on error.');
        }
        if(chainedBatchJob != null) {
            // this can be null if the job is run all by itself outside of a Chainable Job
            chainedBatchJob.currentJobFinished();
        }
    }

    public String getChainableFilter() {
        return filter??'';
    }

    /**
     * Methods to configure the ChainableJob. Uses the Fluent Interface pattern.
     */
    public ChainableJob withBatchSize(Integer batchSize) {
        this.batchSize = batchSize;
        return this;
    }

    public ChainableJob withDelayOfMinutes(Integer delayOfMinutes) {
        this.delayOfMinutes = delayOfMinutes;
        return this;
    }

    public ChainableJob withJobName(String jobName) {
        this.jobName = jobName;
        return this;
    }

    public ChainableJob withFilter(String filter) {
        this.filter = filter;
        return this;
    }

    public ChainableJob continuingOnError() {
        this.continueOnError = true;
        return this;
    }

    public ChainableJob withSendingNotification() {
        this.sendNotification = true;
        return this;
    }

    public ChainableBatchJob andThen() {
        return chainedBatchJob;
    }
}