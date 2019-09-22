# frozen_string_literal: true

# Devise User Controller
class AccountController < Devise::RegistrationsController
  before_action :require_no_sso!, only: %i[new create]

  def new
    super
  end

  def edit
    redirect_to setting_path
  end

  # POST /resource
  def create
    cache_key = ["user-sign-up", request.remote_ip, Date.today]
    # IP limit
    sign_up_count = Rails.cache.read(cache_key) || 0
    setting_limit = Setting.sign_up_daily_limit
    if setting_limit > 0 && sign_up_count >= setting_limit
      message = "You not allow to sign up new Account, because your IP #{request.remote_ip} has over #{setting_limit} times in today."
      logger.warn message
      return render status: 403, plain: message
    end

    email = params[resource_name][:email]
    email_verification_code = params[:_email_verification_code]
    code_key = "user-email-verification-code:#{email}"
    correct_verification_code = $redis.get(code_key)

    if email_verification_code != correct_verification_code
      message = "邮箱验证码错误 #{email_verification_code} correct: #{correct_verification_code} #{code_key}"
      logger.warn message
      return render status: 200, js: "$('#new_user .alert').remove();\n$('#new_user').prepend('  <div class=\"alert alert-block alert-danger\"><a class=\"close\" data-dismiss=\"alert\" href=\"#\">×<\/a><div><strong>有 1 处问题导致无法提交:<\/strong><\/div><ul><li>邮箱验证码不正确<\/li><\/ul><\/div>');"
    end

    params[resource_name][:invite_code] = User.gen_invite_code()

    build_resource(sign_up_params)
    resource.login = params[resource_name][:login]
    resource.email = email
    if verify_complex_captcha?(resource) && resource.save
      Rails.cache.write(cache_key, sign_up_count + 1)

      sign_in(resource_name, resource)
    end
  end

  private

    # Overwrite the default url to be used after updating a resource.
    # It should be edit_user_registration_path
    # Note: resource param can't miss, because it's the super caller way.
    def after_update_path_for(_)
      edit_user_registration_path
    end
end
