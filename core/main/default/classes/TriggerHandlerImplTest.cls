public without sharing class TriggerHandlerImplTest extends TriggerHandler {
    public Integer beforeInsertCallTimes = 0;
    public Integer afterInsertCallTimes = 0;
    public Integer beforeUpdateCallTimes = 0;
    public Integer afterUpdateCallTimes = 0;
    public Integer beforeDeleteCallTimes = 0;
    public Integer afterDeleteCallTimes = 0;
    public Integer afterUndeleteCallTimes = 0;

    public List<SObject> capturedNewList;
    public List<SObject> capturedOldList;
    public Map<Id, SObject> capturedNewMap;
    public Map<Id, SObject> capturedOldMap;

    public String handlerIdentifier;

    public Boolean isCustomDisabled = false;

    public TriggerHandlerImplTest(String identifier) {
        this.handlerIdentifier = identifier;
    }

    public TriggerHandlerImplTest() {
        this(null);
    }

    public override Boolean isDisabled() {
        return isCustomDisabled;
    }

    public override void onBeforeInsert(List<SObject> newList) {
        this.beforeInsertCallTimes++;
        this.capturedNewList = newList;
    }

    public override void onAfterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
        this.afterInsertCallTimes++;
        this.capturedNewList = newList;
        this.capturedNewMap = newMap;
    }

    public override void onBeforeUpdate(
        List<SObject> newList,
        Map<Id, SObject> newMap,
        List<SObject> oldList,
        Map<Id, SObject> oldMap
    ) {
        this.beforeUpdateCallTimes++;
        this.capturedNewList = newList;
        this.capturedNewMap = newMap;
        this.capturedOldList = oldList;
        this.capturedOldMap = oldMap;
    }

    public override void onAfterUpdate(
        List<SObject> newList,
        Map<Id, SObject> newMap,
        List<SObject> oldList,
        Map<Id, SObject> oldMap
    ) {
        this.afterUpdateCallTimes++;
        this.capturedNewList = newList;
        this.capturedNewMap = newMap;
        this.capturedOldList = oldList;
        this.capturedOldMap = oldMap;
    }

    public override void onBeforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        this.beforeDeleteCallTimes++;
        this.capturedOldList = oldList;
        this.capturedOldMap = oldMap;
    }

    public override void onAfterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        this.afterDeleteCallTimes++;
        this.capturedOldList = oldList;
        this.capturedOldMap = oldMap;
    }

    public override void onAfterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
        this.afterUndeleteCallTimes++;
        this.capturedNewList = newList;
        this.capturedNewMap = newMap;
    }

    public override Object getIdentifier() {
        return this.handlerIdentifier;
    }
}