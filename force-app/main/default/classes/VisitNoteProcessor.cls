public class VisitNoteProcessor {
    
    // Data classes to hold the JSON structure
    public class VisitNoteData {
        public VisitData visit;
        public AccountData account;
        public ProviderVisitData providerVisit;
        public List<ProviderVisitProdDetailingData> providerVisitProdDetailing;
        public List<ProviderVisitProdDiscussionData> providerVisitProdDiscussion;
        public List<ProviderVisitDtlProductMsgData> providerVisitDtlProductMsg;
        public ConfidenceData confidence;
        public ExtractedEntitiesData extractedEntities;
    }
    
    public class VisitData {
        public String statusremarks;
        public String instructiondescription;
        public String plannedvisitstarttime;
        public String plannedvisitendtime;
        public String status;
        public String visitpriority;
        public String contactpointaddress;
    }
    
    public class AccountData {
        public String accountname;
        public String accountid;
    }
    
    public class ProviderVisitData {
        public String preprovidervisitnotes;
        public String additionalinformation;
        public String nextprovidervisitobjective;
    }
    
    public class ProviderVisitProdDetailingData {
        public String producthierarchyname;
        public Double priority;
        public String nextprvdvisitobjectives;
        public String additionalinformation;
    }
    
    public class ProviderVisitProdDiscussionData {
        public String providervisitproductdtlid;
        public String additionalinformation;
    }
    
    public class ProviderVisitDtlProductMsgData {
        public String additionalinformation;
        public String reactiontype;
        public String capturedreaction;
    }
    
    public class ConfidenceData {
        public Double overall;
        public Double visit;
        public Double providerVisit;
        public Double productDetailing;
        public Double productDiscussion;
        public Double productMessage;
    }
    
    public class ExtractedEntitiesData {
        public List<String> providers;
        public List<String> products;
        public List<String> activities;
        public List<String> outcomes;
        public List<String> dates;
        public List<String> locations;
    }
    
    public class ProcessingResult {
        @InvocableVariable(required=true)
        public Boolean success;
        
        @InvocableVariable(required=true)
        public String message;
        
        @InvocableVariable(required=false)
        public Id visitId;
        
        @InvocableVariable(required=false)
        public Id providerVisitId;
        
        @InvocableVariable(required=false)
        public List<Id> productDetailingIds;
        
        @InvocableVariable(required=false)
        public List<Id> productDiscussionIds;
        
        @InvocableVariable(required=false)
        public List<Id> productMessageIds;
        
        @InvocableVariable(required=false)
        public Double confidence;
        
        @InvocableVariable(required=false)
        public String errors;
    }
    
    @InvocableMethod(label='Process Visit Notes' description='Process unstructured visit notes and create structured data')
    public static List<ProcessingResult> processVisitNotes(List<String> visitNotesJson) {
        List<ProcessingResult> results = new List<ProcessingResult>();
        
        for (String jsonData : visitNotesJson) {
            ProcessingResult result = new ProcessingResult();
            result.success = false;
            result.productDetailingIds = new List<Id>();
            result.productDiscussionIds = new List<Id>();
            result.productMessageIds = new List<Id>();
            
            try {
                // Clean the JSON data by removing markdown formatting if present
                String cleanJsonData = cleanJsonInput(jsonData);
                VisitNoteData data = (VisitNoteData) JSON.deserialize(cleanJsonData, VisitNoteData.class);
                
                // Check confidence threshold
                if (data.confidence.overall < 0.5) {
                    result.message = 'Confidence too low: ' + data.confidence.overall;
                    results.add(result);
                    continue;
                }
                
                result = createVisitRecords(data);
                
            } catch (Exception e) {
                result.message = 'Error processing visit notes: ' + e.getMessage();
                result.errors = e.getStackTraceString();
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    private static String cleanJsonInput(String jsonInput) {
        if (jsonInput == null) {
            return '';
        }
        
        String cleaned = jsonInput.trim();
        
        // Remove markdown code block formatting
        if (cleaned.startsWith('```json')) {
            cleaned = cleaned.substring(6); // Remove ```json
        } else if (cleaned.startsWith('```')) {
            cleaned = cleaned.substring(3); // Remove ```
        }
        
        if (cleaned.endsWith('```')) {
            cleaned = cleaned.substring(0, cleaned.length() - 3); // Remove trailing ```
        }
        
        // Remove newlines and extra whitespace
        cleaned = cleaned.replace('\n', ' ').replace('\r', ' ');
        cleaned = cleaned.replaceAll('\\s+', ' '); // Replace multiple spaces with single space
        
        // Remove any leading/trailing whitespace and ensure it starts with {
        cleaned = cleaned.trim();
        if (cleaned.startsWith('n ')) {
            cleaned = cleaned.substring(2); // Remove the 'n ' prefix
        }
        
        return cleaned;
    }
    
    private static ProcessingResult createVisitRecords(VisitNoteData data) {
        ProcessingResult result = new ProcessingResult();
        result.success = false;
        result.productDetailingIds = new List<Id>();
        result.productDiscussionIds = new List<Id>();
        result.productMessageIds = new List<Id>();
        
        try {
            // Get Account ID and Contact Point Address
            Id accountId = getAccountId(data.account);
            Id contactPointAddressId = getContactPointAddressForAccount(accountId, data.visit.contactpointaddress);
            
            // Create Visit record
            Visit visitRecord = createVisitRecord(data.visit, accountId, contactPointAddressId);
            insert visitRecord;
            result.visitId = visitRecord.Id;
            
            // Create ProviderVisit record
            SObject providerVisitRecord = createProviderVisitRecord(data.providerVisit, visitRecord.Id);
            insert providerVisitRecord;
            result.providerVisitId = providerVisitRecord.Id;
            
            // Create Product Detailing records
            if (data.providerVisitProdDetailing != null && !data.providerVisitProdDetailing.isEmpty()) {
                List<SObject> productDetailingRecords = new List<SObject>();
                
                for (ProviderVisitProdDetailingData detailingData : data.providerVisitProdDetailing) {
                    SObject detailingRecord = createProductDetailingRecord(detailingData, providerVisitRecord.Id);
                    productDetailingRecords.add(detailingRecord);
                }
                
                insert productDetailingRecords;
                
                for (SObject record : productDetailingRecords) {
                    result.productDetailingIds.add(record.Id);
                }
                
                // Create Product Discussion records
                if (data.providerVisitProdDiscussion != null && !data.providerVisitProdDiscussion.isEmpty()) {
                    List<SObject> discussionRecords = new List<SObject>();
                    
                    for (Integer i = 0; i < data.providerVisitProdDiscussion.size() && i < productDetailingRecords.size(); i++) {
                        ProviderVisitProdDiscussionData discussionData = data.providerVisitProdDiscussion[i];
                        SObject discussionRecord = createProductDiscussionRecord(discussionData, productDetailingRecords[i].Id);
                        discussionRecords.add(discussionRecord);
                    }
                    
                    insert discussionRecords;
                    
                    for (SObject record : discussionRecords) {
                        result.productDiscussionIds.add(record.Id);
                    }
                }
                
                // Create Product Message records
                if (data.providerVisitDtlProductMsg != null && !data.providerVisitDtlProductMsg.isEmpty()) {
                    List<SObject> messageRecords = new List<SObject>();
                    
                    for (Integer i = 0; i < data.providerVisitDtlProductMsg.size() && i < productDetailingRecords.size(); i++) {
                        ProviderVisitDtlProductMsgData messageData = data.providerVisitDtlProductMsg[i];
                        SObject messageRecord = createProductMessageRecord(messageData, productDetailingRecords[i].Id);
                        messageRecords.add(messageRecord);
                    }
                    
                    insert messageRecords;
                    
                    for (SObject record : messageRecords) {
                        result.productMessageIds.add(record.Id);
                    }
                }
            }
            
            result.success = true;
            result.message = 'Successfully created visit records';
            result.confidence = data.confidence.overall;
            
        } catch (Exception e) {
            result.message = 'Error creating records: ' + e.getMessage();
            result.errors = e.getStackTraceString();
        }
        
        return result;
    }
    
    private static Visit createVisitRecord(VisitData data, Id accountId, Id contactPointAddressId) {
        Visit visit = new Visit();
        
        // Map data fields
        if (data.statusremarks != null) visit.StatusRemarks = data.statusremarks;
        if (data.instructiondescription != null) visit.InstructionDescription = data.instructiondescription;
        if (data.status != null) visit.Status = data.status;
        if (data.visitpriority != null) visit.VisitPriority = data.visitpriority;
        if (data.plannedvisitstarttime != null) visit.PlannedVisitStartTime = parseDateTime(data.plannedvisitstarttime);
        if (data.plannedvisitendtime != null) visit.PlannedVisitEndTime = parseDateTime(data.plannedvisitendtime);
        
        // Set required fields
        visit.OwnerId = UserInfo.getUserId();
        visit.VisitorId = UserInfo.getUserId();
        visit.AccountId = accountId;
        visit.TerritoryId = getDefaultTerritoryId();
        visit.PlaceId = contactPointAddressId;
        
        // Ensure PlannedVisitStartTime is set (required field)
        if (visit.PlannedVisitStartTime == null) {
            visit.PlannedVisitStartTime = DateTime.now();
        }
        
        return visit;
    }
    
    private static SObject createProviderVisitRecord(ProviderVisitData data, Id visitId) {
        SObject providerVisit = Schema.getGlobalDescribe().get('ProviderVisit').newSObject();
        
        // Set minimum required fields only
        providerVisit.put('OwnerId', UserInfo.getUserId());
        providerVisit.put('VisitId', visitId);
        providerVisit.put('IsSignedAwayFrmAllowDstn', true);
        
        // Account and Contact Point Address are inherited automatically from the Visit record
        
        // Set Record Type (get the default Provider Visit record type)
        List<RecordType> providerVisitRecordTypes = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'ProviderVisit' 
            AND IsActive = true 
            LIMIT 1
        ];
        if (!providerVisitRecordTypes.isEmpty()) {
            providerVisit.put('RecordTypeId', providerVisitRecordTypes[0].Id);
        }
        
        return providerVisit;
    }
    
    private static SObject createProductDetailingRecord(ProviderVisitProdDetailingData data, Id providerVisitId) {
        SObject productDetailing = Schema.getGlobalDescribe().get('ProviderVisitProdDetailing').newSObject();
        
        // Map data fields
        if (data.priority != null) productDetailing.put('Priority', data.priority);
        if (data.nextprvdvisitobjectives != null) productDetailing.put('NextPrvdVisitObjectives', data.nextprvdvisitobjectives);
        if (data.additionalinformation != null) productDetailing.put('AdditionalInformation', data.additionalinformation);
        if (data.producthierarchyname != null) productDetailing.put('ProductHierarchyName', data.producthierarchyname);
        
        // Set required fields
        productDetailing.put('OwnerId', UserInfo.getUserId());
        productDetailing.put('ProviderVisitId', providerVisitId);
        productDetailing.put('ProductId', getProductIdByName(data.producthierarchyname));
        productDetailing.put('IsOffLabel', false);
        productDetailing.put('IsGeneratedFromPresentation', false);
        productDetailing.put('IsSignatureCaptured', false);
        
        return productDetailing;
    }
    
    private static SObject createProductDiscussionRecord(ProviderVisitProdDiscussionData data, Id productDetailingId) {
        SObject productDiscussion = Schema.getGlobalDescribe().get('ProviderVisitProdDiscussion').newSObject();
        
        // Map data fields
        if (data.additionalinformation != null) productDiscussion.put('AdditionalInformation', data.additionalinformation);
        
        // Set required fields
        productDiscussion.put('OwnerId', UserInfo.getUserId());
        productDiscussion.put('ProviderVisitProductDtlId', productDetailingId);
        
        return productDiscussion;
    }
    
    private static SObject createProductMessageRecord(ProviderVisitDtlProductMsgData data, Id productDetailingId) {
        SObject productMessage = Schema.getGlobalDescribe().get('ProviderVisitDtlProductMsg').newSObject();
        
        // Map data fields
        if (data.additionalinformation != null) productMessage.put('AdditionalInformation', data.additionalinformation);
        if (data.reactiontype != null) productMessage.put('ReactionType', data.reactiontype);
        if (data.capturedreaction != null) productMessage.put('CapturedReaction', data.capturedreaction);
        
        // Set required fields
        productMessage.put('OwnerId', UserInfo.getUserId());
        productMessage.put('ProviderVisitProductDtlId', productDetailingId);
        productMessage.put('IsGeneratedFromPresentation', false);
        
        return productMessage;
    }
    
    private static DateTime parseDateTime(String dateTimeStr) {
        try {
            return DateTime.valueOfGmt(dateTimeStr);
        } catch (Exception e) {
            return DateTime.now();
        }
    }
    
    private static Id getDefaultAccountId() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        return accounts.isEmpty() ? null : accounts[0].Id;
    }
    
    private static Id getDefaultTerritoryId() {
        List<Territory2> territories = [SELECT Id FROM Territory2 LIMIT 1];
        return territories.isEmpty() ? null : territories[0].Id;
    }
    
    private static Id getDefaultProductId() {
        // First try to get a default Product2
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];
        if (!products.isEmpty()) {
            return products[0].Id;
        }
        
        // If no Product2, try Life Sciences Marketable Product
        List<SObject> marketableProducts = [SELECT Id FROM LifeSciMarketableProduct LIMIT 1];
        if (!marketableProducts.isEmpty()) {
            return marketableProducts[0].Id;
        }
        
        return null;
    }
    
    private static String getCurrentUserTerritoryName() {
        try {
            // Get current user's territory
            List<UserTerritory2Association> userTerritories = [
                SELECT Territory2.Name 
                FROM UserTerritory2Association 
                WHERE UserId = :UserInfo.getUserId() 
                LIMIT 1
            ];
            return userTerritories.isEmpty() ? 'Default Territory' : userTerritories[0].Territory2.Name;
        } catch (Exception e) {
            return 'Default Territory';
        }
    }
    
    private static Id getProductIdByName(String productName) {
        if (productName == null || productName.trim() == '') {
            return getDefaultProductId();
        }
        
        try {
            // First try to find in Product2
            List<Product2> products = [
                SELECT Id 
                FROM Product2 
                WHERE Name = :productName 
                   OR ProductCode = :productName 
                   OR Description LIKE :'%' + productName + '%'
                LIMIT 1
            ];
            
            if (!products.isEmpty()) {
                return products[0].Id;
            }
            
            // If not found in Product2, try Life Sciences Marketable Product
            List<SObject> marketableProducts = [
                SELECT Id 
                FROM LifeSciMarketableProduct 
                WHERE Name = :productName 
                   OR ProductCode = :productName 
                   OR Description LIKE :'%' + productName + '%'
                LIMIT 1
            ];
            
            if (!marketableProducts.isEmpty()) {
                return marketableProducts[0].Id;
            }
            
            // If still not found, return default
            return getDefaultProductId();
            
        } catch (Exception e) {
            return getDefaultProductId();
        }
    }
    
    private static Id getContactPointAddressId(String addressInfo) {
        if (addressInfo == null || addressInfo.trim() == '') {
            return getDefaultContactPointAddressId();
        }
        
        try {
            // Try to find Contact Point Address by name or city
            List<ContactPointAddress> addresses = [
                SELECT Id 
                FROM ContactPointAddress 
                WHERE AddressType = 'Office' 
                   AND (Name LIKE :'%' + addressInfo + '%' 
                        OR City LIKE :'%' + addressInfo + '%')
                LIMIT 1
            ];
            
            if (!addresses.isEmpty()) {
                return addresses[0].Id;
            }
            
            // If not found, return default
            return getDefaultContactPointAddressId();
            
        } catch (Exception e) {
            return getDefaultContactPointAddressId();
        }
    }
    
    public static Id getAccountId(AccountData accountData) {
        if (accountData == null) {
            return getDefaultAccountId();
        }
        
        // If Account ID is provided, use it
        if (accountData.accountid != null && accountData.accountid.trim() != '') {
            try {
                return Id.valueOf(accountData.accountid);
            } catch (Exception e) {
                // Invalid ID, fall back to name lookup
            }
        }
        
        // If Account Name is provided, look it up
        if (accountData.accountname != null && accountData.accountname.trim() != '') {
            try {
                List<Account> accounts = [
                    SELECT Id 
                    FROM Account 
                    WHERE Name = :accountData.accountname.trim()
                       OR Name LIKE :'%' + accountData.accountname.trim() + '%'
                    LIMIT 1
                ];
                if (!accounts.isEmpty()) {
                    return accounts[0].Id;
                }
            } catch (Exception e) {
                // Fall back to default
            }
        }
        
        return getDefaultAccountId();
    }
    
    public static Id getContactPointAddressForAccount(Id accountId, String addressInfo) {
        if (accountId == null) {
            return getDefaultContactPointAddressId();
        }
        
        try {
            // First try to get the default Contact Point Address for the account
            List<ContactPointAddress> defaultAddresses = [
                SELECT Id 
                FROM ContactPointAddress 
                WHERE ParentId = :accountId 
                   AND IsDefault = true
                LIMIT 1
            ];
            
            if (!defaultAddresses.isEmpty()) {
                return defaultAddresses[0].Id;
            }
            
            // If no default, try to get the primary Contact Point Address
            List<ContactPointAddress> primaryAddresses = [
                SELECT Id 
                FROM ContactPointAddress 
                WHERE ParentId = :accountId 
                ORDER BY IsDefault DESC, CreatedDate ASC
                LIMIT 1
            ];
            
            if (!primaryAddresses.isEmpty()) {
                return primaryAddresses[0].Id;
            }
            
            // If no Contact Point Address found for the account, try to find by address info
            if (addressInfo != null && addressInfo.trim() != '') {
                List<ContactPointAddress> addresses = [
                    SELECT Id 
                    FROM ContactPointAddress 
                    WHERE (Name LIKE :'%' + addressInfo.trim() + '%' 
                           OR City LIKE :'%' + addressInfo.trim() + '%')
                    LIMIT 1
                ];
                
                if (!addresses.isEmpty()) {
                    return addresses[0].Id;
                }
            }
            
            // Fall back to default
            return getDefaultContactPointAddressId();
            
        } catch (Exception e) {
            return getDefaultContactPointAddressId();
        }
    }
    
    private static Id getDefaultContactPointAddressId() {
        try {
            // Get a default Contact Point Address
            List<ContactPointAddress> addresses = [
                SELECT Id 
                FROM ContactPointAddress 
                WHERE IsDefault = true
                LIMIT 1
            ];
            return addresses.isEmpty() ? null : addresses[0].Id;
        } catch (Exception e) {
            return null;
        }
    }
}