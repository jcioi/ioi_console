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

  # message:: String
  # contestant:: {id: String, name: String, special_requirement_note: String?}
  # desk:: {id: String, map: URI?, zone: String?}
  def print_staff_call(message:, contestant:, desk:)
    conn.post '/staff_call', {message: message, contestant: contestant, desk: desk}
  end
end
