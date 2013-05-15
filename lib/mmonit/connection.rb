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
				'Connection' => 'keepalive'
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
			self.request('/z_security_check', "z_username=#{@username}&z_password=#{@password}").code.to_i == 302
		end

		def status
			JSON.parse(self.request('/json/status/list').body)['records']
		end

		def hosts
			JSON.parse(self.request('/json/admin/hosts/list').body)['records']
		end

		def users
			JSON.parse(self.request('/json/admin/users/list').body)['records']
		end

		def rules
			JSON.parse(self.request('/json/admin/rules/list').body)['records']
		end

		def request(path, body="", headers = {})
			self.connect unless @http.is_a?(Net::HTTP)
			@http.post(path, body, @headers.merge(headers))
		end
	end
end