class Person < ApplicationRecord
  enum role: %i(staff contestant leader)
end
