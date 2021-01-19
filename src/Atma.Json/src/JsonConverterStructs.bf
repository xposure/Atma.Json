using System;
using System.Reflection;
using System.Collections;
namespace Atma
{
	public class JsonBoolConverter : JsonStructConverter<bool> 
	{
		protected override void OnWriteJson(JsonWriter writer, Type type, bool* target)
		{
			if (*target)
				writer.WriteRaw("true");
			else
				writer.WriteRaw("false");
		}

		protected override bool OnReadJson(JsonReader reader, Type type, bool* target)
		{
			*target = false;
			if (reader.Current.type == .Number)
			{
				if (reader.Current.text != "0")
					*target = true;
			}
			else if (reader.Current.type == .Bool)
			{
				if (StringView.Compare("true", reader.Current.text, true) == 0)
					*target = true;
			}
			else
				Runtime.FatalError(scope $"Expected true/false or a number for bool.");

			reader.Next();
			return true;
		}
	}

	public class JsonStructFactory : JsonStructConverter<void>
	{
		public override bool CanConvert(Type type)
		{
			let realType = this.[Friend]GetRealType(type);
			if (realType == null)
				return false;

			if (realType.GetCustomAttribute<SerializableAttribute>() case .Ok)
				return true;

			return false;
		}

		protected override void OnWriteJson(JsonWriter writer, Type type, void* target)
		{
			writer.WriteFields(type, target);
		}

		protected override bool OnReadJson(JsonReader reader, Type type, void* target)
		{
			return reader.ReadFields(type, target);
		}
	}

	public abstract class JsonStructConverter<T> : JsonConverter<T> where T : var
	{
		public override void WriteJson(JsonWriter writer, Type type, void* target)
		{
			if (type.IsPointer)
			{
				let p = *(T**)target;
				if (p == null)
					writer.WriteRaw("null");
				else
					OnWriteJson(writer, type, p);
			}
			else if (type.IsNullable)
			{
				let n = (Nullable<T>*)target;
				if (!n.HasValue)
				{
					writer.WriteRaw("null");
				}
				else
				{
					T t = n.Value;
					OnWriteJson(writer, type, &t);
				}
			}
			else
				OnWriteJson(writer, type, (T*)target);
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			if (type.IsPointer)
			{
				if (reader.Current.type == .Null)
				{
					delete (void*)*(T**)target;
					*(T**)target = null;
					reader.Next();
					return true;
				}
				else
				{
					var p = *(T**)target;
					if (p == null)
					{
						*(T**)target = new T[1]*;
						if (!OnReadJson(reader, type, *(T**)target))
						{
							delete (void*)*(T**)target;
							return false;
						}

						return true;
					}
					else
					{
						return OnReadJson(reader, type, *(T**)target);
					}
				}
			}
			else if (type.IsNullable)
			{
				let n = (Nullable<T>*)target;
				if (reader.Current.type == .Null)
				{
					*n = null;
					reader.Next();
					return true;
				}
				else
				{
					T t = ?;
					let result = OnReadJson(reader, type, &t);
					if (!result)
						return false;
					*n = t;
					return true;
				}
			}
			return OnReadJson(reader, type, (T*)target);
		}

		public override bool CanConvert(Type type)
		{
			let realType = GetRealType(type);
			if (realType == null)
				return false;

			return base.CanConvert(realType);
		}

		private Type GetRealType(Type type)
		{
			if (type.IsPointer)
			{
				let t = (PointerType)type;
				return t.UnderlyingType;
			}
			else if (type.IsValueType)
			{
				if (type.IsNullable)
				{
					let t = (SpecializedGenericType)type;
					return t.GetGenericArg(0);
				}

				return type;
			}
			return null;
		}
	}


	public class JsonNumberConverter : JsonConverter
	{
		public class JsonNumberConverter<T> : JsonStructConverter<T>
			where T : var, struct
		{
			public enum ParseType
			{
				Int,
				UInt,
				Float,
				Double,
			}

			private ParseType _parseType;
			public this(ParseType parseType)
			{
				_parseType = parseType;
			}

			protected override void OnWriteJson(JsonWriter writer, Type type, T* target)
			{
				let str = scope String();
				(*target).ToString(str);
				writer.WriteRaw(str);
			}

			protected override bool OnReadJson(JsonReader reader, Type type, T* target)
			{
				if (!reader.Expect(.Number, let token))
					return false;

				switch (_parseType) {
				case .Double:
					if (double.Parse(token.text) case .Ok(let val))
					{
						*target = (T)val;
						return true;
					}
				case .Float:
					if (float.Parse(token.text) case .Ok(let val))
					{
						*target = (T)val;
						return true;
					}
				case .Int:
					if (int64.Parse(token.text) case .Ok(let val))
					{
						*target = (T)val;
						return true;
					}
				case .UInt:
					if (uint64.Parse(token.text) case .Ok(let val))
					{
						*target = (T)val;
						return true;
					}
				}
				return false;
			}
		}

		private static List<JsonConverter> _converters = new .() ~ DeleteContainerAndItems!(_);

		static this()
		{
			_converters.Add(new JsonNumberConverter<uint8>(.UInt));
			_converters.Add(new JsonNumberConverter<uint16>(.UInt));
			_converters.Add(new JsonNumberConverter<uint32>(.UInt));
			_converters.Add(new JsonNumberConverter<uint64>(.UInt));
			_converters.Add(new JsonNumberConverter<uint>(.UInt));

			_converters.Add(new JsonNumberConverter<int8>(.Int));
			_converters.Add(new JsonNumberConverter<int16>(.Int));
			_converters.Add(new JsonNumberConverter<int32>(.Int));
			_converters.Add(new JsonNumberConverter<int64>(.Int));
			_converters.Add(new JsonNumberConverter<int>(.Int));

			_converters.Add(new JsonNumberConverter<float>(.Float));
			_converters.Add(new JsonNumberConverter<double>(.Double));
		}

		public override bool CanConvert(Type type)
		{
			for (var it in _converters)
				if (it.CanConvert(type))
					return true;

			return false;
		}

		public override void WriteJson(JsonWriter writer, Type type, void* target)
		{
			for (var it in _converters)
			{
				if (it.CanConvert(type))
				{
					it.WriteJson(writer, type, target);
					return;
				}
			}
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			for (var it in _converters)
				if (it.CanConvert(type))
					return it.ReadJson(reader, type, target);

			return false;
		}
	}
}
