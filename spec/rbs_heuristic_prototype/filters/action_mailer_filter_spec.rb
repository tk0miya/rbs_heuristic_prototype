# frozen_string_literal: true

require "rbs_heuristic_prototype/filters/action_mailer_filter"
require_relative "app/mailers/account_mailer"

RSpec.describe RbsHeuristicPrototype::Filters::ActionMailerFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end

    let(:sig_file) { Pathname(__dir__) / "sig/account_mailer.rbs" }
    let(:expected) do
      <<~RBS
        class AccountMailer < ActionMailer::Base
          def self.welcome_email: (untyped account) -> ::ActionMailer::MessageDelivery

          private

          def subject: () -> String
        end
      RBS
    end

    it "converts the return type of validate methods to void" do
      expect(subject).to eq_in_rbs expected
    end
  end
end
