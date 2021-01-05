using System;
using System.Reflection;
namespace Atma
{
	public class JsonArrayConverter : JsonConverter
	{
		public override bool CanConvert(Type type)
		{
			if (type.IsArray)
				return true;

			return false;
		}

		public override void WriteJson(JsonWriter writer, Type type, void* target)
		{
			var obj = Internal.UnsafeCastToObject(*(void**)target);
			if (obj == null)
			{
				writer.WriteRaw("null");
			}
			else
			{
				let arrayType = (ArrayType)type;
				let genericType = arrayType.GetGenericArg(0);
				let array = (Array)obj;
				var ptr = ((uint8*)Internal.UnsafeCastToPtr(obj) + type.InstanceSize - genericType.Size);
				writer.WriteArrayStart();
				for (var i < array.Count)
				{
					writer.WriteComma();
					writer.WriteValue(genericType, ptr);
					ptr += genericType.InstanceStride;
				}
				writer.WriteArrayEnd();
			}
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			Array array = ?;

			let arrayType = (ArrayType)type;
			let genericType = arrayType.GetGenericArg(0);
			var obj = Internal.UnsafeCastToObject(*(void**)target);

			if (reader.Current.type == .Null)
			{
				if (obj != null)
					deleteObject();

				return true;
			}
			if (!reader.Expect(.ArrayStart, let token))
				return false;


			var shouldDelete = obj == null;

			if (obj == null)
			{
				if (arrayType.CreateObject((.)token.elements) case .Ok(out obj))
					array = (Array)obj;
				else
					return false;
				*(int*)target = (int)Internal.UnsafeCastToPtr(obj);
			}
			else
			{
				array = (Array)obj;
				if (array.Count < token.elements)
					Runtime.FatalError(scope $"Array was sized @{array.Count} but we needed {token.elements}");
			}

			var ptr = ((uint8*)Internal.UnsafeCastToPtr(obj) + type.InstanceSize - genericType.Size);
			for (var i < token.elements)
			{
				reader.Parse(genericType, ptr);
				ptr += genericType.InstanceStride;
			}

			if (reader.Expect(.ArrayEnd, ?))
				return true;

			if (shouldDelete)
				deleteObject();

			return false;

			void deleteObject()
			{
				delete obj;
				*(int*)target = 0;
			}
		}
	}

	public class JsonSizedArrayConverter : JsonConverter
	{
		public override bool CanConvert(Type type)
		{
			if (type.IsSizedArray)
				return true;

			return false;
		}

		public override void WriteJson(JsonWriter writer, Type type, void* target)
		{
			let arrayType = (SizedArrayType)type;
			let genericType = arrayType.UnderlyingType;
			var ptr = (uint8*)target;
			writer.WriteArrayStart();
			for (var i < arrayType.ElementCount)
			{
				writer.WriteComma();
				writer.WriteValue(genericType, ptr);
				ptr += genericType.InstanceStride;
			}
			writer.WriteArrayEnd();
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			let arrayType = (SizedArrayType)type;
			let genericType = arrayType.UnderlyingType;
			if (reader.Current.type == .Null)
			{
				//for now we will just let the array default
				reader.Next();
				return true;
			}

			if (!reader.Expect(.ArrayStart, let token))
				return false;

			if (token.elements > arrayType.ElementCount)
				Runtime.FatalError(scope $"Expected no more than {arrayType.ElementCount} elements, but got {token.elements}.");

			var ptr = (uint8*)target;
			for (var i < token.elements)
			{
				reader.Parse(genericType, ptr);
				ptr += genericType.InstanceStride;
			}

			if (reader.Expect(.ArrayEnd, ?))
				return true;

			return false;
		}
	}
}
