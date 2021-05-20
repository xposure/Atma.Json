using System;
using System.Collections;

namespace Atma.Json.Tests
{
	class JsonDictionaryTests
	{
		[Test]
		public static void ReadDictionary()
		{
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<Dictionary<int, int>>("null") case .Ok(let val));
				Assert.IsNull(val);
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<Dictionary<int, int>>("{}") case .Ok(let val));
				Assert.EqualTo(val.Count, 0);
				delete val;
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<Dictionary<String, int>>("{\"_0\": 1, \"_1\": 2, \"_2\": 3}") case .Ok(let val));
				Assert.EqualTo(val.Count, 3);
				DeleteDictionaryAndKeys!(val);
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<Dictionary<String, float>>("{\"_0\": 0.35, \"_1\": 1.35, \"_2\": 2.35}") case .Ok(let val));
				Assert.EqualTo(val.Count, 3);
				var v = val.Values;
				for (var i < val.Count)
				{
					Assert.IsTrue(v.Current - i - 0.35 < 0.00001);
					v.MoveNext();
				}
				DeleteDictionaryAndKeys!(val);
			}
		}

		[Test]
		public static void WriteDictionary()
		{
			{
				let json = scope String();
				let dict = scope Dictionary<String, int>(3);
				dict.Add("_0", 1);
				dict.Add("_1", 2);
				dict.Add("_2", 3);
				Assert.IsTrue(JsonConvert.Serialize(dict, json));
				Assert.EqualTo(json, "{\"_0\":1,\"_1\":2,\"_2\":3}");
			}
			{
				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize(scope Dictionary<String, int>(), json));
				Assert.EqualTo(json, "{}");
			}
			{
				let json = scope String();
				Assert.IsTrue(JsonConvert.Serialize<Dictionary<String, int>>(null, json));
				Assert.EqualTo(json, "null");
			}
		}
	}
}
