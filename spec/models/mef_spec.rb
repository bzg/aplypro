# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Mef do
  subject(:mef) { build(:mef) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:ministry) }
  it { is_expected.to validate_presence_of(:mefstat11) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:short) }

  describe "bop_code" do
    context "when the mef.ministry is no MENJ" do
      let(:mef) { build(:mef, ministry: "masa") }
      let(:establishment) { create(:establishment) }

      it "returns the ministry" do
        expect(mef.bop_code(establishment)).to eq "masa"
      end
    end

    context "when the mef.ministry is MENJ" do
      let(:mef) { build(:mef, ministry: "menj") }

      context "when the establishment status contract is 'without subject'" do
        let(:establishment) { create(:establishment, private_contract_type_code: "99") }

        it "returns the Public MENJ BOP code" do
          expect(mef.bop_code(establishment)).to eq "enpu"
        end
      end

      context "when the establishment status contract is an 'allowed private'" do
        let(:establishment) { create(:establishment, private_contract_type_code: "31") }

        it "returns the Public MENJ BOP code" do
          expect(mef.bop_code(establishment)).to eq "enpr"
        end
      end

      context "when the establishment status contract is an 'unallowed_private'" do
        let(:establishment) { create(:establishment, private_contract_type_code: "10") }

        it "returns the Public MENJ BOP code" do
          expect { mef.bop_code(establishment) }.to raise_error IdentityMappers::Errors::UnallowedPrivateEstablishment
        end
      end
    end
  end

  describe "#wage" do
    context "when there is one wage with mefstat4 & ministry" do
      let!(:wage) { create(:wage, mefstat4: mef.mefstat4, ministry: mef.ministry) }

      it "returns the only wage" do
        expect(mef.wage).to eq wage
      end
    end

    context "when there are several wages with mefstat4 & ministry" do
      let!(:correct_wage) { create(:wage, mefstat4: mef.mefstat4, ministry: mef.ministry, mef_codes: [mef.code]) }

      before do
        create(:wage, mefstat4: mef.mefstat4, ministry: mef.ministry, mef_codes: %w[many codes])
      end

      it "returns the correct wage" do
        expect(mef.wage).to eq correct_wage
      end
    end
  end

  describe "associated wage of mef in seed" do
    {
      "2712101021" => { daily_rate: 10, yearly_cap: 450 },
      "2712101022" => { daily_rate: 15, yearly_cap: 675 },
      "2762100132" => { daily_rate: 15, yearly_cap: 900 },
      "2532210311" => { daily_rate: 15, yearly_cap: 1350 }
    }.each do |mef_code, amounts|
      context mef_code.to_s do
        let(:wage) { described_class.find_by(code: mef_code).wage }

        it "has daily_rate = #{amounts[:daily_rate]}" do
          expect(wage.daily_rate).to eq amounts[:daily_rate]
        end

        it "#{mef_code} has yearly_cap = #{amounts[:yearly_cap]}" do
          expect(wage.yearly_cap).to eq amounts[:yearly_cap]
        end
      end
    end
  end
end
