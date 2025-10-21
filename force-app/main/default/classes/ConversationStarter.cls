/**
 * Conversation starter data model
 * Contains conversation starters for specific accounts
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public class ConversationStarter {
    
    // Account information
    public String accountName;
    public Id accountId;
    
    // Conversation starters
    public List<String> starters;
    
    // Context information
    public String context;
    public String lastVisitDate;
    public String visitObjective;
    
    // Quality metrics
    public Double relevanceScore;
    public String source;
    
    /**
     * Constructor
     */
    public ConversationStarter() {
        this.starters = new List<String>();
    }
    
    /**
     * Add a conversation starter
     */
    public void addStarter(String starter) {
        this.starters.add(starter);
    }
    
    /**
     * Get formatted conversation starters
     */
    public String getFormattedStarters() {
        if (starters.isEmpty()) {
            return 'No conversation starters available';
        }
        
        String formatted = '💬 **Conversation Starters for ' + accountName + ':**\n';
        for (Integer i = 0; i < starters.size(); i++) {
            formatted += (i + 1) + '. ' + starters[i] + '\n';
        }
        
        if (context != null) {
            formatted += '\n📝 **Context:** ' + context + '\n';
        }
        
        if (lastVisitDate != null) {
            formatted += '📅 **Last Visit:** ' + lastVisitDate + '\n';
        }
        
        return formatted;
    }
    
    /**
     * Get starter count
     */
    public Integer getStarterCount() {
        return starters.size();
    }
    
    /**
     * Check if starters are available
     */
    public Boolean hasStarters() {
        return !starters.isEmpty();
    }
}
