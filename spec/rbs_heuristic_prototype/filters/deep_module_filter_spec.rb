# frozen_string_literal: true

require "rbs_heuristic_prototype/filters/deep_module_filter"
require_relative "models/deep_module"

RSpec.describe RbsHeuristicPrototype::Filters::DeepModuleFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end

    let(:sig_file) { Pathname(__dir__) / "sig/deep_module.rbs" }
    let(:expected) do
      <<~RBS
        module Mod
          module Mod
            class Class < Integer
              class Class < Integer
              end
            end
          end
        end

        module Mod
          class Class < Integer
            module Mod
            end
          end
        end
      RBS
    end

    it "converts the deep class definition to the nested definition" do
      expect(subject).to eq_in_rbs expected
    end
  end
end
