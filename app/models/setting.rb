class Setting < ApplicationRecord
  # Singleton pattern - only one settings record
  has_one_attached :logo

  # Company name is optional - user can update other settings without it

  # Class method to get or create the singleton instance
  def self.instance
    first_or_create! do |setting|
      setting.tax_rate = 0.0
      setting.currency = "$"
      setting.payment_terms = "Net 30"
      setting.invoice_prefix = "INV-"
    end
  end
end
