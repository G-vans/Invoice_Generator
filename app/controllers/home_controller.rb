class HomeController < ApplicationController
  # Allow unauthenticated access to home page
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @setting = Setting.instance
    @has_setup = @setting.company_name.present?

    if user_signed_in?
      @invoice_count = Invoice.count
      @product_count = Product.active.count
      @recent_invoices = Invoice.recent.limit(5)
    else
      @invoice_count = 0
      @product_count = 0
      @recent_invoices = []
    end
  end
end
