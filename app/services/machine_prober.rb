class MachineProber
  Status = Struct.new(:ip_address, :last_succeeded_at, :up, keyword_init: true)
  StatusesResult = Struct.new(:statuses, :error)
  def initialize
    @prom = Prometheus::ApiClient.client(url: Rails.application.config.x.prometheus_url)
    @ping_job = 'contestant_ping'
  end

  attr_reader :prom

  def statuses
    query = prom.query_range(
      query: "probe_success{job=\"#{@ping_job}\"} == 1",
      end: (Time.now).to_i,
      start: (Time.now - 60).to_i,
      step: '5s'
    )

    statuses = {}
    query.fetch('result').each do |metric|
      ip_address = metric.fetch('metric').fetch('instance')
      last = metric.fetch('values').reverse_each.find { |(_ts,v)| v == '1' }&.at(0)
      statuses[ip_address] = Status.new(
        ip_address: metric.fetch('metric').fetch('instance'),
        last_succeeded_at: last ? Time.zone.at(last) : nil,
        up: metric.fetch('values').last[1] == '1',
      )
    end

    StatusesResult.new(statuses, nil)
  rescue KeyError, Prometheus::ApiClient::Client::RequestError => e
    Raven.capture_exception(e)
    StatusesResult.new(nil, e)
  end
end
