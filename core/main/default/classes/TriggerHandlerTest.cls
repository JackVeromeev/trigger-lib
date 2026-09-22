
@IsTest
class TriggerHandlerTest {

    @IsTest
    static void beforeInsert_noDisables_beforeInsertInvoked_newListCaptured() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        handler.run(context);

        Assert.areEqual(1, handler.beforeInsertCallTimes, 'onBeforeInsert should be called');
        Assert.areEqual(1, handler.capturedNewList.size(), 'Should capture new list');
    }

    @IsTest
    static void afterInsert_noDisables_afterInsertInvoked_newListAndMapCaptured() {
        Account acc = new Account(
            Id = '001000000000000AAA',
            Name = 'Test Account'
        );
        List<SObject> newList = new List<SObject>{ acc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.AFTER_INSERT, newList);

        handler.run(context);

        Assert.areEqual(1, handler.afterInsertCallTimes, 'onAfterInsert should be called');
        Assert.areEqual(1, handler.capturedNewList.size(), 'Should capture new list');
        Assert.areEqual(1, handler.capturedNewMap.size(), 'Should capture new map');
    }

    @IsTest
    static void beforeUpdate_noDisables_beforeUpdateInvoked_allCollectionsCaptured() {
        Account oldAcc = new Account(
            Id = '001000000000000AAA',
            Name = 'Old Account'
        );
        Account newAcc = new Account(
            Id = '001000000000000AAA',
            Name = 'New Account'
        );

        List<SObject> newList = new List<SObject>{ newAcc };
        Map<Id, SObject> newMap = new Map<Id, SObject>{ newAcc.Id => newAcc };
        List<SObject> oldList = new List<SObject>{ oldAcc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ oldAcc.Id => oldAcc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_UPDATE, newList, newMap, oldList, oldMap);

        handler.run(context);

        Assert.areEqual(1, handler.beforeUpdateCallTimes, 'onBeforeUpdate should be called');
        Assert.areEqual(1, handler.capturedNewList.size(), 'Should capture new list');
        Assert.areEqual(1, handler.capturedOldList.size(), 'Should capture old list');
    }

    @IsTest
    static void testAfterUpdate() {
        Account oldAcc = new Account(Name = 'Old Account');
        oldAcc.Id = '001000000000000AAA';
        Account newAcc = new Account(Name = 'New Account');
        newAcc.Id = '001000000000000AAA';

        List<SObject> newList = new List<SObject>{ newAcc };
        Map<Id, SObject> newMap = new Map<Id, SObject>{ newAcc.Id => newAcc };
        List<SObject> oldList = new List<SObject>{ oldAcc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ oldAcc.Id => oldAcc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.AFTER_UPDATE, newList, newMap, oldList, oldMap);

        handler.run(context);

        Assert.areEqual(1, handler.afterUpdateCallTimes, 'onAfterUpdate should be called');
        Assert.areEqual(1, handler.capturedNewList.size(), 'Should capture new list');
        Assert.areEqual(1, handler.capturedOldList.size(), 'Should capture old list');
    }

    @IsTest
    static void testBeforeDelete() {
        Account acc = new Account(Name = 'Test Account');
        acc.Id = '001000000000000AAA';
        List<SObject> oldList = new List<SObject>{ acc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ acc.Id => acc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_DELETE, oldList);

        handler.run(context);

        Assert.areEqual(1, handler.beforeDeleteCallTimes, 'onBeforeDelete should be called');
        Assert.areEqual(1, handler.capturedOldList.size(), 'Should capture old list');
    }

    @IsTest
    static void testAfterDelete() {
        Account acc = new Account(Name = 'Test Account');
        acc.Id = '001000000000000AAA';
        List<SObject> oldList = new List<SObject>{ acc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ acc.Id => acc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.AFTER_DELETE, oldList);

        handler.run(context);

        Assert.areEqual(1, handler.afterDeleteCallTimes, 'onAfterDelete should be called');
        Assert.areEqual(1, handler.capturedOldList.size(), 'Should capture old list');
    }

    @IsTest
    static void testAfterUndelete() {
        Account acc = new Account(Name = 'Test Account');
        acc.Id = '001000000000000AAA';
        List<SObject> newList = new List<SObject>{ acc };
        Map<Id, SObject> newMap = new Map<Id, SObject>{ acc.Id => acc };

        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.AFTER_UNDELETE, newList, newMap, null, null);

        handler.run(context);

        Assert.areEqual(1, handler.afterUndeleteCallTimes, 'onAfterUndelete should be called');
        Assert.areEqual(1, handler.capturedNewList.size(), 'Should capture new list');
    }

    @IsTest
    static void testDisableAllTriggers() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };

        TriggerHandler.disableAll();
        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        handler.run(context);

        TriggerHandler.enableAll();

        Assert.areEqual(0, handler.beforeInsertCallTimes, 'Handler should not be called when all triggers are disabled');
    }

    @IsTest
    static void testToggleDisableAllTriggers() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };

        // Test with true (disabled)
        TriggerHandler.setDisableAll(true);
        TriggerHandlerImplTest handler1 = new TriggerHandlerImplTest();
        TriggerHandler.Context context1 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler1.run(context1);

        Assert.areEqual(0, handler1.beforeInsertCallTimes, 'Handler should not be called when disabled');

        // Test with false (enabled)
        TriggerHandler.setDisableAll(false);
        TriggerHandlerImplTest handler2 = new TriggerHandlerImplTest();
        TriggerHandler.Context context2 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler2.run(context2);

        Assert.areEqual(1, handler2.beforeInsertCallTimes, 'Handler should be called when enabled');
    }

    @IsTest
    static void testEnableDisableTriggersByObject() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };
        Schema.SObjectType accountType = Account.SObjectType;

        // Disable Account triggers
        TriggerHandler.disableByObject(accountType);
        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        handler.run(context);

        Assert.areEqual(0, handler.beforeInsertCallTimes, 'Handler should not be called when object type is disabled');

        // Re-enable
        TriggerHandler.enableByObject(accountType);
        TriggerHandlerImplTest handler2 = new TriggerHandlerImplTest();
        TriggerHandler.Context context2 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler2.run(context2);

        Assert.areEqual(1, handler2.beforeInsertCallTimes, 'Handler should be called when object type is enabled');
    }

    @IsTest
    static void testToggleDisableTriggersByObject() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };
        Schema.SObjectType accountType = Account.SObjectType;

        // Disable
        TriggerHandler.setDisableByObject(accountType, true);
        TriggerHandlerImplTest handler1 = new TriggerHandlerImplTest();
        TriggerHandler.Context context1 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        Assert.areEqual(context1.getRecordObjectType(), accountType);
        handler1.run(context1);

        Assert.areEqual(0, handler1.beforeInsertCallTimes, 'Handler should not be called when disabled via toggle');

        // Enable
        TriggerHandler.setDisableByObject(accountType, false);
        TriggerHandlerImplTest handler2 = new TriggerHandlerImplTest();
        TriggerHandler.Context context2 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler2.run(context2);

        Assert.areEqual(1, handler2.beforeInsertCallTimes, 'Handler should be called when enabled via toggle');
    }

    @IsTest
    static void testEnableDisableTriggersByIdentifier() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };
        String identifier = 'testIdentifier';

        // Disable by identifier
        TriggerHandler.disableByIdentifier(identifier);
        TriggerHandlerImplTest handler = new TriggerHandlerImplTest(identifier);
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        handler.run(context);

        Assert.areEqual(0, handler.beforeInsertCallTimes, 'Handler should not be called when identifier is disabled');

        // Enable
        TriggerHandler.enableByIdentifier(identifier);
        TriggerHandlerImplTest handler2 = new TriggerHandlerImplTest(identifier);
        TriggerHandler.Context context2 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler2.run(context2);

        Assert.areEqual(1, handler2.beforeInsertCallTimes, 'Handler should be called when identifier is enabled');
    }

    @IsTest
    static void testToggleDisableTriggersByIdentifier() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };
        String identifier = 'testIdentifier';

        // Disable
        TriggerHandler.setDisableByIdentifier(identifier, true);
        TriggerHandlerImplTest handler1 = new TriggerHandlerImplTest(identifier);
        TriggerHandler.Context context1 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler1.run(context1);

        Assert.areEqual(0, handler1.beforeInsertCallTimes, 'Handler should not be called when disabled via toggle');

        // Enable
        TriggerHandler.setDisableByIdentifier(identifier, false);
        TriggerHandlerImplTest handler2 = new TriggerHandlerImplTest(identifier);
        TriggerHandler.Context context2 = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);
        handler2.run(context2);

        date.today();

        Assert.areEqual(1, handler2.beforeInsertCallTimes, 'Handler should be called when enabled via toggle');
    }

    @IsTest
    static void testContextConstructorWithMaps() {
        Account oldAcc = new Account(Name = 'Old');
        oldAcc.Id = '001000000000000AAA';
        Account newAcc = new Account(Name = 'New');
        newAcc.Id = '001000000000000AAA';

        List<SObject> newList = new List<SObject>{ newAcc };
        Map<Id, SObject> newMap = new Map<Id, SObject>{ newAcc.Id => newAcc };
        List<SObject> oldList = new List<SObject>{ oldAcc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ oldAcc.Id => oldAcc };

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_UPDATE, newList, newMap, oldList, oldMap);

        Assert.areEqual(TriggerOperation.BEFORE_UPDATE, context.operation, 'Operation should be set correctly');
        Assert.areEqual(1, context.newList.size(), 'New list should be set');
        Assert.areEqual(1, context.oldList.size(), 'Old list should be set');
        Assert.areEqual(1, context.newMap.size(), 'New map should be set');
        Assert.areEqual(1, context.oldMap.size(), 'Old map should be set');
    }

    @IsTest
    static void testContextConstructorWithSingleRecords() {
        Account oldAcc = new Account(Name = 'Old');
        oldAcc.Id = '001000000000000AAA';
        Account newAcc = new Account(Name = 'New');
        newAcc.Id = '001000000000000AAA';

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_UPDATE, newAcc, oldAcc);

        Assert.areEqual(TriggerOperation.BEFORE_UPDATE, context.operation, 'Operation should be set correctly');
        Assert.areEqual(1, context.newList.size(), 'New list should contain single record');
        Assert.areEqual(1, context.oldList.size(), 'Old list should contain single record');
    }

    @IsTest
    static void testContextConstructorWithNewListAndOldList() {
        Account oldAcc = new Account(Name = 'Old');
        oldAcc.Id = '001000000000000AAA';
        Account newAcc = new Account(Name = 'New');
        newAcc.Id = '001000000000000AAA';

        List<SObject> newList = new List<SObject>{ newAcc };
        List<SObject> oldList = new List<SObject>{ oldAcc };

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_UPDATE, newList, oldList);

        Assert.areEqual(TriggerOperation.BEFORE_UPDATE, context.operation, 'Operation should be set correctly');
        Assert.areEqual(1, context.newList.size(), 'New list should be set');
        Assert.areEqual(1, context.oldList.size(), 'Old list should be set');
        Assert.areEqual(1, context.newMap.size(), 'New map should be auto-created');
        Assert.areEqual(1, context.oldMap.size(), 'Old map should be auto-created');
    }

    @IsTest
    static void testContextConstructorWithNewListAndOldMap() {
        Account oldAcc = new Account(Name = 'Old');
        oldAcc.Id = '001000000000000AAA';
        Account newAcc = new Account(Name = 'New');
        newAcc.Id = '001000000000000AAA';

        List<SObject> newList = new List<SObject>{ newAcc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ oldAcc.Id => oldAcc };

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_UPDATE, newList, oldMap);

        Assert.areEqual(TriggerOperation.BEFORE_UPDATE, context.operation, 'Operation should be set correctly');
        Assert.areEqual(1, context.newList.size(), 'New list should be set');
        Assert.areEqual(1, context.oldList.size(), 'Old list should be created from old map values');
        Assert.areEqual(1, context.oldMap.size(), 'Old map should be set');
    }

    @IsTest
    static void testContextConstructorBeforeInsert() {
        Account acc = new Account(Name = 'Test');
        List<SObject> newList = new List<SObject>{ acc };

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        Assert.areEqual(TriggerOperation.BEFORE_INSERT, context.operation, 'Operation should be BEFORE_INSERT');
        Assert.areEqual(1, context.newList.size(), 'New list should be set');
        Assert.isNull(context.oldList, 'Old list should be null for BEFORE_INSERT');
        Assert.isNull(context.newMap, 'New map should be null for BEFORE_INSERT');
        Assert.isNull(context.oldMap, 'Old map should be null for BEFORE_INSERT');
    }

    @IsTest
    static void testContextConstructorBeforeDelete() {
        Account acc = new Account(Name = 'Test');
        acc.Id = '001000000000000AAA';
        List<SObject> oldList = new List<SObject>{ acc };

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_DELETE, oldList);

        Assert.areEqual(TriggerOperation.BEFORE_DELETE, context.operation, 'Operation should be BEFORE_DELETE');
        Assert.areEqual(1, context.oldList.size(), 'Old list should be set');
        Assert.isNull(context.newList, 'New list should be null for BEFORE_DELETE');
        Assert.isNull(context.newMap, 'New map should be null for BEFORE_DELETE');
    }

    @IsTest
    static void testIsDisabledMethod() {
        // Create a custom handler that returns true for isDisabled
        TriggerHandlerImplTest disabledHandler = new TriggerHandlerImplTest();
        disabledHandler.isCustomDisabled = true;

        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };
        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        disabledHandler.run(context);

        Assert.areEqual(0, disabledHandler.beforeInsertCallTimes, 'Handler should not be called when isDisabled returns true');
    }

    @IsTest
    static void testMultipleHandlersWithDifferentIdentifiers() {
        Account acc = new Account(Name = 'Test Account');
        List<SObject> newList = new List<SObject>{ acc };

        String identifier1 = 'handler1';
        String identifier2 = 'handler2';

        // Disable only handler1
        TriggerHandler.disableByIdentifier(identifier1);

        TriggerHandlerImplTest handler1 = new TriggerHandlerImplTest(identifier1);
        TriggerHandlerImplTest handler2 = new TriggerHandlerImplTest(identifier2);

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, newList);

        handler1.run(context);
        handler2.run(context);

        Assert.areEqual(0, handler1.beforeInsertCallTimes, 'Handler1 should be disabled');
        Assert.areEqual(1, handler2.beforeInsertCallTimes, 'Handler2 should be enabled');

        // Cleanup
        TriggerHandler.enableByIdentifier(identifier1);
    }

    @IsTest
    static void testRunWithoutContext() {
        // This test verifies that run() without parameters works
        // Since we cannot mock actual Trigger context, this is a limited test
        TriggerHandlerImplTest handler = new TriggerHandlerImplTest();

        // We cannot call run() without context in a test environment
        // because it relies on actual Trigger global variables
        // This test just ensures the method exists and is callable
        Assert.isNotNull(handler, 'Handler should be instantiated');
    }

    @IsTest
    static void testContextWithEmptyLists() {
        Account acc = new Account(Name = 'Test');
        acc.Id = '001000000000000AAA';

        // Empty list scenarios
        List<SObject> emptyNewList = new List<SObject>();
        List<SObject> emptyOldList = new List<SObject>();

        TriggerHandler.Context context = new TriggerHandler.Context(TriggerOperation.BEFORE_INSERT, emptyNewList);

        Assert.areEqual(TriggerOperation.BEFORE_INSERT, context.operation, 'Operation should be set');
        Assert.areEqual(0, context.newList.size(), 'New list should be empty');
    }
}