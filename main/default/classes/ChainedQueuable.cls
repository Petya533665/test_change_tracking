/**
* This is meant to be the super-class for any Queueable job class we want to participate in a chain.
*/
public abstract class ChainedQueuable implements Queueable, Database.AllowsCallouts {
    // Reference to the chain this queueable belongs to, because we can't allow callbacks to the parent chain
    // for when this class's execute method ends.
    protected QueueableJobChain chain;

    /**
     * The constructor receives a chain as parameter.
     */
    public ChainedQueuable(QueueableJobChain chain) {
        this.chain = chain;
    }

    /**
     * Executes the next queueable in the chain, if this queueable is in a chain.
     */
    protected void executeNext() {
        if (this.isChained()) {
            this.chain.runNext();
        }
    }

    /**
     * Sets the job's chain.
     */
    public void setChain(QueueableJobChain chain) {
        this.chain = chain;
    }

    /**
     * execute method from the Queueable interface. You're meant to override this in any sub-class.
     */
    public virtual void execute(QueueableContext context) {
        this.executeNext();
    }

    /**
     * Tells us if the job is in a chain or not.
     */
    protected boolean isChained() {
        return this.chain != null;
    }
}