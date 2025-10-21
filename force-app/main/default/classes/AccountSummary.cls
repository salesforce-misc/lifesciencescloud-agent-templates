/**
 * Data model for Account Summary information
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public class AccountSummary {
    public Id accountId;
    public String accountName;
    public String territoryName;
    public Id territoryId;
    public DateTime lastUpdated;
    public String keyInformation;
    public String strategicFocus;
    public String priority;
    public String recentActivity;
    public List<String> keyContacts;
    public String priorityReason;
    
    public AccountSummary() {
        this.keyContacts = new List<String>();
    }
    
    public void addKeyContact(String contact) {
        if (String.isNotBlank(contact)) {
            this.keyContacts.add(contact);
        }
    }
}
