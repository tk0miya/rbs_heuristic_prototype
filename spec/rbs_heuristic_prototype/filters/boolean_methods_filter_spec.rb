# frozen_string_literal: true

require "rbs_heuristic_prototype/filters/boolean_methods_filter"

RSpec.describe RbsHeuristicPrototype::Filters::BooleanMethodsFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end
    let(:sig_file) { Pathname(__dir__) / "sig/boolean_methods.rbs" }
    let(:expected) do
      <<~RBS
        class Foo
          def bar: (untyped param1, untyped param2) -> untyped
          def baz?: () -> boolish
        end
      RBS
    end

    it "converts the return type of boolean methods to boolish" do
      expect(subject).to eq_in_rbs expected
    end
  end
end
