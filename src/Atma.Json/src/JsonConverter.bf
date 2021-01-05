using System;
using System.Collections;
using System.Reflection;
namespace Atma
{
	public abstract class JsonConverter
	{
		public abstract bool CanConvert(Type type);

		public bool CanRead => true;
		public bool CanWrite => true;

		public abstract void WriteJson(JsonWriter writer, Type type, void* target);
		public abstract bool ReadJson(JsonReader reader, Type type, void* target);
	}

	public abstract class JsonConverter<T> : JsonConverter
		where T : var
	{
		private Type _type;

		public this() { _type = typeof(T); }

		public override bool CanConvert(Type type) => type == _type;

		public override void WriteJson(JsonWriter writer, Type type, void* target)
		{
			OnWriteJson(writer, type, (T*)target);
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			return OnReadJson(reader, type, (T*)target);
		}

		protected abstract void OnWriteJson(JsonWriter writer, Type type, T* target);
		protected abstract bool OnReadJson(JsonReader reader, Type type, T* target);
	}
}
