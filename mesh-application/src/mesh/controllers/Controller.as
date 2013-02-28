package mesh.controllers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	import mesh.application.Application;
	import mesh.support.Aliases;
	import mesh.support.FieldHelper;

	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;

	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.Type;

	use namespace flash_proxy;

	[Bindable("propertyChange")]
	public class Controller extends Proxy implements IEventDispatcher
	{
		private var _aliases:Aliases;
		private var _dispatcher:EventDispatcher;

		private var _data:Object;
		[Bindable]
		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			if (data != value) {
				if (_data != null) _data.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
				_data = value;
				if (_data != null) _data.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
				dispatchPropertyChangeEvents();
			}
		}

		private var _reflect:Type;
		public function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.forInstance(this);
			}
			return _reflect;
		}

		/**
		 * Constructor.
		 */
		public function Controller()
		{
			super();
			_dispatcher = new EventDispatcher(this);
			_aliases = new Aliases(this);
		}

		private function dispatchPropertyChangeEvents():void
		{
			for each (var field:Field in Type.forInstance(this).properties) {
				var events:Object = ChangeWatcher.getEvents(this, field.name);
				for (var event:String in events) {
					dispatchEvent( new Event(event) );
				}
			}
		}

		private function handlePropertyChange(event:PropertyChangeEvent):void
		{
			dispatchEvent(event);
		}

		public function initialize(application:Application):void
		{
			// Populate the Application field.
			for each (var property:Field in reflect.properties) {
				if (FieldHelper.writeable(property) && property.hasMetadata("Application")) {
					this[property.name] = application;
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return data ? data[name.toString()] : null;
		}

		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return data ? data.hasOwnProperty(name.toString()) : false;
		}

		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (data) {
				data[name.toString()] = value;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}

		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}

		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}
