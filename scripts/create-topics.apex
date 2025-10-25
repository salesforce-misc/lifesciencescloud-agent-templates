// lifesciencescloud-agent-templates - Topic Creation Script
// This script creates the necessary Topic records for the Agentforce agents

List<String> topicNames = new List<String>{
    'Daily Briefing',
    'Influencer Map',
    'NextBestCustomer',
    'PostCallVisitNotes'
};

List<Topic> topicsToCreate = new List<Topic>();
List<Topic> existingTopics = [SELECT Id, Name FROM Topic WHERE Name IN :topicNames];

Set<String> existingTopicNames = new Set<String>();
for (Topic existingTopic : existingTopics) {
    existingTopicNames.add(existingTopic.Name);
}

for (String topicName : topicNames) {
    if (!existingTopicNames.contains(topicName)) {
        Topic newTopic = new Topic();
        newTopic.Name = topicName;
        topicsToCreate.add(newTopic);
    }
}

if (!topicsToCreate.isEmpty()) {
    try {
        insert topicsToCreate;
        System.debug('Successfully created ' + topicsToCreate.size() + ' Topic records');
        
        for (Topic topic : topicsToCreate) {
            System.debug('Created Topic: ' + topic.Name + ' (ID: ' + topic.Id + ')');
        }
    } catch (Exception e) {
        System.debug('Error creating Topic records: ' + e.getMessage());
        throw e;
    }
} else {
    System.debug('All Topic records already exist. No new records created.');
}

// Verify all topics exist
List<Topic> allTopics = [SELECT Id, Name FROM Topic WHERE Name IN :topicNames];
System.debug('Total Topic records found: ' + allTopics.size());

for (Topic topic : allTopics) {
    System.debug('Topic: ' + topic.Name + ' (ID: ' + topic.Id + ')');
}
