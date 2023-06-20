# frozen_string_literal: true

require "rbs_heuristic_prototype/filters/symbol_array_constants_filter"

RSpec.describe RbsHeuristicPrototype::Filters::SymbolArrayConstantsFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end
    let(:sig_file) { Pathname(__dir__) / "sig/symbol_array_constants.rbs" }
    let(:expected) do
      <<~RBS
        module Foo
          MODULE_CONSTANT: ::Array[::Symbol]

          class Bar
            CLASS_CONSTANT: ::Array[::Symbol]
          end
        end
      RBS
    end

    it "converts the return type of Symbol arrays to Array[:Symbol]" do
      expect(subject).to eq_in_rbs expected
    end
  end
end
