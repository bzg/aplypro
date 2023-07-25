# frozen_string_literal: true

class Student < ApplicationRecord
  self.primary_key = "ine"

  validates :ine, :first_name, :last_name, presence: true

  belongs_to :classe
  has_one :establishment, through: :classe
  has_many :pfmps, dependent: :destroy
  has_many :payments, through: :pfmps

  has_many :ribs, dependent: :destroy
  has_one :rib, -> { where(archived_at: nil) }, dependent: :destroy, inverse_of: :student

  def to_s
    full_name
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def rib_changed!
    pfmps.each do |p|
      p.setup_payment! if p.unscheduled?
    end
  end
end