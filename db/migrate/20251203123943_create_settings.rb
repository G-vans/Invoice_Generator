class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.string :company_name
      t.text :company_address
      t.string :company_phone
      t.string :company_email
      t.string :company_website
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0.0
      t.string :currency, default: "$"
      t.string :payment_terms, default: "Net 30"
      t.string :invoice_prefix, default: "INV-"

      t.timestamps
    end
  end
end
