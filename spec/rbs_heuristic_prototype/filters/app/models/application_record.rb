# frozen_string_literal: true

require "active_record"
require_relative "concerns/discardable"

class ApplicationRecord < ActiveRecord::Base
  include Discardable
end
