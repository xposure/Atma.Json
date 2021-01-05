using System;
namespace Atma
{
	[AttributeUsage(.Struct | .Class, .AlwaysIncludeTarget | .ReflectAttribute, ReflectUser = .All, AlwaysIncludeUser = .IncludeAllMethods | .AssumeInstantiated)]
	public struct SerializableAttribute : Attribute
	{
	}

	public static class JsonConvert
	{
		public static bool Serialize<T>(T t, String json)
		{
			var writer = scope JsonWriter();
#unwarn
			writer.Write<T>(json, t);
			return true;
		}

		public static Result<bool> Deserialize<T>(T target, StringView json)
			where T : class
		{
			var reader = scope JsonReader();
#unwarn
			return reader.Parse<T>(&target, json);
		}

		public static Result<bool> Deserialize<T>(T* target, StringView json)
			where T : struct
		{
			var reader = scope JsonReader();
#unwarn
			return reader.Parse<T>(target, json);
		}


		public static Result<T> Deserialize<T>(StringView json)
		{
			var reader = scope JsonReader();
			return reader.Parse<T>(json);
		}
	}
}
