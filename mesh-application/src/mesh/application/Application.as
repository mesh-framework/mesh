package mesh.application
{
	import flash.events.EventDispatcher;

	public dynamic class Application extends EventDispatcher
	{
		public function Application()
		{
			super();
		}

		public function initialize(parameters:Object = null):void
		{
			_parameters = parameters || {};
		}

		private var _parameters:Object;
		public function get parameters():Object
		{
			return _parameters;
		}
	}
}
