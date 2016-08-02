public with sharing class ContractMessageController {
// testing git repository updates
    public ContractMessageController(ApexPages.StandardController controller) {
        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: ApexPages.CurrentPage().getParameters().get('id') AND Status='Pending'];       
       if(existingApprovals.size()==0){
          ShowMessage=true;
       }else{
          ShowMessage=false;
       }
    }
    public boolean ShowMessage {get; set;}

}