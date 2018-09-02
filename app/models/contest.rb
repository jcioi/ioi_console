class Contest < ApplicationRecord
  has_many :password_tiers

  def taskable?
    cms_remote_task_target.present? && cms_remote_task_driver.present? && cms_contest_id.present?
  end
end
