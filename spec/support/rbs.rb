# frozen_string_literal: true

require "stringio"

RSpec::Matchers.define :eq_in_rbs do |expected|
  match do |actual|
    out = StringIO.new
    RBS::Writer.new(out: out).write(actual.declarations)
    @actual = out.string
    out.string == expected
  end

  diffable
end
