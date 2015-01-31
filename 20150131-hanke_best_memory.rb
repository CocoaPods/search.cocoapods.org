 index: 368748 ruby /Users/hanke/.gem/ruby/2.2.0/bin/unicorn -p 5000 -c unicorn.rb
master:  70476 unicorn master -p 5000 -c unicorn.rb
 stats:  20084 ruby /Users/hanke/.gem/ruby/2.2.0/bin/unicorn -p 5000 -c unicorn.rb
   web:  15852 unicorn worker[1] -p 5000 -c unicorn.rb
   web:  15144 unicorn worker[0] -p 5000 -c unicorn.rb
   
* Could we reduce the master size?