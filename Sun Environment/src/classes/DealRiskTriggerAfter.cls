/**
 * This class replaces all after insert and after update Deal Risk triggers.  The
 * processTrigger method is invoked by the DealRisk_After trigger and in turn invokes
 * all the methods of this class.  This gives us a way to control the order in
 * which the code logic is invoked, as well as allowing other class features such
 * as shared data, constant values, and rigorous test coverage.
 * <p>
 * The Trigger object should never be directly referenced inside this class, as
 * that would make it impossible to substituting values inside test methods.
 * </p>
 *
 * @version 2016-06-08
 * @author Sundeep Godishala <sgodisha@redhat.com>
 * @since 2016-06-08 - Created a method to post a message on chatter for Deal Risk Approvals (only for EMEA)
 */
 
 public without sharing class DealRiskTriggerAfter extends AbstractTrigger {
      /** BooleanSetting__c key to enable chatterApprovalEmea */
    public static final String CHATTER_APPROVAL_EMEA = 'DealRisk_After.chatterApprovalEmea';
    
    private final Map<Id,Deal_Risk_Assessment__c> oldMap = new Map<Id,Deal_Risk_Assessment__c>();
    private final Map<Id,Deal_Risk_Assessment__c> newMap = new Map<Id,Deal_Risk_Assessment__c>();

  /**
     * This our standard constructor for an after trigger.
     * @param xoldMap the mapping of old values
     * @param xnewMap the mapping of new values
     */
    public DealRiskTriggerAfter(Map<Id,Deal_Risk_Assessment__c> xoldMap,Map<Id,Deal_Risk_Assessment__c> xnewMap) {
        super(xoldMap,null,xnewMap);
        if(xoldMap != null) {
            oldMap.putAll(xoldMap);
        }
        if(xnewMap != null) {
            newMap.putAll(xnewMap);
        }
    }
    
        public void chatterApprovalEmea(){
         Set<Id> DealRiskIds = new Set<Id>(); 
            for(Deal_Risk_Assessment__c newDealRiskAssessment : newMap.values()) {
             if((newDealRiskAssessment.Approval_Step_2__c == True || 
                  newDealRiskAssessment.Approval_Step_3__c == True || 
                  newDealRiskAssessment.Approval_Step_4__c == True) && newDealRiskAssessment.Super_Region__c == 'EMEA') {
                DealRiskIds.add(newDealRiskAssessment.id);
                }
            }   
         System.Debug(' Deal RiskIds###'+DealRiskIds);
         ProcessInstance[] pi = [Select ID, Status,TargetObject.Name, (SELECT Id, ActorId,Actor.name,ProcessInstanceId FROM Workitems),
                                  (SELECT Id,StepStatus, Comments,Actor.Name,ActorId FROM Steps where StepStatus='Pending') 
                                  From ProcessInstance Where TargetObjectID IN: DealRiskIds];
           Set<Id> aprvrids = new Set<Id>();
           for(ProcessInstance instance:pi){         
                for(ProcessInstanceWorkItem workItem:instance.Workitems){
                     aprvrids.add(workItem.ActorId);
                }
           } 
           System.Debug('Process Instance###'+pi.size()+' ApproverIds###'+aprvrids.size());
           if(aprvrids.size()>0){
               List<User> users = new List<User>();
                for(Id userId : aprvrids) {
                   users.add(new User(Id = userId));
                }            
             for(Deal_Risk_Assessment__c newDealRiskAssessment : newMap.values()) {   
              if((newDealRiskAssessment.Approval_Step_2__c == True || 
              newDealRiskAssessment.Approval_Step_3__c == True || 
              newDealRiskAssessment.Approval_Step_4__c == True) &&
              newDealRiskAssessment.Super_Region__c == 'EMEA'){
                String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                String msg='Approval process initiated for the record, '+salesforceHost+'/'+newDealRiskAssessment.id;       
                 postChatterMessage(newDealRiskAssessment.id, msg, aprvrids, UserInfo.getSessionId());  
               }            
             } 
          }      
        }
        
       @future(callout=true)
       private static void postChatterMessage(Id oppId, String message, Set<Id> mentionIds, String sessionId) {
            List<User> users = new List<User>();
            for(Id userId : mentionIds) {
                users.add(new User(Id = userId));
            }
            ChatterUtil.postMessage(oppId, message, users, sessionId);
        }
        
        public static void processTrigger(Map<Id,Deal_Risk_Assessment__c> xoldMap,Map<Id,Deal_Risk_Assessment__c> xnewMap) {
        try {
            final DealRiskTriggerAfter afterTrigger = new DealRiskTriggerAfter(xoldMap,xnewMap);
            if(AbstractTrigger.isActive(CHATTER_APPROVAL_EMEA,true)) {
                afterTrigger.chatterApprovalEmea();
            }
        }
        finally {
            AbstractTrigger.processTriggerComplete();
        }
       }
 }