class_name CommonFuncs extends Node

static var fibo : Array = [1,2]
static func _fib(n: int) -> int:
	if fibo.size() >= n:
		return fibo[n - 1]
	var start = max(2, fibo.size())
	for i in range(start, n):
		var last = fibo[i - 1] + fibo[i - 2]
		fibo.append(last)
	return fibo.back()
