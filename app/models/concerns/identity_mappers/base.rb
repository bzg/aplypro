# frozen_string_literal: true

module IdentityMappers
  class Base
    attr_accessor :attributes

    # List of establishment types : https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_TYPE_UAI
    ACCEPTED_ESTABLISHMENT_TYPES = %w[LYC LP SEP EREA].freeze
    FREDURNERESP_MAPPING = %i[uai type category activity tna_sym tty_code tna_code].freeze
    FREDURNE_MAPPING     = %i[uai type category activity uaj tna_sym tty_code tna_code].freeze

    def initialize(attributes)
      @attributes = normalize(attributes)
    end

    def normalize(attributes)
      attributes
    end

    def map_responsibility(line)
      FREDURNERESP_MAPPING.zip(line.split("$")).to_h
    end

    def map_establishment(line)
      FREDURNE_MAPPING.zip(line.split("$")).to_h
    end

    def responsibilities
      return [] if attributes["FrEduRneResp"].blank? || !director?

      Array(attributes["FrEduRneResp"])
        .reject { |line| no_value?(line) }
        .map    { |line| map_responsibility(line) }
        .filter { |line| relevant?(line) }
    end

    def director?
      attributes["FrEduFonctAdm"] == "DIR"
    end

    def no_value?(line)
      line.blank? || line == "X"
    end

    def relevant?(attrs)
      ACCEPTED_ESTABLISHMENT_TYPES.include?(attrs[:tty_code])
    end

    def authorised_establishments_for(email)
      return [] if attributes["FrEduRne"].blank?

      Array(attributes["FrEduRne"])
        .reject     { |line| no_value?(line) }
        .map        { |line| map_establishment(line) }
        .filter_map { |attrs| Establishment.find_by(uai: attrs[:uai]) }
        .select     { |establishment| establishment.invites?(email) }
    end

    def establishments_in_responsibility
      responsibilities
        .pluck(:uai)
        .map { |uai| Establishment.find_or_create_by!(uai: uai) }
    end
  end
end
