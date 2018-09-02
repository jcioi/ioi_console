require 'securerandom'
class RemoteTask::Tasks::Adduser < RemoteTask::Tasks::Base
  def initialize(execution, password_tier_id:)
    super(execution)
    @password_tier = PasswordTier.includes(:contest, passwords: :person).find(password_tier_id)
  end

  def script
    [
      @password_tier.passwords.map do |password|
        "sudo getent passwd '#{password.person.login}' || sudo useradd -g contestant -s /bin/bash '#{password.person.login}'"
      end,
      "cat \"${IOI_SCRATCH_PATH}\" | sudo chpasswd -e",
    ].flatten.join(?\n)
  end

  def scratch
    StringIO.new(
     @password_tier.passwords.map do |password|
       [password.person.login, password.plaintext_password.crypt("$6$#{SecureRandom.base64(12).tr(?+, ?.)}")].join(?:)
     end.join("\n") + "\n", 'r')
  end
end
