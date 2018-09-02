class Admin::MetricsController < Admin::ApplicationController
  skip_before_action :require_staff

  def show
    text = []

    text << "# TYPE ioiconsole_hailings_count gauge"
    text << "# HELP ioiconsole_hailings_count total number of staff requests"
    Hailing.joins(:contestant).group('people.login, hailings.request_type').pluck('people.login', 'hailings.request_type', 'COUNT(*)').each do |(login, request, count)|
      text << "ioiconsole_hailings_count{login=\"#{login}\",request=\"#{request}\"} #{count}"
    end

    render plain: text.join("\n")
  end
end
