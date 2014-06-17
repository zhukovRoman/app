class Vacancies < ActiveRecord::Base
  belongs_to :department, inverse_of: :vacancies

  validates :count, numericality: { only_integer: true, :message =>  " должно быть целым числом!" }
end
