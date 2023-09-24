# frozen_string_literal: true

require "action_mailer"

class AccountMailer < ActionMailer::Base
  def welcome_email(account)
    mail to: account.email, subject: subject
  end

  private

  def subject
    "Welcome to My Awesome Site"
  end
end
