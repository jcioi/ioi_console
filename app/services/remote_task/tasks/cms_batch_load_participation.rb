class RemoteTask::Tasks::CmsBatchLoadParticipation < RemoteTask::Tasks::Base
  def initialize(execution, password_tier_id:)
    super(execution)
    @password_tier = PasswordTier.includes(:contest, passwords: :person).find(password_tier_id)
  end

  def script
    [
      'cd /opt/cms',
      'sudo chown cmsuser:cmsuser "$IOI_SCRATCH_PATH"',
      'sudo chmod 600 "$IOI_SCRATCH_PATH"',
      'sudo -u cmsuser ioi-cms-venv python3 ./cmscontrib/BatchLoadParticipation.py "$IOI_SCRATCH_PATH"',
    ].join(?\n)
  end

  def scratch
    StringIO.new({
      participations: @password_tier.passwords.map do |password|
        user = {username: password.person.login}.merge(password.person.first_and_last_name)
        if password.person.team
          user[:team] = {code: password.person.team.slug, name: password.person.team.name}
        end
        {
          contest_id: @password_tier.contest.cms_contest_id,
          plaintext_password: password.plaintext_password,
          user: user,
        }
      end
    }.to_json, 'r')
  end
end
