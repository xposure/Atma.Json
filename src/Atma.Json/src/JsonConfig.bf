using System.Collections;
using System;
namespace Atma
{
	public static class JsonConfig
	{
		internal static List<JsonConverter> _converters = new .() ~ DeleteContainerAndItems!(_);

		static this()
		{
			_converters.Add(new JsonBoolConverter());
			_converters.Add(new JsonNumberConverter());
			_converters.Add(new JsonArrayConverter());
			_converters.Add(new JsonSizedArrayConverter());
			_converters.Add(new JsonStringConverter());
			_converters.Add(new JsonListConverter());

			//default converters for [SerializeAttribute]
			_converters.Add(new JsonStructFactory());
			_converters.Add(new JsonObjectFactory());
		}

		public static bool GetConverter(Type type, out JsonConverter converter)
		{
			for (var it in _converters)
				if (it.CanConvert(type))
				{
					converter = it;
					return true;
				}

			converter = null;
			return false;
		}

		public static void AddConverter(JsonConverter converter)
		{
			//custom converteres get inserted first
			_converters.Insert(0, converter);
		}
	}
}
