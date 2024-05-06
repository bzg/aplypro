# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::CoordPaieMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:rib) { payment_request.student.rib }

  before do
    with_readonly_bypass(rib)
  end

  context "when the BIC ends in 'XXX'" do
    let(:xbic) { "CMCIFR2AXXX" } # https://wise.com/fr/swift-codes/countries/france/credit-mutuel-swift-code

    before { rib.update!(bic: xbic) }

    context "when it is from a non-French country" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "it")) }

      it "does not remove any characters" do
        expect(mapper.bic).to eq rib.bic
      end
    end

    context "when it is from a French country (or considered as such)" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "mc")) }

      it "removes those characters" do
        expect(mapper.bic).to eq "CMCIFR2A"
      end
    end
  end

  context "when the BIC is 8 characters long" do
    before { rib.update!(bic: rib.bic.first(8)) }

    context "when it is from a French country (or considered as such)" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "mc")) }

      it "does not touch the bic" do
        expect(mapper.bic).to eq rib.bic
      end
    end

    context "when it is from a non-French country" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "it")) }

      it "pads it to 11 characters with X's" do
        expect(mapper.bic).to eq "#{rib.bic}XXX"
      end
    end
  end

  context "when the name has special characters in it" do
    before { rib.update!(name: "Bonnie´ & _Clyde^;retraités-end") }

    it "removes them" do
      expect(mapper.intitdest).to eq "Bonnie Clyde retraités end"
    end
  end
end
