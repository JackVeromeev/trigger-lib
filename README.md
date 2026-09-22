# Trigger Library

[![codecov](https://codecov.io/gh/JackVeromeev/trigger-lib/graph/badge.svg?token=QU6VT0TKCD)](https://codecov.io/gh/JackVeromeev/trigger-lib)

Inspired by existing Trigger Handler frameworks, built from scratch to meet my own design goals.

## Installation

Currently only manual mode is available: clone the repository and deploy the project to the org

## Features

### Simple and eloquent Trigger Handler classes

Simply extend the `TriggerHandler` for your object Trigger Handler and you can go. The base `TriggerHandler` class has a set of overridable methods for each Trigger event `on[Before|After][Event]`, e.g. `onBeforeInsert`. Each method comes with the parameters that are available for the chosen event

If your current architecture requires to extend another base class, you can use separate interfaces one per event. The interface names are `TriggerHandler.[Before|After][Event]`, `TriggerHandler.BeforeInsert`. The only difference is that your 

| Method | Interface | arguments |
|---|---|---|
| `onBeforeInsert` | `TriggerHandler.BeforeInsert` | `onBeforeInsert(List<SObject> newList)` |
| `onAfterInsert` | `TriggerHandler.AfterInsert` | `onAfterInsert(List<SObject> newList, Map<Id, SObject> newMap)` |
| `onBeforeUpdate` | `TriggerHandler.BeforeUpdate` | `onBeforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)` |
| `onAfterUpdate` | `TriggerHandler.AfterUpdate` | `onAfterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)` |
| `onBeforeDelete` | `TriggerHandler.BeforeDelete` | `onBeforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap)` |
| `onAfterDelete` | `TriggerHandler.AfterDelete` | `onAfterDelete(List<SObject> oldList, Map<Id, SObject> oldMap)` |
| `onAfterUndelete` | `TriggerHandler.AfterUndelete` | `onAfterUndelete(List<SObject> newList, Map<Id, SObject> newMap)` |

Example

1. Extension of `TriggerHandler`

    ```apex
    public class AccountTriggerHandler extends TriggerHandler {
        public override void onAfterInsert(List<Sobject> newList, Map<Id, SObject> newMap) {
            // business logic here
        }
    }

    trigger AccountTrigger on Account (before insert, after insert, ...) {
        AccountTriggerHandler.run();
    }
    ```

2. Implementation of separate interfaces

    ```apex
    public class AccountProcessor extends VeryEnterpriseProcessorBase implements TriggerHandler.AfterInsert {
        public override void onAfterInsert(List<Sobject> newList, Map<Id, SObject> newMap) {
            // business logic here
        }
    }

    trigger AccountTrigger on Account (before insert, after insert, ...) {
        TriggerHandler.run(new AccountProcessor(), TriggerHandler.composeTriggerContext());
    }
    ```

### Bypass mechanisms

#### Bypass all

Disable all trigger handlers for the current transaction with `TriggerHandler.disableAll();`. Enable them back with `TriggerHandler.enableAll();`

Use `TriggerHandler.setDisableAll(Boolean)` when the enabled state should be controlled by a variable.

All three methods return previous value of the disable state - `true` if disabled;

```apex
Boolean isDisabled = TriggerHandler.disableAll();
// logic that requires trigger disable
TriggerHandler.setDisableAll(previousState);
```

#### Bypass by object

Disable all handlers for a specific `Sobject` type by passing its `Schema.SObjectType`:

```apex
TriggerHandler.disableByObject(Account.SObjectType);

// Account handlers are skipped; handlers for other objects still run

TriggerHandler.enableByObject(Account.SObjectType);
```

Use `setDisableByObject(objectType, isDisabled)` to add or remove the object from the bypass list in one call.

#### Bypass by identifier

Handlers can override a `Object getIdentifier()` method to set a unique identifier. Identifier could be any type that could be stored in `Set<Object>`. Trigger can disable handlers with matching identifiers.

```apex
public override Object getIdentifier() {
    return 'AccountTriggerHandler';
}

TriggerHandler.disableByIdentifier('AccountTriggerHandler');

// Handlers with another identifier still run

TriggerHandler.enableByIdentifier('AccountTriggerHandler');
```

In general identifiers could repeat, in this case all handlers with matching identifier marked as disable will be bypassed.

## Roadmap

- Metadata driven handlers. Yes, the idea is inherited from Mitch'es Trigger Action Framework but purpose is to keep it simple stupid and as quick as possible without Formula filters and Finalizers.
- Installation links/packages