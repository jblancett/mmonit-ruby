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
				'Referer' => "#{@url}/index.csp",
				'Content-Type' => 'application/x-www-form-urlencoded',
				'User-Agent' => @useragent,
				'Connection' => 'Keep-Alive'
			}
		end

		def connect
			@http = Net::HTTP.new(@address, @port)

			if @ssl
				@http.use_ssl = true
				@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end

			@headers['Cookie'] = @http.get('/index.csp').response['set-cookie'].split(';').first
			self.login
		end

		def login
			self.request('/z_security_check', "z_username=#{@username}&z_password=#{@password}", true).code.to_i == 302
		end

		# Status API: http://mmonit.com/documentation/http-api/Methods/Status
		def status
			JSON.parse(self.request('/status/hosts/list').body)['records']
		end

		def status_detailed(id_or_fqdn)
			status = find_status(id_or_fqdn)
			status.nil? ? nil : JSON.parse(self.request("/status/hosts/get?id=#{status['id']}").body)['records']['host'] rescue nil
		end

		# Events API: http://mmonit.com/documentation/http-api/Methods/Events
		def events
			JSON.parse(self.request('/reports/events/list').body)['records']
		end

		def event(id)
			JSON.parse(self.request("/reports/events/get?id=#{id}").body) rescue nil
		end

		# Admin Hosts API: http://mmonit.com/documentation/http-api/Methods/Admin_Hosts
		def hosts
			JSON.parse(self.request('/admin/hosts/list').body)['records']
		end

		def host(id_or_fqdn)
			host = find_host(id_or_fqdn)
			host.nil? ? nil : JSON.parse(self.request("/admin/hosts/get?id=#{host['id']}").body) rescue nil
		end

		# Admin Users API: http://mmonit.com/documentation/http-api/Methods/Admin_Users
		def users
			JSON.parse(self.request('/admin/users/list').body)
		end

		def user(username)
			JSON.parse(self.request("/admin/users/get?uname=#{username}").body) rescue nil
		end

		# Admin Groups API: http://mmonit.com/documentation/http-api/Methods/Admin_Groups
		def groups
			JSON.parse(self.request('/admin/groups/list').body)
		end

		# Helpers
		def find_host(id_or_fqdn)
			hosts = self.hosts rescue []
			host = hosts.select{ |h| h['id'] == id_or_fqdn || h['host'] == id_or_fqdn }
			host.empty? ? nil : host.first
		end

		def find_status(id_or_fqdn)
			statuses = self.status rescue []
			status = statuses.select{ |s| s['id'] == id_or_fqdn || s['hostname'] == id_or_fqdn }
			status.empty? ? nil : status.first
		end

		def request(path, body="", is_post = false, headers = {})
			self.connect unless @http.is_a?(Net::HTTP)
			if is_post
				@http.post(path, body, @headers.merge(headers))
			else
				@http.get(path, @headers.merge(headers))
			end
		end

		# Backwards compatability
		def get_host_details(id) # Left for backwards compatability
			status_detailed(id)
		end
	end
end