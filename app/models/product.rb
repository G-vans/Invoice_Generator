class Product < ApplicationRecord
  has_many :invoice_items, dependent: :nullify

  validates :name, presence: true
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def self.search(query)
    return all if query.blank?
    where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", "%#{query.downcase}%", "%#{query.downcase}%")
  end
end

