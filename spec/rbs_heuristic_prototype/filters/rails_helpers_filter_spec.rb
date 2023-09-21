# frozen_string_literal: true

require "rbs_heuristic_prototype"
require_relative "app/controllers/application_controller"
require_relative "app/helpers/application_helper"
require_relative "app/helpers/accounts_helper"

RSpec.describe RbsHeuristicPrototype::Filters::RailsHelpersFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end

    context "When the module is ApplicationController" do
      let(:sig_file) { Pathname(__dir__) / "sig/application_helper.rbs" }
      let(:expected) do
        <<~RBS
          module ApplicationHelper : ::ApplicationController, ::ActionView::Base
          end
        RBS
      end

      it "sets ActionView::Base as module-self-types" do
        expect(subject).to eq_in_rbs expected
      end
    end

    context "When the module is not ApplicationController" do
      let(:sig_file) { Pathname(__dir__) / "sig/accounts_helper.rbs" }
      let(:expected) do
        <<~RBS
          module AccountsHelper : ::ApplicationController, ::ApplicationHelper
          end
        RBS
      end

      it "sets ApplicationController as module-self-types" do
        expect(subject).to eq_in_rbs expected
      end
    end
  end
end
