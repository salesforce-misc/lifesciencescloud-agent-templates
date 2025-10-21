/**
 * Data model for Daily Briefing data container
 * 
 * @author LSC4CE Team
 * @version 1.0
 */
public class BriefingData {
    public User user;
    public List<Visit> visits;
    public List<ProviderVisit> providerVisits;
    public List<AccountSummary> accountSummaries;
    public PriorityAssessment priority;
    public String focus;
    public Date targetDate;
    public String userTerritoryId;
    public String userTerritoryName;
    public String timePeriod;
    public Map<Id, String> placeAddresses;
}
