# frozen_string_literal: true

require "rbs_heuristic_prototype/filters/type_args_filter"
require_relative "models/collection"

RSpec.describe RbsHeuristicPrototype::Filters::TypeArgsFilter do
  describe "#apply" do
    subject { described_class.new(env).apply }

    let(:env) do
      loader = RBS::EnvironmentLoader.new(core_root: nil)
      loader.add(path: sig_file)
      RBS::Environment.from_loader(loader)
    end

    let(:sig_file) { Pathname(__dir__) / "sig/collection.rbs" }
    let(:expected) do
      <<~RBS
        class Item < Struct[untyped]
        end

        class Collection
          include Enumerable[untyped]
        end
      RBS
    end

    it "converts the return type of validate methods to void" do
      expect(subject).to eq_in_rbs expected
    end
  end
end
