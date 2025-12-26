class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank

  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :due_date, presence: true
  validates :client_name, presence: true
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_totals, on: [ :create, :update ]
  before_validation :generate_invoice_number, on: :create, unless: :invoice_number?

  scope :recent, -> { order(created_at: :desc) }
  scope :by_client, ->(name) { where("LOWER(client_name) LIKE ?", "%#{name.downcase}%") if name.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(invoice_date: start_date..end_date) if start_date.present? && end_date.present?
  }

  def calculate_totals
    # Calculate subtotal from invoice items (including unsaved ones)
    calculated_subtotal = invoice_items.map do |item|
      # Ensure line_total is calculated
      if item.line_total.nil? || item.line_total.zero?
        line_total = (item.quantity.to_f * item.unit_price.to_f).round(2)
        item.line_total = line_total unless item.persisted?
        line_total
      else
        item.line_total.to_f
      end
    end.compact.sum

    self.subtotal = calculated_subtotal || 0.0
    tax_rate_value = (tax_rate || 0).to_f
    self.tax_amount = (subtotal * (tax_rate_value / 100.0)).round(2)
    self.total = (subtotal + tax_amount).round(2)
  end

  def generate_invoice_number
    setting = Setting.instance
    prefix = setting.invoice_prefix.presence || "INV-"

    last_invoice = Invoice.order(:invoice_number).last
    if last_invoice&.invoice_number&.match?(/^#{Regexp.escape(prefix)}\d+$/)
      last_number = last_invoice.invoice_number.gsub(/^#{Regexp.escape(prefix)}/, "").to_i
      self.invoice_number = "#{prefix}#{(last_number + 1).to_s.rjust(3, '0')}"
    else
      self.invoice_number = "#{prefix}001"
    end
  end

  def duplicate
    new_invoice = dup
    new_invoice.invoice_number = nil
    new_invoice.invoice_date = Date.current
    new_invoice.due_date = calculate_due_date
    new_invoice.status = "draft"

    if new_invoice.save
      invoice_items.each do |item|
        new_invoice.invoice_items.create!(
          product: item.product,
          description: item.description,
          quantity: item.quantity,
          unit_price: item.unit_price,
          line_total: item.line_total,
          position: item.position
        )
      end
    end

    new_invoice
  end

  private

  def calculate_due_date
    setting = Setting.instance
    days = setting.payment_terms.to_s.scan(/\d+/).first&.to_i || 30
    invoice_date + days.days
  end
end
