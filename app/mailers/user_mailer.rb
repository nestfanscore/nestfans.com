# frozen_string_literal: true

class UserMailer < BaseMailer
  def welcome(user_id)
    @user = User.find_by_id(user_id)
    return false if @user.blank?
    mail(to: @user.email, subject: t("mail.welcome_subject", app_name: Setting.app_name).to_s)
  end

  def verification_code(email, code)
    @code = code
    return false if email.blank? || @code.blank?

    mail(to: email, subject: "注册验证码 - #{Setting.app_name}")
  end
end
