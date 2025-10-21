/**
 * Data model for Priority Assessment information
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public class PriorityAssessment {
    public Integer totalAccounts;
    public Integer accountsWithRecentActivity;
    public Id priorityAccountId;
    public String priorityAccountName;
    public String priorityReason;
    public Double averageCompletionRate;
    
    public PriorityAssessment() {
        this.totalAccounts = 0;
        this.accountsWithRecentActivity = 0;
        this.averageCompletionRate = 0.0;
    }
    
    public String getPriorityLevel() {
        if (totalAccounts == 0) return 'None';
        if (averageCompletionRate >= 0.8) return 'High';
        if (averageCompletionRate >= 0.6) return 'Medium';
        return 'Low';
    }
}
