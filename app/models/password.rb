require 'securerandom'

class Password < ApplicationRecord
  belongs_to :person
  belongs_to :password_tier

  validates :plaintext_password, presence: true

  scope :in_use, ->(t = Time.now) { left_joins(:password_tier).merge(PasswordTier.active) }

  def self.random
    chars = ([*'a'..'z', *'0'..'9'] - '1Ilij0OopPG6g89'.chars)
    SecureRandom.send(:choose, chars, 9)
  end

  def in_use?(t = Time.now)
    password_tier ? password_tier.active?(t) : true
  end

  def attempt(value)
    Rack::Utils.secure_compare(value, plaintext_password)
  end
end
