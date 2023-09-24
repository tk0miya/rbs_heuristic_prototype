# frozen_string_literal: true

require "rbs_heuristic_prototype"
require_relative "app/controllers/application_controller"
require_relative "app/controllers/concerns/bloggable"
require_relative "app/controllers/concerns/loginable"

RSpec.describe RbsHeuristicPrototype::Filters::RailsConcernsFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end

    context "When a controller concern given" do
      context "When the concern is used in the ApplicationController" do
        let(:sig_file) { Pathname(__dir__) / "sig/loginable.rbs" }
        let(:expected) do
          <<~RBS
            module Loginable : ::ActionController::Base
              extend ActiveSupport::Concern
            end
          RBS
        end

        it "converts the deep class definition to the nested definition" do
          expect(subject).to eq_in_rbs expected
        end
      end

      context "When the concern is not used in the ApplicationController" do
        let(:sig_file) { Pathname(__dir__) / "sig/bloggable.rbs" }
        let(:expected) do
          <<~RBS
            module Bloggable : ::ApplicationController
              extend ActiveSupport::Concern
            end
          RBS
        end

        it "converts the deep class definition to the nested definition" do
          expect(subject).to eq_in_rbs expected
        end
      end
    end
  end
end
