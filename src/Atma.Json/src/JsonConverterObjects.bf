using System;
namespace Atma
{
	public class JsonObjectFactory : JsonObjectConverter<Object>
	{
		public override bool CanConvert(Type type)
		{
			if (type.IsObject && type.GetCustomAttribute<SerializableAttribute>() case .Ok)
				return true;
			return false;
		}

		protected override Object CreateObject(Type type)
		{
			if (type.CreateObject() case .Ok(let val))
				return val;

			return null;
		}
	}

	public abstract class JsonObjectConverter<T> : JsonConverter
		where T : class, delete
	{
		public override bool CanConvert(Type type) => typeof(T) == type;

		public override void WriteJson(JsonWriter writer, Type type, void* target)
		{
			var ptr = (T*)target;
			if (*ptr == null)
				writer.WriteRaw("null");
			else
				OnWriteJson(writer, type, ptr);
		}

		protected virtual void OnWriteJson(JsonWriter writer, Type type, T* target)
		{
			writer.WriteFields(type, Internal.UnsafeCastToPtr(*target));
		}

		protected abstract T CreateObject(Type type);// => new T();

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			var ptr = (T*)target;
			if (reader.Current.type == .Null)
			{
				if (*ptr != null)
				{
					delete target;
					*ptr = null;
				}
				reader.Next();
				return true;
			}

			bool created = false;
			if (*ptr == null)
			{
				*ptr = CreateObject(type);

				//failed to create object, should be rare
				if (*ptr == null)
					return false;

				created = true;
			}

			if (OnReadJson(reader, type, ptr))
				return true;

			if (created)
			{
				delete *ptr;
				*ptr = null;
			}
			return false;
		}

		protected virtual bool OnReadJson(JsonReader reader, Type type, T* target)
		{
			return reader.ReadFields(type, Internal.UnsafeCastToPtr(*target));
		}
	}

	public class JsonStringConverter : JsonObjectConverter<String>
	{
		protected override void OnWriteJson(JsonWriter writer, Type type, String* target)
		{
			writer.WriteString(*target);
		}

		protected override bool OnReadJson(JsonReader reader, Type type, String* target)
		{
			if (!reader.Expect(.String, let token))
				return false;

			if (*target == null)
				*target = new String(token.text.Length);

			token.GetString(*target);
			return true;
		}

		protected override String CreateObject(Type type) => new String();
	}
}
