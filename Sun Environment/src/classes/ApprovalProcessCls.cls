public with sharing class ApprovalProcessCls {

    //Propertied Declaration
     public string recid;
     public Boolean Show_Hide_ApprovalsButton{get;set;}
     public User usr {get;set;}
     public Boolean refreshPnl{get;set;}

    public ApprovalProcessCls(ApexPages.StandardController controller) {
           
        usr = new User();
        
        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =:recid AND Status='Pending'];
    }
        public String getUser() {
           return null;
        }
        
        public PageReference manualSubmitDRA() {
          List<Attachment> attchmntLst = [select id,parentid from Attachment where parentId=:recid];
          Deal_Risk_Assessment__c dra = [Select id, Link_to_Spreadsheet__c From Deal_Risk_Assessment__c Where id=:recid];
          if(dra!=null && (dra.Link_to_Spreadsheet__c == null || dra.Link_to_Spreadsheet__c == '') &&attchmntLst.size()<=1){
                Show_Hide_ApprovalsButton=true; 
                refreshPnl=false;                 
             return null;
          } else if(dra!=null && dra.Link_to_Spreadsheet__c != null && attchmntLst.size()==0){
              refreshPnl=true;
              Show_Hide_ApprovalsButton=false;
              return null;
          }
              refreshPnl=false;
              Show_Hide_ApprovalsButton=false;
              PageReference retval = null;
            try {
               if(Show_Hide_ApprovalsButton==false && refreshPnl==false){
                    Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
                    submitRequest.setObjectId(recid);
                    Approval.ProcessResult result = Approval.process(submitRequest);
                    System.Debug('Record ID### '+recid);
                    recid=ApexPages.CurrentPage().getParameters().get('id');
                    String apprvlid;          
                    ProcessInstance[] pi = [SELECT Id, Status,(SELECT Id, ActorId, OriginalActorId, StepStatus, Comments 
                                             FROM StepsAndWorkitems WHERE StepStatus IN('Pending')) 
                                              FROM ProcessInstance where TargetObjectID =:recid AND Status IN('Pending')];
               }
               
            }
            catch(Exception e) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));   
            }
            return null;
    }
}