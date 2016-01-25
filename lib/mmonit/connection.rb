require 'net/http'
require 'net/https'
require 'json'

module MMonit
	class Connection
		attr_reader :http, :address, :port, :ssl, :username, :useragent, :headers
		attr_writer :password

		def initialize(options = {})
			@ssl = options[:ssl] || false
			@address = options[:address]
			options[:port] ||= @ssl ? '8443' : '8080'
			@port = options[:port]
			@username = options[:username]
			@password = options[:password]
			options[:useragent] ||= "MMonit-Ruby/#{MMonit::VERSION}"
			@useragent = options[:useragent]
			@headers = {
				'Host' => @address,
				'Content-Type' => 'application/x-www-form-urlencoded',
				'User-Agent' => @useragent,
				'Connection' => 'keepalive'
			}
		end

		def connect
			@http = Net::HTTP.new(@address, @port)

			if @ssl
				@http.use_ssl = true
				@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end

			@headers['Cookie'] = @http.get('/index.csp', initheader = @headers).response['set-cookie'].split(';').first
			self.login
		end

		def login
			self.request('/z_security_check', "z_username=#{@username}&z_password=#{@password}&z_csrf_protection=off").code.to_i == 302
		end

		def logout
			self.request('/login/logout.csp')
		end

		def status
			JSON.parse(self.request('/status/list').body)['records']
		end

		def hosts
			JSON.parse(self.request('/admin/hosts/list').body)['records']
		end

		def groups
			JSON.parse(self.request('/admin/groups/list').body)['groups']
		end

		def users
			JSON.parse(self.request('/admin/users/list').body)
		end

		def alerts
			JSON.parse(self.request('/admin/alerts/list').body)
		end

		def events
			JSON.parse(self.request('/events/list').body)['records']
		end

		####  topography and reports are disabled until I figure out their new equivalent in M/Monit
		# def topography
		# 	JSON.parse(self.request('/json/status/topography').body)
		# end

		# def reports(hostid=nil)
		# 	body = String.new
		# 	body = "hostid=#{hostid.to_s}" if hostid
		# 	JSON.parse(self.request('/json/reports/overview', body).body)
		# end

		def find_host(fqdn)
			host = self.hosts.select{ |h| h['hostname'] == fqdn }
			host.empty? ? nil : host.first
		end

		def find_group(group)
			groups = self.groups.select{ |g| g['name'] == group }
			groups.empty? ? nil : groups.first
		end

		def get_host_details(id)
			JSON.parse(self.request("/status/hosts/get?id=#{id}").body)['records']['host'] rescue nil
		end

		def delete_host(host)
			host = self.find_host(host['host']) if host.key?('host') && ! host.key?('id')
			return false unless host['id']
			self.request("/admin/hosts/delete?id=#{host['id']}")
		end

		def delete_group(group)
			group = self.find_group(group) unless group.key?('id')
			return false unless group['id']
			self.request("/admin/groups/delete", "id=#{group['id']}")
		end

		def create_group(group)
			self.request("/admin/groups/create", "name=#{group}")
		end

		def add_group(group, hostids)
			group = self.find_group(group) if group.is_a?(String)
			return false unless group['id']
			if hostids.is_a?(Array)
				hostids_str = hostids.join('&hostid=')
			elsif hostids.is_a?(String)
				hostids_str = hostids
			elsif hostid.key('id')
				hostids_str = hostids['id']
			end
			self.request("/admin/groups/add", "id=#{group['id']}&hostid=#{hostids_str}")
		end

		def request(path, body="", headers = {})
			self.connect unless @http.is_a?(Net::HTTP)
			if body == ""
				@http.get(path, initheader = @headers.merge(headers))
			else
				@http.post(path, body, @headers.merge(headers))
			end
		end
	end
end
