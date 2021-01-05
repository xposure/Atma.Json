using System;
namespace Atma
{
	[Serializable]
	public class Class1
	{
		public int x;

		public static bool operator==(Class1 l, Class1 r) => l.x == r.x;
	}

	public class JsonObjectTests
	{
		[Test]
		public static void Test()
		{
			const String data = "{\"x\":123}";

			let json = scope String();
			let v = scope Class1();
			v.x = 123;

			//let v2 = JsonConverter.Serialize(..scope Class1(), data);

			Assert.IsTrue(JsonConvert.Serialize(v, json));
			Assert.EqualTo(json, data);

			Assert.IsTrue(JsonConvert.Deserialize<Class1>(json) case .Ok(let val));
			Assert.IsTrue(val == v);
			delete val;
		}
	}
}
