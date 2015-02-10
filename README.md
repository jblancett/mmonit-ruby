# mmonit-ruby

Ruby interface for M/Monit

A subset of the [M/Monit HTTP API](http://mmonit.com/documentation/http-api/) commands are currently available. Requests are currently read-only.

## Available Commands

* `connect` - Connect to M/Monit and establish a session
* `status` - Status overview
* `status_detailed(id_or_fqdn)` - Detailed status for a specified host
  * `id_or_fqdn` - Either the numeric id or the fully-qualified domain name for a host
* `events` - Events overview
* `event(id)` - Detailed information about an event
  * `id` - The numeric id for an event
* `hosts` - A list of hosts
* `host(id_or_fqdn)` - Detailed information about a specified host
  * `id_or_fqdn` - Either the numeric id or the fully-qualified domain name for a host
* `users` - A list of users
* `user(id)` - Detailed information about a user
  * `id` - The numeric id for a user
* `groups` - A list of groups

## Usage

    require 'mmonit-ruby'

    mmonit = MMonit::Connection.new({
            :ssl => true,
            :username => 'USERNAME',
            :password => 'PASSWORD',
            :address => 'example.com',
            :port => '443'
    })

    mmonit.connect

    hosts = mmonit.hosts

## Custom Requests

Custom requests can be made like:

    require 'mmonit-ruby'

    mmonit.request(path, [body])

`body` is optional