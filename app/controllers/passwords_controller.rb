class PasswordsController < ApplicationController
  def edit
  end

  def update
    @form = PasswordChangeForm.new(password_params)

    if @form.save(Current.user)
      redirect_to settings_path, notice: "Password updated."
    else
      render turbo_stream: turbo_stream.replace(:password_form,
        partial: "passwords/form"), status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:password).permit(:current_password, :password, :password_confirmation)
  end
end
