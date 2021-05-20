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
			}
			{
				var jr = scope JsonReader();
				Assert.IsTrue(jr.Parse<Dictionary<String, int>>("{\"_0\": 1, \"_1\": 2, \"_2\": 3}") case .Ok(let val));
				Assert.EqualTo(val.Count, 3);
			}
		}
	}
}
