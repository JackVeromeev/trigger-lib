/**
 * @description Main Trigger Handler class.
 * You can use the class as base class or implement the event based interfaces separately.
 * Extend this class with your object handler.
 * Override `on[Before|After][Insert|Update|Delete|Undelete]` methods to inject the logic calls
 * In trigger use trigger for all events and call the `.run()` method
 * @author Yakau Verameyeu
 */
public abstract without sharing class TriggerHandler implements
		TriggerHandler.BeforeInsert,
		TriggerHandler.AfterInsert,
		TriggerHandler.BeforeUpdate,
		TriggerHandler.AfterUpdate,
		TriggerHandler.BeforeDelete,
		TriggerHandler.AfterDelete,
		TriggerHandler.AfterUndelete,
		TriggerHandler.DisableOption,
		TriggerHandler.WithIdentifier
{

	/// Disable data

	public static Boolean isDisableAllTriggers { get; private set;}
	private static Set<Schema.SObjectType> disabledObjects = new Set<Schema.SObjectType>();
	private static Set<Object> disabledIdentifiers = new Set<Object>();

	static {
		isDisableAllTriggers = false;
	}

	/// Run methods

	public static void run(Object handler, TriggerHandler.Context context) {
		if (TriggerHandler.isTriggerEnabled(handler, context)) {
			TriggerHandler.selectTriggerMethod(handler, context);
		}
	}

	// Static enable/disable manipulation on All Triggers. Quickest way to disable triggers

	public static Boolean enableAll() {
		Boolean previousValue = TriggerHandler.isDisableAllTriggers;
		TriggerHandler.isDisableAllTriggers = false;
		return previousValue;
	}

	public static Boolean disableAll() {
		Boolean previousValue = TriggerHandler.isDisableAllTriggers;
		TriggerHandler.isDisableAllTriggers = true;
		return previousValue;
	}

	public static Boolean setDisableAll(Boolean isDisabled) {
		Boolean previousValue = TriggerHandler.isDisableAllTriggers;
		TriggerHandler.isDisableAllTriggers = isDisabled;
		return previousValue;
	}

	// Static enable/disable by SObject Type

	public static Boolean enableByObject(Schema.SObjectType selectedObjectType) {
		return TriggerHandler.disabledObjects.remove(selectedObjectType);
	}

	public static Boolean disableByObject(Schema.SObjectType selectedObjectType) {
		return TriggerHandler.disabledObjects.add(selectedObjectType);
	}

	public static Boolean setDisableByObject(Schema.SObjectType selectedObjectType, Boolean isDisabled) {
		if (isDisabled) {
			return TriggerHandler.disabledObjects.add(selectedObjectType);
		}
		return TriggerHandler.disabledObjects.remove(selectedObjectType);
	}

	// Static enable/disable by Identifier. It could be either String, or Type or whatsoever


	public static Boolean enableByIdentifier(Object identifier) {
		return TriggerHandler.disabledIdentifiers.remove(identifier);
	}

	public static Boolean disableByIdentifier(Object identifier) {
		return TriggerHandler.disabledIdentifiers.add(identifier);
	}

	public static Boolean setDisableByIdentifier(Object identifier, Boolean isDisabled) {
		if (isDisabled) {
			return TriggerHandler.disabledIdentifiers.add(identifier);
		}
		return TriggerHandler.disabledIdentifiers.remove(identifier);
	}


	private static Boolean isTriggerEnabled(Object handler, TriggerHandler.Context context) {
		return (
			!TriggerHandler.isDisableAllTriggers &&
			(
				!(handler instanceOf TriggerHandler.DisableOption) ||
				!((TriggerHandler.DisableOption) handler).isDisabled()
			) &&
			(
				TriggerHandler.disabledObjects.isEmpty() ||
				!TriggerHandler.disabledObjects.contains(context.getRecordObjectType())
			) &&
			(
				TriggerHandler.disabledIdentifiers.isEmpty() ||
				!(handler instanceOf TriggerHandler.WithIdentifier) ||
				!TriggerHandler.disabledIdentifiers.contains(((TriggerHandler.WithIdentifier) handler).getIdentifier())
			)
		);
	}

	public static TriggerHandler.Context composeTriggerContext() {
		return new TriggerHandler.Context(
			Trigger.operationType,
			Trigger.new,
			Trigger.newMap,
			Trigger.old,
			Trigger.oldMap
		);
	}

	private static void selectTriggerMethod(Object handler, TriggerHandler.Context context) {
		switch on context.operation {
			when BEFORE_INSERT {
				if (handler instanceOf TriggerHandler.BeforeInsert) {
					((TriggerHandler.BeforeInsert) handler).onBeforeInsert(context.newList);
				}
			}
			when AFTER_INSERT {
				if (handler instanceOf TriggerHandler.AfterInsert) {
					((TriggerHandler.AfterInsert) handler).onAfterInsert(context.newList, context.newMap);
				}
			}
			when BEFORE_UPDATE {
				if (handler instanceOf TriggerHandler.BeforeUpdate) {
					((TriggerHandler.BeforeUpdate) handler).onBeforeUpdate(context.newList, context.newMap, context.oldList, context.oldMap);
				}
			}
			when AFTER_UPDATE {
				if (handler instanceOf TriggerHandler.AfterUpdate) {
					((TriggerHandler.AfterUpdate) handler).onAfterUpdate(context.newList, context.newMap, context.oldList, context.oldMap);
				}
			}
			when BEFORE_DELETE {
				if (handler instanceOf TriggerHandler.BeforeDelete) {
					((TriggerHandler.BeforeDelete) handler).onBeforeDelete(context.oldList, context.oldMap);
				}
			}
			when AFTER_DELETE {
				if (handler instanceOf TriggerHandler.AfterDelete) {
					((TriggerHandler.AfterDelete) handler).onAfterDelete(context.oldList, context.oldMap);
				}
			}
			when AFTER_UNDELETE {
				if (handler instanceOf TriggerHandler.AfterUndelete) {
					((TriggerHandler.AfterUndelete) handler).onAfterUndelete(context.newList, context.newMap);
				}
			}
		}
	}

	public virtual void run() {
		TriggerHandler.run(this, TriggerHandler.composeTriggerContext());
	}

	public virtual void run(TriggerHandler.Context context) {
		TriggerHandler.run(this, context);
	}

	/// Overridable logic methods

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public virtual void onBeforeInsert(List<SObject> newList) {}

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public virtual void onAfterInsert(List<SObject> newList, Map<Id, SObject> newMap) {}

	@SuppressWarnings('PMD.EmptyStatementBlock,PMD.ExcessiveParameterList')
	public virtual void onBeforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {}

	@SuppressWarnings('PMD.EmptyStatementBlock,PMD.ExcessiveParameterList')
	public virtual void onAfterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {}

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public virtual void onBeforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {}

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public virtual void onAfterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {}

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public virtual void onAfterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {}

	/**
	 * Disable overridable method, should return true if the handler must not be called
	 */
	public virtual Boolean isDisabled() {
		return false;
	}

	/**
	 * Should return identifier by which the Trigger Handler can be disabled
	 * @return  `Object`
	 */
	public virtual Object getIdentifier() {
		return null;
	}

	// private methods

	public interface BeforeInsert {
		void onBeforeInsert(List<SObject> newList);
	}

	public interface AfterInsert {
		void onAfterInsert(List<SObject> newList, Map<Id, SObject> newMap);
	}

	@SuppressWarnings('PMD.ExcessiveParameterList')
	public interface BeforeUpdate {
		void onBeforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap);
	}

	@SuppressWarnings('PMD.ExcessiveParameterList')
	public interface AfterUpdate {
		void onAfterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap);
	}

	public interface BeforeDelete {
		void onBeforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap);
	}

	public interface AfterDelete {
		void onAfterDelete(List<SObject> oldList, Map<Id, SObject> oldMap);
	}

	public interface AfterUndelete {
		void onAfterUndelete(List<SObject> newList, Map<Id, SObject> newMap);
	}

	public interface DisableOption {
		Boolean isDisabled();
	}

	public interface WithIdentifier {
		Object getIdentifier();
	}

	public class Context {
		public System.TriggerOperation operation;

		public List<SObject> newList { get; set; }
		public Map<Id, SObject> newMap { get; set; }

		public List<SObject> oldList { get; set; }
		public Map<Id, SObject> oldMap { get; set; }

		private Schema.SObjectType type;
		public Context(
			System.TriggerOperation operation,
			List<SObject> newList,
			Map<Id, SObject> newMap,
			List<SObject> oldList,
			Map<Id, SObject> oldMap
		) {
			this.operation = operation;
			this.newList = newList;
			this.newMap = newMap;
			this.oldList = oldList;
			this.oldMap = oldMap;
		}

		public Context(
			System.TriggerOperation operation,
			List<SObject> triggerList
		) {
			this(
				operation,
				(
					operation == TriggerOperation.BEFORE_DELETE ||
					operation == TriggerOperation.AFTER_DELETE
				) ? null : triggerList,
				(
					operation == TriggerOperation.BEFORE_DELETE ||
					operation == TriggerOperation.AFTER_DELETE ||
					operation == TriggerOperation.BEFORE_INSERT
				) ? null : new Map<Id, SObject>(triggerList),
				(
					operation == TriggerOperation.BEFORE_INSERT ||
					operation == TriggerOperation.AFTER_INSERT
				) ? null : triggerList,
				(
					operation == TriggerOperation.BEFORE_INSERT ||
					operation == TriggerOperation.AFTER_INSERT
				) ? null : new Map<Id, SObject>(triggerList)
			);
		}

		public Context(
			System.TriggerOperation operation,
			List<SObject> newList,
			List<SObject> oldList
		) {
			this(
				operation,
				newList,
				new Map<Id, SObject>(newList),
				oldList,
				new Map<Id, SObject>(oldList)
			);
		}

		public Context(
			System.TriggerOperation operation,
			List<SObject> newList,
			Map<Id, SObject> oldMap
		) {
			this(
				operation,
				newList,
				new Map<Id, SObject>(newList),
				oldMap.values(),
				oldMap
			);
		}

		public Context(
			System.TriggerOperation operation,
			SObject newRecord,
			SObject oldRecord
		) {
			this(
				operation,
				new List<SObject>{newRecord},
				new Map<Id, SObject>{newRecord.Id => newRecord},
				new List<SObject>{oldRecord},
				new Map<Id, SObject>{newRecord.Id => oldRecord}
			);
		}

		public Schema.SObjectType getRecordObjectType() {
			if (this.type == null) {
				if (this.newList != null && !this.newList.isEmpty()) {
					this.type = this.newList[0].getSObjectType();
				}
				if (this.type != null && this.oldList != null && !this.oldList.isEmpty()) {
					this.type = this.oldList[0].getSObjectType();
				}
			}
			return this.type;
		}
	}
}