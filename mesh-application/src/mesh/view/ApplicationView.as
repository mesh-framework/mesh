package mesh.view
{
	import flash.events.Event;

	import mesh.application.Application;
	import mesh.controllers.Controller;
	import mesh.support.FieldHelper;

	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.Type;

	public class ApplicationView extends View
	{
		private var _application:Application;
		public function get application():Application
		{
			if (_application == null) {
				_application = createApplication();
			}
			return _application;
		}

		public function ApplicationView()
		{
			super();
			addEventListener(Event.ADDED, handleAdded);
		}

		private function handleAdded(event:Event):void
		{
			if (event.target != this && event.target is IView) {
				setupView(event.target as IView);
			}
		}

		private function setupView(view:IView):void
		{
			// Populate the application property on the view and its controllers.
			var type:Type = Type.forInstance(view);
			for each (var field:Field in type.fields) {
				if (field.name == "application") {
					view[field.name] = application;
				}

				if (FieldHelper.readable(field)) {
					var value:Object = view[field.name];
					if (value is Controller && "application" in value) {
						value.application = application;
					}
				}
			}
		}

		protected function createApplication():Application
		{
			throw new Error("ApplicationView.createApplication() is not implemented.")
		}

		override public function initialize():void
		{
			super.initialize();
			application.initialize();
		}
	}
}
