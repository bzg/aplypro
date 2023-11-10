# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdentityMappers::Base do
  let(:mapper) { described_class.new(attributes) }
  let(:fredurneresp) { build(:fredurneresp, uai: "dir") }
  let(:fredufonctadm) { "DIR" }
  let(:fredurne) { [build(:fredurne, uai: "normal")] }

  let(:attributes) do
    {
      "FrEduRneResp" => fredurneresp,
      "FrEduRne" => fredurne,
      "FrEduFonctAdm" => fredufonctadm
    }
  end

  describe "#all_indicated_uais" do
    subject(:result) { mapper.all_indicated_uais }

    it { is_expected.to contain_exactly "normal", "dir" }

    context "when there are irrelevant establishments" do
      let(:fredurne) { [build(:fredurne, uai: "normal"), build(:fredurne, uai: "normal wrong", tty_code: "CLG")] }
      let(:fredurneresp) { [build(:fredurneresp, uai: "dir"), build(:fredurneresp, uai: "dir wrong", tty_code: "CLG")] }

      it { is_expected.not_to include "normal wrong", "dir wrong" }
    end

    context "when there are no values" do
      let(:fredurneresp) { ["X"] }
      let(:fredurne) { ["X"] }

      it { is_expected.to be_empty }
    end
  end

  describe "#responsibility_uais" do
    context "when there is a FrEduRneResp" do
      subject(:result) { mapper.responsibility_uais }

      context "when it's a not the right kind of school" do
        let(:fredurneresp) { [build(:fredurneresp, uai: "dir wrong", tty_code: "CLG")] }

        it { is_expected.to be_empty }
      end

      context "when it's the proper kind of school" do
        it { is_expected.to contain_exactly "dir" }
      end

      context "when the administration function is not DIR" do
        let(:fredufonctadm) { "ADM" }

        it { is_expected.to be_empty }
      end

      context "when the FrEduRneResp value is plain" do
        let(:fredurneresp) { "0441550W$UAJ$PU$N$T3$LYC$340" }

        it { is_expected.not_to be_empty }
      end
    end

    context "when there is no FrEduRneResp" do
      it "is empty" do
        attributes.delete("FrEduRneResp")

        expect(described_class.new(attributes).responsibility_uais).to be_empty
      end
    end
  end
end