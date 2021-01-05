using System;
namespace Atma.Json.Tests
{
	class JsonStructTests
	{
		[Serializable]
		public struct vec2 : this(int x, int y)
		{
		}

		[Test]
		public static void WriteSimpleStruct()
		{
			const String data = "{\"x\":10,\"y\":20}";
			let json = scope String();
			let v = vec2(10, 20);
			Assert.IsTrue(JsonConvert.Serialize(v, json));
			Assert.EqualTo(json, data);

			Assert.IsTrue(JsonConvert.Deserialize<vec2>(json) case .Ok(let val));
			Assert.EqualTo(val, v);
		}

		[Serializable]
		public struct vec3
		{
			public vec2 v2;
			public int z;
		}

		[Test]
		public static void NestedStruct()
		{
			const String data = "{\"v2\":{\"x\":10,\"y\":20},\"z\":30}";
			let json = scope String();
			vec3 v = ?;
			v.v2 = vec2(10, 20);
			v.z = 30;
			Assert.IsTrue(JsonConvert.Serialize(v, json));
			Assert.EqualTo(json, data);

			Assert.IsTrue(JsonConvert.Deserialize<vec3>(json) case .Ok(let val));
			Assert.EqualTo(val, v);
		}

		[Serializable]
		public struct vec3<T>
			where T : Object
		{
			public vec2 v2;
			public T z;
		}

		[Test]
		public static void NestedStructObject()
		{
			{
				const String data = "{\"v2\":{\"x\":10,\"y\":20},\"z\":null}";
				vec3<String> v = ?;
				v.v2 = vec2(10, 20);
				v.z = null;

				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize(v, json));
				Assert.EqualTo(json, data);

				Assert.IsTrue(JsonConvert.Deserialize<vec3<String>>(json) case .Ok(let val));
				Assert.EqualTo(val, v);
			}
			{
				const String data = "{\"v2\":{\"x\":10,\"y\":20},\"z\":\"hello world\"}";
				vec3<String> v = ?;
				v.v2 = vec2(10, 20);
				v.z = new String("hello world");

				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize(v, json));
				Assert.EqualTo(json, data);

				Assert.IsTrue(JsonConvert.Deserialize<vec3<String>>(json) case .Ok(let val));
				Assert.EqualTo(val, v);
				delete v.z;
				delete val.z;
			}
		}

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

		[Test]
		public static void ParseVec3()
		{
			//deseriealize simple struct from string
			if (JsonConvert.Deserialize<Vec2<float>>("{x:1.1,y:7.9}") case .Ok(let val))
				Console.WriteLine(val.ToString(..scope String()));//[x:1.1, y:7.9]
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
	}
}
