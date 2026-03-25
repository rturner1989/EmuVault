module Settings
  class PasswordsController < MainController
    def update
      if current_user.authenticate(params[:current_password])
        if current_user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          redirect_to settings_path, notice: "Password updated."
        else
          redirect_to settings_path, alert: current_user.errors.full_messages.to_sentence
        end
      else
        redirect_to settings_path, alert: "Current password is incorrect."
      end
    end
  end
end
