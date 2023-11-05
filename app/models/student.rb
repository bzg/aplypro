# frozen_string_literal: true

class Student < ApplicationRecord
  validates :ine,
            :first_name,
            :last_name,
            :birthdate,
            :asp_file_reference,
            presence: true

  validates :asp_file_reference, uniqueness: true

  has_many :schoolings, dependent: :delete_all
  has_many :classes, through: :schoolings, source: "classe"

  has_many :pfmps, -> { order "pfmps.start_date" }, through: :schoolings

  belongs_to :current_schooling, optional: true, class_name: "Schooling", dependent: :destroy
  has_one :classe, through: :current_schooling

  has_one :establishment, through: :classe
  has_many :payments, through: :pfmps

  has_many :ribs, dependent: :destroy
  has_one :rib, -> { where(archived_at: nil) }, dependent: :destroy, inverse_of: :student

  before_validation :check_asp_file_reference

  def to_s
    full_name
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def index_name
    [last_name, first_name].join(" ")
  end

  def used_allowance
    payments.in_state(:success).map(&:amount).sum
  end

  def allowance_left
    current_schooling.mef.wage.yearly_cap - used_allowance
  end

  def close_current_schooling!
    return if current_schooling.nil?

    current_schooling.update!(end_date: Time.zone.today)
    update!(current_schooling: nil)
  end

  def addressable?
    [
      address_line1,
      address_line2,
      postal_code,
      city_insee_code,
      city,
      country_code
    ].compact.any?
  end

  private

  def check_asp_file_reference
    return if asp_file_reference.present?

    loop do
      self.asp_file_reference = generate_asp_file_reference

      break unless Student.exists?(asp_file_reference: asp_file_reference)
    end
  end

  def generate_asp_file_reference
    SecureRandom.alphanumeric(10).upcase
  end
end
