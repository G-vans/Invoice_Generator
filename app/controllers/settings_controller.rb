class SettingsController < ApplicationController
  before_action :set_setting, only: [ :show, :edit, :update ]

  def show
    redirect_to edit_settings_path
  end

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to edit_settings_path, notice: "Settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_setting
    @setting = Setting.instance
  end

  def setting_params
    params.require(:setting).permit(
      :company_name,
      :company_address,
      :company_phone,
      :company_email,
      :company_website,
      :tax_rate,
      :currency,
      :payment_terms,
      :invoice_prefix,
      :logo
    )
  end
end
