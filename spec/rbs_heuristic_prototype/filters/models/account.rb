# frozen_string_literal: true

require "active_model"

class Account
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :name, :string
  attribute :age, :integer

  validate :matured
  validate :name_given

  def matured
    errors.add(:age, "too young") if age.present? && age < 18
  end

  def name_given
    errors.add(:name, "empty") if name.empty?
  end

  def other_method; end
end
