package mesh.view
{
	import flash.events.Event;

	import mesh.support.Aliases;

	import mx.binding.utils.ChangeWatcher;

	import org.as3commons.reflect.Type;

	import spark.components.supportClasses.SkinnableComponent;

	public class View extends SkinnableComponent implements IView
	{
		private var _aliases:Aliases;

		private var _currentSkinState:String;
		protected function get currentSkinState():String
		{
			return _currentSkinState;
		}
		protected function set currentSkinState(value:String):void
		{
			if (_currentSkinState != value) {
				_currentSkinState = value;
				invalidateSkinState();
			}
		}

		/**
		 * Constructor.
		 */
		public function View()
		{
			super();
			_aliases = new Aliases(this);
		}

		private var _statements:Array = [];
		/**
		 * A utility method that allows you to bind data defined on this view to a skin part. This
		 * method lets you easily bind and set data on a skin part without having to override the
		 * <code>partAdded()</code> method.
		 *
		 * <p>
		 * The skin part, its property, and the data to bind to it are defined using a statement
		 * that mimics AS3's dot syntax, such as: <code>bindSkinPartToData(mySkinPart.title, data.title)</code>.
		 * </p>
		 *
		 * <p>
		 * You may also pass in a <code>block</code> function with the following signature:
		 * <code>function(fromValue:Object):Object</code>. This function is passed the value from
		 * <code>from</code>, and the skin part's data is set to the function's result.
		 * </p>
		 *
		 * <p>
		 * The skin part, and the bound data are assumed to belong to the view and must be public.
		 * Binding to private or protected data will throw an error.
		 * </p>
		 *
		 * @param to The skin part and its property to bind to.
		 * @param from The data hosted on this view to bind from.
		 * @param block An optional function that's result is passed to the skin part.
		 */
		protected function bind(to:String, from:String, block:Function = null):void
		{
			var skinParts:Array = to.split(".");
			var partName:String = skinParts[0];
			var property:String = skinParts[skinParts.length > 1 ? 1 : 0];

			var host:Object = this;
			var watcher:ChangeWatcher = ChangeWatcher.watch(host, from.split("."), null);
			var handler:Function = function(event:* = null):void
			{
				var value:Object = block != null ? block(watcher.getValue()) : watcher.getValue();

				// This is a property chain.
				if (skinParts.length > 1) {
					if (host[partName] != null) {
						host[partName][property] = value;
					}
				} else {
					host[property] = value;
				}
			};
			watcher.setHandler(handler);

			_statements.push({partName:partName, watcher:watcher, handler:handler});
		}

		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			return currentSkinState;
		}

		private var _deferredActions:Array = [];
		/**
		 * Adds an event listener to an object.
		 *
		 * @example Using <code>on()</code>.
		 * on("button", MouseEvent.CLICK, function():void
		 * {
		 *  trace("button clicked.");
		 * });
		 * </listing>
		 *
		 * @param host The object to add the event listener to.
		 * @param event The event name to listen for.
		 * @param handler A function invoked when the event is dispatched.
		 */
		protected function on(host:Object, event:String, handler:Function):void
		{
			var action:Action = new Action(this, host, event, handler);
			if (action.canAttach) {
				action.attach();
			} else {
				_deferredActions.push(action);
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);

			for each (var action:Action in _deferredActions) {
				if (action.partName == partName) {
					action.attach();
				}
			}

			for each (var statement:Object in _statements) {
				if (statement.partName == partName) {
					statement.handler();
				}
			}
		}

		/**
		 * Listens to a property chain for changes. When the property is updated, a handler function
		 * is invoked with the property's new value.
		 *
		 * @example Adding a watcher.
		 * <listing version="3.0">
		 * watch("data.email", function(email:String):void
		 * {
		 *  trace("new email: " + email);
		 * }
		 * </listing>
		 *
		 * @example By using an options object, you can change the host of the property chain. This is
		 *  useful for watching private objects belonging to the view.
		 * <listing version="3.0">
		 * watch({
		 *  host: this,
		 *  chain: "data.email",
		 *  handler: function(email:String):void
		 *  {
		 *      trace("new email: " + email);
		 *  }
		 * });
		 * </listing>
		 *
		 * @param chainOrOptions The property chain to watch, or a set of options.
		 * @param handler The function that will be called when the property changes.
		 * @return A change watcher.
		 */
		protected function watch(chainOrOptions:Object, handler:Function = null):ChangeWatcher
		{
			if (chainOrOptions is String) {
				return watch({
					host: this,
					chain: chainOrOptions,
					handler: handler
				});
			}

			var watcher:ChangeWatcher = ChangeWatcher.watch(chainOrOptions.host, chainOrOptions.chain.split("."), function(event:Event):void
			{
				chainOrOptions.handler(watcher.getValue());
			});
			return watcher;
		}

		private var _reflect:Type;
		public function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.forInstance(this);
			}
			return _reflect;
		}
	}
}

import flash.events.Event;
import flash.events.IEventDispatcher;

import mesh.view.View;

class Action
{
	private var _view:View;
	private var _host:Object;
	private var _event:String;
	private var _handler:Function;

	public function Action(view:View, host:Object, event:String, handler:Function)
	{
		_view = view;
		_host = host;
		_event = event;
		_handler = handler;
	}

	public function attach():void
	{
		if (canAttach) {
			(host as IEventDispatcher).addEventListener(_event, function(event:Event):void
			{
				_handler();
			});
		}
	}

	private function getPath(host:Object, path:String):Object
	{
		var result:Object = host;
		for each (var p:String in path.split(".")) {
			result = result[p];
		}
		return result;
	}

	public function get canAttach():Boolean
	{
		return host != null;
	}

	private function get host():Object
	{
		return _host is String ? getPath(_view, _host.toString()) : _host
	}

	public function get partName():String
	{
		return _host is String ? _host.split(".").pop() : "";
	}
}
