package mesh.support
{
	import org.as3commons.reflect.Accessor;
	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.Variable;

	public class FieldHelper
	{
		public static function writeable(field:Field):Boolean
		{
			return (field is Variable) || (field is Accessor && (field as Accessor).writeable);
		}

		public static function readable(field:Field):Boolean
		{
			return (field is Variable) || (field is Accessor && (field as Accessor).readable);
		}
	}
}
