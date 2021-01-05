using System;
using System.Reflection;
namespace Atma.Json.Tests
{
	public static class Examples
	{
		[Serializable]
		public struct Vec2<T>
		{
			public T x, y;
			public this(T x, T y)
			{
				this.x = x;
				this.y = y;
			}

			public override void ToString(String strBuffer)
			{
				strBuffer.Append(scope $"[x:{x:0.0}, y:{y:0.0}] ");
			}
		}

		[Serializable]
		public struct Vec3<T>
		{
			public Vec2<T> p;
			public T z;

			public this(Vec2<T> p, T z)
			{
				this.p = p;
				this.z = z;
			}

			public override void ToString(String strBuffer)
			{
				strBuffer.Append(scope $"[x:{p.x:0.0}, y:{p.y:0.0}, z:{z:0.0}] ");
			}
		}

		[Serializable]
		public class StringRef
		{
			//you can create a new string or the runtime will create it for you if null
			public int x;
			public String Text = new .() ~ delete _;
			public this(int x)
			{
				this.x = x;
			}
		}

		[Test]
		public static void Examples()
		{
			//deseriealize simple struct from string
			if (JsonConvert.Deserialize<Vec2<float>>("{x:1.1,y:7.9}") case .Ok(let v2))
				Console.WriteLine(v2.ToString(..scope String()));//Output: [x:1.1, y:7.9]

			//nested struct
			if (JsonConvert.Deserialize<Vec3<float>>("{p:{x:1.5,y:9.1},z:4.4}") case .Ok(let v3))
				Console.WriteLine(v3.ToString(..scope String()));//Output: [x:1.1, y:7.9]

			//Class references
			if (JsonConvert.Deserialize<StringRef>("{text:'hello world'}") case .Ok(let rf))
			{
				Console.WriteLine(rf.Text);//Output: [x:1.1, y:7.9]
				delete rf;//be sure to delete your references
			}
			{
				//You can also pass in your own references
				let result = JsonConvert.Deserialize(..scope StringRef(10), "{text:'hello world'}");
				Console.WriteLine(scope $"{result.Text}, {result.x}");
				//delete result; //there is no need to delete since it was scoped
			}

			JsonConfig.AddConverter(new JsonVec2Converter());
			//deseriealize simple struct from string
			if (JsonConvert.Deserialize<Vec2<float>>("[1.1,7.9]") case .Ok(let v2))
				Console.WriteLine(v2.ToString(..scope String()));//Output: [x:1.1, y:7.9]
		}

		//We can't pass in Vec2<> as the Converter type so we much manually do it as void
		//so we need to do void and do our own casts
		//we still want to use StructConverter because it handles, pointers, nullables, etc
		public class JsonVec2Converter : JsonStructConverter<void>
		{
			public override bool CanConvert(Type type)
			{
				return GetGenericType(type) != null;
			}

			private Type GetGenericType(Type type)
			{
				if (let genericType = type as SpecializedGenericType && (genericType.UnspecializedType == typeof(Vec2<>)))
					return genericType.GetGenericArg(0);
				return null;
			}

			protected override void OnWriteJson(JsonWriter writer, Type type, void* target)
			{
				//since this is a struct, target points straight at the first element of vec2 (aka x)
				let genericType = GetGenericType(type);
				var ptr = (uint8*)target;
				writer.WriteArrayStart();
				{
					//element count increases by 1 as well as marking the next WriteComma to actually write a comma
					writer.WriteComma();
					//write x
					writer.WriteValue(genericType, ptr);

					//move to next element base on the generic elements stride
					ptr += genericType.Stride;
					//write the first comma, element count == 2
					writer.WriteComma();

					//write y
					writer.WriteValue(genericType, ptr);
				}
				writer.WriteArrayEnd();
			}

			protected override bool OnReadJson(JsonReader reader, Type type, void* target)
			{
				//since this is a struct, target points straight at the first element of vec2 (aka x)
				let genericType = GetGenericType(type);
				var ptr = (uint8*)target;

				//we expect to find an array
				if (!reader.Expect(.ArrayStart, let token))
					return false;

				//we expect to find to elements in the array
				if (token.elements != 2)
					return false;

				//read x
				if (!reader.Parse(genericType, ptr))
					return false;

				ptr += genericType.Stride;
				//read y
				if (!reader.Parse(genericType, ptr))
					return false;

				return reader.Expect(.ArrayEnd, ?);
			}
		}

	}
}
