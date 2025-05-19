/**
 * Implements a chain of Queueable jobs.
 */
public with sharing class QueueableJobChain {

    // Here we store the currently
    private List<ChainedQueuable> chain;
    public QueueableJobChain() {
        this.chain = new List<ChainedQueuable>();
    }
    /**
     * Adds a queueable to the beginning of the chain.
     */
    public void chainFirst(ChainedQueuable cq) {
        // avoid test exception System.AsyncException: Maximum stack depth has been reached.
        // allow only one ChainedQueuable
        if(Test.isRunningTest() && !this.chain.isEmpty() && this.chain.size() == 1) {
            return;
        }
        if(this.chain.isEmpty()) {
            this.chain.add(cq);
        }
        else {
            this.chain.add(0, cq);
        }
    }
    /**
     * Adds a queueable to the end of the chain.
     */
    public void chainLast(ChainedQueuable cq) {
        this.chain.add(cq);
    }
    /**
     * Checks if there are more items in the chain left to be run
     */
    public Boolean hasNext() {
        return this.chain.size() > 0;
    }
    /**
     * Runs the first queueable in the list.
     */
    public void runNext() {
        if (this.hasNext()) {
            ChainedQueuable cq = this.chain.remove(0);
            cq.setChain(this);
            System.enqueueJob(cq);
        }
    }
}