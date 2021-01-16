using System;
using System.Collections;

namespace Atma.Json.Tests
{
	class JsonListTest
	{
		[Test]
		public static void ReadList()
		{
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<List<int>>("[]") case .Ok(let val));
				Assert.EqualTo(val.Count, 0);
				delete val;
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<List<int>>("[0,1,2]") case .Ok(let val));
				Assert.EqualTo(val.Count, 3);
				for (var i < val.Count)
					Assert.EqualTo(val[i], i);
				delete val;
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<List<float>>("[0.35,1.35,2.35]") case .Ok(let val));
				Assert.EqualTo(val.Count, 3);
				for (var i < val.Count)
					Assert.IsTrue(val[i] - i - 0.35 < 0.00001);
				delete val;
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<List<List<int>>>("[[0,1,2],[3,4,5]]") case .Ok(let val));
				Assert.EqualTo(val.Count, 2);
				Assert.EqualTo(val[0].Count, 3);
				Assert.EqualTo(val[1].Count, 3);
				DeleteContainerAndItems!(val);
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<List<int>>("null") case .Ok(let val));
				Assert.IsNull(val);
			}
		}

		[Test]
		public static void WriteList()
		{
			{
				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize(scope List<int>(3) {1, 2, 3}, json));
				Assert.EqualTo(json, "[1,2,3]");
			}
			{
				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize(scope List<int>(), json));
				Assert.EqualTo(json, "[]");
			}
			{
				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize<List<int>>(null, json));
				Assert.EqualTo(json, "null");
			}
		}
	}
}
