class Vacancies < ActiveRecord::Base
  belongs_to :department, inverse_of: :vacancies

  validates :count, numericality: { only_integer: true, :message =>  " должно быть целым числом!" }

  def self.fill_empty_vac (date)
    Department.where(parent_id:  nil).each do |dep|
      vac = dep.vacancies.where(for_date: date.at_beginning_of_month..date.at_end_of_month).take
      if (vac == nil)
        dep.vacancies.create(count: 0, for_date: date.at_beginning_of_month+14.day)
      end
    end
  end
end
