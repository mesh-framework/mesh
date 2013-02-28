package mesh.controllers
{
	import mx.collections.ArrayList;
	import mx.collections.IList;

	import org.as3commons.reflect.Type;

	public class ListController extends Controller implements IList
	{
		private var _list:IList;

		/**
		 * @inheritDoc
		 */
		override public function set data(value:Object):void
		{
			value = value is Array ? new ArrayList(value as Array) : value;

			if (value is IList) {
				_list = value as IList;
			} else {
				throw new ArgumentError("Expected an 'mx.collections.IList' but got a '" + Type.forInstance(value).fullName + "'");
			}

			super.data = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return _list.length;
		}

		/**
		 * Constructor.
		 */
		public function ListController()
		{
			super();
		}

		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			_list.addItem(item);
		}

		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			_list.addItemAt(item, index);
		}

		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _list.getItemAt(index, prefetch);
		}

		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _list.getItemIndex(item);
		}

		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_list.itemUpdated(item, property, oldValue, newValue);
		}

		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			_list.removeAll();
		}

		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			return _list.removeItemAt(index);
		}

		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return _list.setItemAt(item, index);
		}

		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return _list.toArray();
		}
	}
}
