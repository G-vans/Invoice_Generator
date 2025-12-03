class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :line_total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_line_total, on: [:create, :update]
  before_save :set_position_if_needed

  def calculate_line_total
    self.line_total = (quantity.to_f * unit_price.to_f).round(2)
  end

  private

  def set_position_if_needed
    self.position ||= invoice.invoice_items.maximum(:position).to_i + 1
  end
end

