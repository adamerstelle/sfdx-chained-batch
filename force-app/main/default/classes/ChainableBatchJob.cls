public class ChainableBatchJob {
    private List<ChainableJob> jobs = new List<ChainableJob>();
    private Integer currentJobIndex = -1;

    // private Id id;
    private String name;

    private Integer batchSize = 200;
    private Integer delayOfMinutes = 0;
    private Boolean continueOnError = false;
    private Boolean sendNotifications = false;
    private String filter;

    /**
     * Methods to create a new ChainableBatchJob
     */
    public static ChainableBatchJob createNew(String name) {
        System.debug('Creating ChainableBatchJob from scratch with name: ' + name);
        ChainableBatchJob job = new ChainableBatchJob();
        job.name = name;
        return job;
    }

    // public static ChainableBatchJob resumeFromPrevious(Id id) {
    //     System.debug('Resuming ChainableBatchJob with id: ' + id);
    //     ChainableBatchJob job = new ChainableBatchJob();
    //     job.id = id;
    //     return job;
    // }

    private ChainableBatchJob() {}

    /**
     * Methods to configure the ChainableBatchJob. Uses the Fluent Interface pattern.
     */
    public ChainableBatchJob withBatchSize(Integer batchSize) {
        this.batchSize = batchSize;
        return this;
    }
    public ChainableBatchJob withDelayOfMinutes(Integer delayOfMinutes) {
        this.delayOfMinutes = delayOfMinutes;
        return this;
    }
    public ChainableBatchJob withFilter(String filter) {
        this.filter = filter;
        return this;
    }

    public ChainableBatchJob continuingOnError() {
        this.continueOnError = true;
        return this;
    }

    public ChainableBatchJob withSendingNotifications() {
        this.sendNotifications = true;
        return this;
    }
    public ChainableJob withJob(ChainableJob job) {
        System.debug('Adding job of Class: ' + getClassName(job));

        // set job default values
        job
            .setChainableBatchJob(this)
            .withFilter(filter)
            .withBatchSize(batchSize)
            .withDelayOfMinutes(delayOfMinutes);
        
        // these are positive only
        if(continueOnError) {job.continuingOnError();}
        if(sendNotifications) {job.withSendingNotification();}

        jobs.add(job);
        return job;
    }

    /**
     * Methods to start and finish the ChainableBatchJob
     */
    public void startChain() {
        System.debug('Starting ChainableBatchJob');
        continueProcessing(); // this will eventually tell SF to start the first job

        // save details of the current state
    }

    public void currentJobFinished() {
        System.debug('Current job finished');
        continueProcessing();
    }

    public void finishChain() {
        System.debug('Finished ChainableBatchJob');
    }

    // public void saveCurrentState() {
    //     System.debug('Saving current state');
    // }

    private void continueProcessing() {
        currentJobIndex++;
        System.debug('index = ' + currentJobIndex + ' jobs.size() = ' + jobs.size());
        if (currentJobIndex < jobs.size()) {
            ChainableJob job = jobs[currentJobIndex];
            System.debug('Starting job from Class: ' + getClassName(job));
            job.start();
        }
        else {
            this.finishChain();
        }
    }

    public static String getClassName(Object obj) {
        String typeName = 'Date';
    
        // Attempt to cast the object to Datetime
        // If it succeeds, the object is a date
        // If a type exception is thrown, catch it and parse the exception for the actual type
        try {
            Date d = (Date) obj;
        } catch(TypeException te) {
            String message = te.getMessage().substringAfter('Invalid conversion from runtime type ');
            typeName = message.substringBefore(' to Date');
        }
        return typeName;
    }
}