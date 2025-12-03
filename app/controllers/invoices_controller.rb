class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :duplicate, :pdf]
  before_action :set_setting, only: [:new, :create, :edit, :update]

  def index
    @invoices = Invoice.recent
    @invoices = @invoices.by_client(params[:client]) if params[:client].present?
    @invoices = @invoices.by_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "invoice-#{@invoice.invoice_number}",
               template: "invoices/show.pdf.erb",
               layout: "pdf",
               page_size: "A4"
      end
    end
  end

  def new
    @invoice = Invoice.new
    @invoice.invoice_date = Date.current
    @invoice.due_date = calculate_due_date
    @invoice.tax_rate = @setting.tax_rate
    @invoice.invoice_items.build
    @products = Product.active.order(:name)
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.tax_rate = @setting.tax_rate unless invoice_params[:tax_rate].present?

    if @invoice.save
      redirect_to @invoice, notice: "Invoice created successfully."
    else
      @products = Product.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.active.order(:name)
    @invoice.invoice_items.build if @invoice.invoice_items.empty?
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Invoice updated successfully."
    else
      @products = Product.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Invoice deleted successfully."
  end

  def duplicate
    new_invoice = @invoice.duplicate
    if new_invoice.persisted?
      redirect_to new_invoice, notice: "Invoice duplicated successfully."
    else
      redirect_to invoices_path, alert: "Failed to duplicate invoice."
    end
  end

  def pdf
    respond_to do |format|
      format.pdf do
        render pdf: "invoice-#{@invoice.invoice_number}",
               template: "invoices/show.pdf.erb",
               layout: "pdf",
               page_size: "A4"
      end
    end
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_setting
    @setting = Setting.instance
  end

  def invoice_params
    params.require(:invoice).permit(
      :invoice_date,
      :due_date,
      :client_name,
      :client_address,
      :client_email,
      :tax_rate,
      :notes,
      invoice_items_attributes: [:id, :product_id, :description, :quantity, :unit_price, :_destroy, :position]
    )
  end

  def calculate_due_date
    setting = Setting.instance
    days = setting.payment_terms.to_s.scan(/\d+/).first&.to_i || 30
    Date.current + days.days
  end
end

