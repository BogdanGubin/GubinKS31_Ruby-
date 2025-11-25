sum3_Gubin = ->(a, b, c) { a + b + c }
def curry3(proc_or_lambda)
  build = ->(args_so_far) {
    ->(*new_args) {
      all_args = args_so_far + new_args
      if all_args.size > 3
        raise ArgumentError, "Error!"
      elsif all_args.size == 3
        proc_or_lambda.call(*all_args)
      else
        build.call(all_args)
      end
    }
  }
  build.call([])
end


cur = curry3(sum3_Gubin)
puts cur.call(1).call(2).call(3)     
puts cur.call(1, 2).call(3)          
puts cur.call(1).call(2, 3)           
p cur.call()                          
puts cur.call(1, 2, 3)              

