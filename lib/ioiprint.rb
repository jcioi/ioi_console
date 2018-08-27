require 'uri'

class Ioiprint
  def initialize(url = ENV.fetch('IOIPRINT_URL'))
    @conn = Faraday.new(url: url) do |faraday|
      faraday.request :json
      faraday.response :raise_error
      faraday.use :instrumentation
      faraday.adapter Faraday.default_adapter
    end
  end

  attr_reader :conn

  # title:: String
  # users:: [{name: String, username: String, password: String}]
  def print_passwords(title:, users:)
    conn.post '/password', {title: title, users: users}
  end
end
