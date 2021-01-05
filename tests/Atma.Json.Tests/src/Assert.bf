using System;
namespace Atma
{
	public static class Assert
	{
		public static void IsTrue(bool cond, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
		{
			Test.Assert(cond == true, error, filePath, line);
		}

		public static void IsFalse(bool cond, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
		{
			Test.Assert(cond == false, error, filePath, line);
		}

		public static void EqualTo<T, K>(T actual, K expected, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
			where bool : operator T == K
		{
			Test.Assert(actual == expected, error, filePath, line);
		}

		public static void IsNull<T>(T obj, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
			where T : var
		{
			Test.Assert(obj == null, error, filePath, line);
		}


	}
}
