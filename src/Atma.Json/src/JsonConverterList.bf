using System;
using System.Collections;
using System.Reflection;

namespace Atma
{
	public class JsonListConverter : JsonConverter
	{
		public override bool CanConvert(Type type)
		{
			let typeName = scope String();
			type.GetName(typeName);

			return typeName.Equals("List");
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
				let listType = type as SpecializedGenericType;
				let genericType = listType.GetGenericArg(0);
				let list = (List<Object>*)&obj;
				writer.WriteArrayStart();
				for (var item in *list)
				{
					writer.WriteComma();
					if (genericType.IsPrimitive)
						writer.WriteValue(genericType, (void*)&item);
					else
						writer.WriteValue(genericType, Internal.UnsafeCastToPtr(item));
				}
				writer.WriteArrayEnd();
			}
		}

		public override bool ReadJson(JsonReader reader, Type type, void* target)
		{
			let listType = type as SpecializedGenericType;
			let genericType = listType.GetGenericArg(0);
			MethodInfo addMethod;
			if (listType.GetMethod("Add") case .Ok(let val))
				addMethod = val;
			else
				return false;
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
				if (type.CreateObject() case .Ok(let val))
					obj = val;
				else
					return false;
				*(int*)target = (int)Internal.UnsafeCastToPtr(obj);
			}

			for (var i < token.elements)
			{
				void* ptr = null;

				mixin Add(Object objItem)
				{
					if (addMethod.Invoke(obj, objItem) case .Err)
					{
						if (shouldDelete)
							deleteObject();

						return false;
					}
				}

				if (genericType.IsPrimitive)
				{
					Variant varVal;
					ptr = Variant.Alloc(genericType, out varVal);
					if (!reader.Parse(genericType, ptr))
						return false;
					Add!(varVal.GetValueData());
				}
				else
				{
					if (!reader.Parse(genericType, &ptr))
						return false;
					Add!(Internal.UnsafeCastToObject(ptr));
				}
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
}
