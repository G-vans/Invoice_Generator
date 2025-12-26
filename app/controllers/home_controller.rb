class HomeController < ApplicationController
  def index
    @invoice_count = Invoice.count
    @product_count = Product.active.count
    @setting = Setting.instance
    @recent_invoices = Invoice.recent.limit(5)
    @has_setup = @setting.company_name.present?
  end
end
