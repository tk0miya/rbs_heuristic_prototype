# frozen_string_literal: true

require "action_controller"
require_relative "concerns/loginable"

class ApplicationController < ActionController::Base
  include Loginable
end
