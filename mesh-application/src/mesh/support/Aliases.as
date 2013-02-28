package mesh.support
{
	import flash.events.Event;

	import mx.binding.utils.ChangeWatcher;

	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.Type;

	public class Aliases
	{
		private var _host:Object;
		private var _watchers:Array = [];

		public function Aliases(host:Object)
		{
			_host = host;
			initialize();
		}

		public function create(property:String, chain:String):ChangeWatcher
		{
			var watcher:ChangeWatcher = ChangeWatcher.watch(_host, chain.split("."), function(event:Event):void
			{
				_host[property] = watcher.getValue();
			});
			_watchers.push(watcher);
			return watcher;
		}

		private function initialize():void
		{
			for each (var property:Field in Type.forInstance(_host).properties) {
				if (FieldHelper.writeable(property) && property.hasMetadata("Alias")) {
					var metadata:Metadata = property.getMetadata("Alias")[0]
					create(property.name, metadata.getArgument("").value);
				}
			}
		}
	}
}
