# frozen_string_literal: true

Item = Struct.new("Item", :name)

class Collection < Struct
  include Enumerable
end
