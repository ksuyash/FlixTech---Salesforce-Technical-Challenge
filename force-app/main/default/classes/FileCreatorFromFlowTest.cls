@isTest
public class FileCreatorFromFlowTest {

    // Test setup to create necessary records (e.g., Account) for the test methods
    @testSetup
    static void setupData() {
        // Create an Account that will be used for attaching files
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
    }

    // Test method to cover valid case
    @isTest
    static void testCreateAndAttachFile_ValidRequest() {
        // Retrieve the Account created in the @testSetup
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        
        // Prepare test data (valid request)
        FileCreatorFromFlow.FileRequest request = new FileCreatorFromFlow.FileRequest();
        request.recordId = testAccount.Id;
        request.textList = new List<String>{'Line 1', 'Line 2', 'Line 3'};

        // Call the method under test
        Test.startTest();
        FileCreatorFromFlow.createAndAttachFile(new List<FileCreatorFromFlow.FileRequest>{request});
        Test.stopTest();

        // Verify the result
        List<ContentVersion> contentVersions = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = :testAccount.Id];
        System.assertEquals(1, contentVersions.size(), 'One content version should have been created');
        System.assertEquals('Generated File', contentVersions[0].Title, 'The file title should be "Generated File"');
        System.assertEquals(testAccount.Id, contentVersions[0].FirstPublishLocationId, 'The file should be attached to the correct Account record');
    }

    // Test method to handle case where request has empty textList
    @isTest
    static void testCreateAndAttachFile_EmptyTextList() {
        // Retrieve the Account created in the @testSetup
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        
        // Prepare test data with empty textList
        FileCreatorFromFlow.FileRequest request = new FileCreatorFromFlow.FileRequest();
        request.recordId = testAccount.Id;
        request.textList = new List<String>(); // Empty list

        // Call the method under test
        Test.startTest();
        FileCreatorFromFlow.createAndAttachFile(new List<FileCreatorFromFlow.FileRequest>{request});
        Test.stopTest();

        // Verify no content version was created
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId = :testAccount.Id];
        System.assertEquals(0, contentVersions.size(), 'No content version should have been created when textList is empty');
    }

    // Test method to handle case where request has null textList
    @isTest
    static void testCreateAndAttachFile_NullTextList() {
        // Retrieve the Account created in the @testSetup
        Account testAccount = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        
        // Prepare test data with null textList
        FileCreatorFromFlow.FileRequest request = new FileCreatorFromFlow.FileRequest();
        request.recordId = testAccount.Id;
        request.textList = null; // Null list

        // Call the method under test
        Test.startTest();
        FileCreatorFromFlow.createAndAttachFile(new List<FileCreatorFromFlow.FileRequest>{request});
        Test.stopTest();

        // Verify no content version was created
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId = :testAccount.Id];
        System.assertEquals(0, contentVersions.size(), 'No content version should have been created when textList is null');
    }

    // Test method to handle case where request has missing recordId
    @isTest
    static void testCreateAndAttachFile_MissingRecordId() {
        // Prepare test data with missing recordId
        FileCreatorFromFlow.FileRequest request = new FileCreatorFromFlow.FileRequest();
        request.recordId = ''; // Empty string for recordId
        request.textList = new List<String>{'Line 1', 'Line 2'};

        // Call the method under test
        Test.startTest();
        FileCreatorFromFlow.createAndAttachFile(new List<FileCreatorFromFlow.FileRequest>{request});
        Test.stopTest();

        // Verify no content version was created (since recordId is missing)
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assertEquals(0, contentVersions.size(), 'No content version should have been created when recordId is missing');
    }

    // Test method to ensure no ContentVersion is created for invalid data (empty recordId and empty textList)
    @isTest
    static void testCreateAndAttachFile_InvalidRequest() {
        // Prepare test data with invalid recordId and empty textList
        FileCreatorFromFlow.FileRequest request = new FileCreatorFromFlow.FileRequest();
        request.recordId = ''; // Empty string for recordId
        request.textList = new List<String>(); // Empty textList

        // Call the method under test
        Test.startTest();
        FileCreatorFromFlow.createAndAttachFile(new List<FileCreatorFromFlow.FileRequest>{request});
        Test.stopTest();

        // Verify no content version was created
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assertEquals(0, contentVersions.size(), 'No content version should have been created for invalid request');
    }
}