public with sharing class FileCreatorFromFlow {
    
    // Invocable method to create files and attach them to records
    @InvocableMethod(label='Create and Attach File' description='Creates a file from a list of strings and attaches it to the given record ID')
    public static void createAndAttachFile(List<FileRequest> requests) {
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        // Process each request
        for (FileRequest request : requests) {
            // Validate each individual request
            if (String.isBlank(request.recordId) || request.textList == null || request.textList.isEmpty()) {
                // Skip invalid request and log for debugging
                System.debug(LoggingLevel.INFO, 'Skipping invalid request: ' + request);
                continue; // Skip if record ID is missing or list is empty
            }
            
            try {
                // Convert the list of strings into a single text block
                String fileContent = String.join(request.textList, '\n'); // New line separated
                
                // Create ContentVersion (File)
                ContentVersion content = new ContentVersion();
                content.Title = 'Generated File';
                content.PathOnClient = 'GeneratedFile.txt';
                content.VersionData = Blob.valueOf(fileContent);
                content.FirstPublishLocationId = request.recordId; // Attach to record
                contentVersions.add(content);
            } catch (Exception e) {
                // Handle any unexpected errors during file creation
                System.debug(LoggingLevel.ERROR, 'Error processing request for recordId ' + request.recordId + ': ' + e.getMessage());
            }
        }
        
        // Bulk insert contentVersions if any are valid
        if (!contentVersions.isEmpty()) {
            try {
                insert contentVersions;
                System.debug(LoggingLevel.INFO, 'Files created successfully: ' + contentVersions);
            } catch (DmlException dmlEx) {
                // Handle DML exceptions (e.g., too many records to insert)
                System.debug(LoggingLevel.ERROR, 'Error inserting content versions: ' + dmlEx.getMessage());
            }
        } else {
            System.debug(LoggingLevel.INFO, 'No valid content versions were created.');
        }
    }
    
    // Wrapper class for passing data from Flow
    public class FileRequest {
        @InvocableVariable(label='Record ID' description='ID of the Account_Contract__c record to attach the file to' required=true)
        public String recordId;
        
        @InvocableVariable(label='Text List' description='List of text lines to be included in the file' required=true)
        public List<String> textList;
    }
    
}