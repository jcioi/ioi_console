class Service::ApplicationController < ::ApplicationController
  layout 'service'
  before_action :require_contestant
end
