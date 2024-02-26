# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::PersPhysiqueMapper do
  subject(:mapper) { described_class.new(payment) }

  let(:payment) { create(:payment) }
  let(:student) { payment.student }

  described_class::MAPPING.each do |name, mapping|
    it "maps to the student's`#{mapping}'" do
      expect(mapper.send(name)).to eq student[mapping]
    end
  end

  describe "codeinseepaysnai" do
    subject(:code) { mapper.codeinseepaysnai }

    before do
      allow(InseeCountryCodeMapper).to receive(:call).and_return :value
    end

    it "delegates to the INSEE country code mapper" do
      expect(code).to eq :value
    end
  end
end
