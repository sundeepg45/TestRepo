trigger DealRisk_After on Deal_Risk_Assessment__c (after delete, after insert, after undelete, after update) {
    System.Debug('Trigger after###');
    DealRiskTriggerAfter.processTrigger(Trigger.oldMap,Trigger.newMap);
}