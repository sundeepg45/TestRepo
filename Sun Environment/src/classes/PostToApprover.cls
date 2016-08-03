Public class PostToApprover {
    @InvocableMethod
    public static void postToApprover(list<string> params) {
        
        //Fetch the Deal Risk Record
        Deal_Risk_Assessment__c dra = [Select Id, Name, Contract__c, Super_region__c From Deal_Risk_Assessment__c Where id = :params[0] And Super_Region__c = 'EMEA'];
    }
}