# frozen_string_literal: true

class Student
  module AddressMappers
    class Sygne < Base
      class Mapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          unwrap :adrResidenceEle

          rename_keys(
            codePostal: :postal_code,
            adresseLigne1: :address_line1,
            adresseLigne2: :address_line2,
            codePays: :country_code,
            codeCommuneInsee: :city_insee_code,
            libelleCommune: :city
          )

          accept_keys %i[postal_code country_code city city_insee_code address_line1 address_line2]
        end
      end
    end
  end
end