mmonit-ruby
===========

Ruby interface for M/Monit

All the commands listed here are currently available:

http://mmonit.com/wiki/MMonit/HTTP-API

Requests are read-only until I find a way to do more.




mmonit = MMonit::Connection.new({
        :ssl => true,
        :username => 'USERNAME',
        :password => 'PASSWORD',
        :address => 'example.com',
        :port => '443'
})

mmonit.connect

hosts = mmonit.hosts

p hosts



Custom requests can be made like:

mmonit.request(path, [body])

body is optional