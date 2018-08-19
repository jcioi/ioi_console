class PasswordTier < ApplicationRecord
  belongs_to :contest, required: false
  has_many :passwords, dependent: :destroy

  scope :active, ->(t = Time.now) { where('(not_before < ? OR not_before IS NULL) AND (? < not_after OR not_after IS NULL)', t, t) }

  def active?(t = Time.now)
    (not_before ? not_before < t : true) && (not_after ? t < not_after : true)
  end

  def generate!(people:, overwrite: false)
    people.map do |person|
      password = passwords.find_or_initialize_by(person: person)
      if !password.persisted? || overwrite
        password.plaintext_password = Password.random
        password.save!
      end
      password
    end
  end
end
