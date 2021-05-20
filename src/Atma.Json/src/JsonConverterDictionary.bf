using System;
using System.Collections;
using System.Reflection;

namespace Atma
{
	public class JsonDictionaryConverter : JsonConverter
	{
		public override bool CanConvert(Type type)
		{
			let typeName = scope String();
			type.GetName(typeName);

			return typeName.Equals("Dictionary");
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
				let dictType = type as SpecializedGenericType;
				let genericTypeValue = dictType.GetGenericArg(1);
				let dict = (Dictionary<String, Object>*)&obj;

				writer.WriteObjectStart();
				for (var item in *dict)
				{
					writer.WriteComma();
					writer.WriteString(item.key);

					writer.WriteRaw(':');

					if (genericTypeValue.IsPrimitive)
						writer.WriteValue(genericTypeValue, (void*)&item.value);
					else
						writer.WriteValue(genericTypeValue, Internal.UnsafeCastToPtr(item.value));
				}
				writer.WriteObjectEnd();
			}
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			let dictType = type as SpecializedGenericType;
			let genericTypeKey = dictType.GetGenericArg(0);
			let genericTypeValue = dictType.GetGenericArg(1);

			MethodInfo addMethod = default;
			let methods = dictType.GetMethods();
			for (let m in methods)
			{
				if (m.Name == "Add" && m.ParamCount == 2)
				{
					addMethod = m;
					break;
				}
			}
			if (addMethod == default)
				return false;

			var obj = Internal.UnsafeCastToObject(*(void**)target);

			if (reader.Current.type == .Null)
			{
				if (obj != null)
					deleteObject();

				return true;
			}
			if (!reader.Expect(.ObjectStart, let token))
				return false;


			var shouldDelete = obj == null;

			if (obj == null)
			{
				if (type.CreateObject() case .Ok(let val))
					obj = val;
				else
					return false;
				*(int*)target = (int)Internal.UnsafeCastToPtr(obj);
			}

			for (var i < token.elements)
			{
				String ptrKey = null;
				void* ptrVal = null;
				if (!reader.Expect(.Field, let field))
				{
					if (shouldDelete)
						deleteObject();

					return false;
				}

				ptrKey = new String(field.text);

				reader.Parse(genericTypeValue, &ptrVal);

				int valVal = 0;

				if (genericTypeValue.IsPrimitive)
				   valVal = (int)ptrVal;
				else
					valVal = (int)Internal.UnsafeCastToObject(ptrVal);

				if (addMethod.Invoke(obj, ptrKey, valVal) case .Err)
				{
					if (shouldDelete)
						deleteObject();

					return false;
				}
			}

			if (reader.Expect(.ObjectEnd, ?))
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
}
