require "prawn"
require "prawn/table"

class InvoicePdfService
  def initialize(invoice)
    @invoice = invoice
    @setting = Setting.instance
  end

  def generate
    Prawn::Document.new(page_size: "A4", margin: [ 50, 50, 50, 50 ]) do |pdf|
      draw_header(pdf)
      draw_bill_to(pdf)
      draw_line_items(pdf)
      draw_totals(pdf)
      draw_notes(pdf) if @invoice.notes.present?
      draw_footer(pdf)
    end
  end

  private

  def draw_header(pdf)
    # Two column layout for header
    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
      # Left column - Company Info
      pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width * 0.6) do
        # Company Logo
        if @setting.logo.attached?
          begin
            logo_path = ActiveStorage::Blob.service.path_for(@setting.logo.key)
            if File.exist?(logo_path)
              pdf.image logo_path, width: 100
              pdf.move_down 10
            end
          rescue => e
            Rails.logger.error "Error loading logo: #{e.message}"
          end
        end

        # Company Information
        pdf.text @setting.company_name || "Company Name", size: 18, style: :bold, color: "0066CC"
        pdf.move_down 5

        if @setting.company_address.present?
          pdf.text @setting.company_address, size: 10, color: "666666"
          pdf.move_down 3
        end

        contact_info = []
        contact_info << @setting.company_phone if @setting.company_phone.present?
        contact_info << @setting.company_email if @setting.company_email.present?
        if contact_info.any?
          pdf.text contact_info.join(" | "), size: 9, color: "666666"
        end
      end

      # Right column - Invoice Info
      pdf.bounding_box([ pdf.bounds.width * 0.6, pdf.cursor + 50 ], width: pdf.bounds.width * 0.4) do
        pdf.text "INVOICE", size: 24, style: :bold, align: :right, color: "0066CC"
        pdf.move_down 10
        pdf.text "Invoice #: #{@invoice.invoice_number}", size: 10, align: :right
        pdf.text "Date: #{@invoice.invoice_date.strftime("%B %d, %Y")}", size: 10, align: :right
        pdf.text "Due: #{@invoice.due_date.strftime("%B %d, %Y")}", size: 10, align: :right
      end
    end

    pdf.move_down 30
  end

  def draw_bill_to(pdf)
    pdf.bounding_box([ 0, pdf.cursor ], width: 250) do
      pdf.text "Bill To:", size: 10, style: :bold, color: "666666"
      pdf.move_down 5
      pdf.text @invoice.client_name, size: 11, style: :bold
      pdf.move_down 3

      if @invoice.client_address.present?
        pdf.text @invoice.client_address, size: 9, color: "666666"
        pdf.move_down 3
      end

      if @invoice.client_email.present?
        pdf.text @invoice.client_email, size: 9, color: "666666"
      end
    end

    pdf.move_down 20
  end

  def draw_line_items(pdf)
    items_data = [ [ "Description", "Qty", "Unit Price", "Total" ] ]

    @invoice.invoice_items.order(:position).each do |item|
      items_data << [
        item.description,
        item.quantity.to_s,
        "#{@setting.currency}#{sprintf('%.2f', item.unit_price)}",
        "#{@setting.currency}#{sprintf('%.2f', item.line_total)}"
      ]
    end

    pdf.table(items_data, header: true, width: pdf.bounds.width) do |table|
      table.row(0).font_style = :bold
      table.row(0).background_color = "F5F5F5"
      table.row(0).text_color = "000000"
      table.columns(1..3).align = :right
      table.row(0).align = :center

      table.rows(1..-1).each do |row|
        row.height = 30
        row.valign = :center
      end

      table.column(0).width = pdf.bounds.width * 0.55
      table.column(1).width = pdf.bounds.width * 0.15
      table.column(2).width = pdf.bounds.width * 0.15
      table.column(3).width = pdf.bounds.width * 0.15
    end

    pdf.move_down 20
  end

  def draw_totals(pdf)
    totals_width = 200
    totals_x = pdf.bounds.width - totals_width

    pdf.bounding_box([ totals_x, pdf.cursor ], width: totals_width) do
      pdf.stroke_color "666666"
      pdf.stroke_horizontal_line 0, totals_width

      pdf.move_down 10

      # Subtotal
      pdf.text_box "Subtotal:", at: [ 0, pdf.cursor ], width: totals_width * 0.6, size: 10, color: "666666"
      pdf.text_box "#{@setting.currency}#{sprintf('%.2f', @invoice.subtotal)}",
                   at: [ totals_width * 0.6, pdf.cursor ], width: totals_width * 0.4,
                   size: 10, align: :right
      pdf.move_down 15

      # Tax
      if @invoice.tax_rate > 0
        pdf.text_box "Tax (#{@invoice.tax_rate}%):", at: [ 0, pdf.cursor ], width: totals_width * 0.6, size: 10, color: "666666"
        pdf.text_box "#{@setting.currency}#{sprintf('%.2f', @invoice.tax_amount)}",
                     at: [ totals_width * 0.6, pdf.cursor ], width: totals_width * 0.4,
                     size: 10, align: :right
        pdf.move_down 15
      end

      pdf.stroke_color "666666"
      pdf.stroke_horizontal_line 0, totals_width

      pdf.move_down 10

      # Grand Total
      pdf.text_box "Total:", at: [ 0, pdf.cursor ], width: totals_width * 0.6, size: 12, style: :bold
      pdf.text_box "#{@setting.currency}#{sprintf('%.2f', @invoice.total)}",
                   at: [ totals_width * 0.6, pdf.cursor ], width: totals_width * 0.4,
                   size: 12, style: :bold, align: :right
    end
  end

  def draw_notes(pdf)
    pdf.move_down 30
    pdf.stroke_color "666666"
    pdf.stroke_horizontal_line 0, pdf.bounds.width
    pdf.move_down 10

    pdf.text "Notes:", size: 10, style: :bold, color: "666666"
    pdf.move_down 5
    pdf.text @invoice.notes, size: 9, color: "666666"
  end

  def draw_footer(pdf)
    pdf.move_cursor_to 50
    pdf.stroke_color "666666"
    pdf.stroke_horizontal_line 0, pdf.bounds.width
    pdf.move_down 5
    pdf.text "Thank you for your business!", size: 9, align: :center, color: "666666", style: :italic
  end
end
