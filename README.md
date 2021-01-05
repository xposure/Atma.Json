# Atma.Json


## Simple serialization example

```
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
```

And these can be used with the following code.

```
    public static void Examples()
		{
			//deseriealize simple struct from string
			if (JsonConvert.Deserialize<Vec2<float>>("{x:1.1,y:7.9}") case .Ok(let v2))
				Console.WriteLine(v2.ToString(..scope String()));//Output: [x:1.1, y:7.9]

			//nested struct
			if (JsonConvert.Deserialize<Vec3<float>>("{p:{x:1.5,y:9.1},z:4.4}") case .Ok(let v3))
				Console.WriteLine(v3.ToString(..scope String()));//Output: [x:1.1, y:7.9]

		}
```
