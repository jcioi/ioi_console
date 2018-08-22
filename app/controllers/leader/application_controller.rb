class Leader::ApplicationController < ::ApplicationController
  layout 'leader'
  before_action :require_leader
end
