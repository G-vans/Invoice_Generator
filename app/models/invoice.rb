class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy

  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :due_date, presence: true
  validates :client_name, presence: true
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_totals, on: [:create, :update]
  before_validation :generate_invoice_number, on: :create, unless: :invoice_number?

  scope :recent, -> { order(created_at: :desc) }
  scope :by_client, ->(name) { where("LOWER(client_name) LIKE ?", "%#{name.downcase}%") if name.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(invoice_date: start_date..end_date) if start_date.present? && end_date.present?
  }

  def calculate_totals
    self.subtotal = invoice_items.sum(&:line_total) || 0.0
    self.tax_amount = subtotal * (tax_rate / 100.0)
    self.total = subtotal + tax_amount
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

