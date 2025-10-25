// lifesciencescloud-agent-templates - Deployment Validation Script
// This script validates that all components were deployed successfully

System.debug('=== lifesciencescloud-agent-templates Validation ===');

// Validate GenAiFunctions
List<GenAiFunction> genAiFunctions = [SELECT Id, DeveloperName, MasterLabel FROM GenAiFunction];
System.debug('GenAiFunctions found: ' + genAiFunctions.size());
for (GenAiFunction func : genAiFunctions) {
    System.debug('  - ' + func.DeveloperName + ' (' + func.MasterLabel + ')');
}

// Validate GenAiPlugins
List<GenAiPlugin> genAiPlugins = [SELECT Id, DeveloperName, MasterLabel FROM GenAiPlugin];
System.debug('GenAiPlugins found: ' + genAiPlugins.size());
for (GenAiPlugin plugin : genAiPlugins) {
    System.debug('  - ' + plugin.DeveloperName + ' (' + plugin.MasterLabel + ')');
}

// Validate GenAiPlannerBundles
List<GenAiPlannerBundle> genAiPlannerBundles = [SELECT Id, DeveloperName, MasterLabel FROM GenAiPlannerBundle];
System.debug('GenAiPlannerBundles found: ' + genAiPlannerBundles.size());
for (GenAiPlannerBundle bundle : genAiPlannerBundles) {
    System.debug('  - ' + bundle.DeveloperName + ' (' + bundle.MasterLabel + ')');
}

// Validate GenAiPromptTemplates
List<GenAiPromptTemplate> genAiPromptTemplates = [SELECT Id, DeveloperName, MasterLabel FROM GenAiPromptTemplate];
System.debug('GenAiPromptTemplates found: ' + genAiPromptTemplates.size());
for (GenAiPromptTemplate template : genAiPromptTemplates) {
    System.debug('  - ' + template.DeveloperName + ' (' + template.MasterLabel + ')');
}

// Validate Flows
List<FlowDefinition> flows = [SELECT Id, DeveloperName, MasterLabel FROM FlowDefinition];
System.debug('Flows found: ' + flows.size());
for (FlowDefinition flow : flows) {
    System.debug('  - ' + flow.DeveloperName + ' (' + flow.MasterLabel + ')');
}

// Validate Apex Classes
List<ApexClass> apexClasses = [SELECT Id, Name FROM ApexClass WHERE NamespacePrefix = null];
System.debug('Apex Classes found: ' + apexClasses.size());
for (ApexClass cls : apexClasses) {
    System.debug('  - ' + cls.Name);
}

// Validate Custom Applications
List<CustomApplication> customApps = [SELECT Id, DeveloperName, MasterLabel FROM CustomApplication];
System.debug('Custom Applications found: ' + customApps.size());
for (CustomApplication app : customApps) {
    System.debug('  - ' + app.DeveloperName + ' (' + app.MasterLabel + ')');
}

// Validate Topics
List<Topic> topics = [SELECT Id, Name FROM Topic];
System.debug('Topics found: ' + topics.size());
for (Topic topic : topics) {
    System.debug('  - ' + topic.Name);
}

System.debug('=== Validation Complete ===');

// Check for expected components
Set<String> expectedGenAiFunctions = new Set<String>{
    'Generate_Complete_Daily_Briefing',
    'GetNBC',
    'Influencer_Map_Flow',
    'Visit_Note_Processor_Simple'
};

Set<String> expectedGenAiPlugins = new Set<String>{
    'Daily_Briefing',
    'Influencer_Map',
    'NextBestCustomer',
    'PostCallVisitNotes'
};

Set<String> expectedGenAiPlannerBundles = new Set<String>{
    'Daily_Briefing_Agent',
    'Influencer_Map_Agent',
    'NextBestCustomer_Agent',
    'PostCallVisitNotes_Agent'
};

// Validate expected GenAiFunctions
Set<String> foundGenAiFunctions = new Set<String>();
for (GenAiFunction func : genAiFunctions) {
    foundGenAiFunctions.add(func.DeveloperName);
}

Set<String> missingGenAiFunctions = new Set<String>();
for (String expected : expectedGenAiFunctions) {
    if (!foundGenAiFunctions.contains(expected)) {
        missingGenAiFunctions.add(expected);
    }
}

if (missingGenAiFunctions.isEmpty()) {
    System.debug('✓ All expected GenAiFunctions are present');
} else {
    System.debug('✗ Missing GenAiFunctions: ' + missingGenAiFunctions);
}

// Validate expected GenAiPlugins
Set<String> foundGenAiPlugins = new Set<String>();
for (GenAiPlugin plugin : genAiPlugins) {
    foundGenAiPlugins.add(plugin.DeveloperName);
}

Set<String> missingGenAiPlugins = new Set<String>();
for (String expected : expectedGenAiPlugins) {
    if (!foundGenAiPlugins.contains(expected)) {
        missingGenAiPlugins.add(expected);
    }
}

if (missingGenAiPlugins.isEmpty()) {
    System.debug('✓ All expected GenAiPlugins are present');
} else {
    System.debug('✗ Missing GenAiPlugins: ' + missingGenAiPlugins);
}

// Validate expected GenAiPlannerBundles
Set<String> foundGenAiPlannerBundles = new Set<String>();
for (GenAiPlannerBundle bundle : genAiPlannerBundles) {
    foundGenAiPlannerBundles.add(bundle.DeveloperName);
}

Set<String> missingGenAiPlannerBundles = new Set<String>();
for (String expected : expectedGenAiPlannerBundles) {
    if (!foundGenAiPlannerBundles.contains(expected)) {
        missingGenAiPlannerBundles.add(expected);
    }
}

if (missingGenAiPlannerBundles.isEmpty()) {
    System.debug('✓ All expected GenAiPlannerBundles are present');
} else {
    System.debug('✗ Missing GenAiPlannerBundles: ' + missingGenAiPlannerBundles);
}

System.debug('=== Deployment Validation Summary ===');
System.debug('Total Components Deployed:');
System.debug('  - GenAiFunctions: ' + genAiFunctions.size());
System.debug('  - GenAiPlugins: ' + genAiPlugins.size());
System.debug('  - GenAiPlannerBundles: ' + genAiPlannerBundles.size());
System.debug('  - GenAiPromptTemplates: ' + genAiPromptTemplates.size());
System.debug('  - Flows: ' + flows.size());
System.debug('  - Apex Classes: ' + apexClasses.size());
System.debug('  - Custom Applications: ' + customApps.size());
System.debug('  - Topics: ' + topics.size());
