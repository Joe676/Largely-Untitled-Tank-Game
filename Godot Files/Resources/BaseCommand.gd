extends Node

var func_ref: FuncRef

func _init(new_func: FuncRef):
	func_ref = new_func

func execute_command(bullet, hit_body, hit_point):
	func_ref.call_func(bullet, hit_body, hit_point)