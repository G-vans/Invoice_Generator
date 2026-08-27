require "prawn"
require "prawn/table"

class InvoicePdfService
  # Modern color palette
  PRIMARY_COLOR = "1F2937"    # Dark gray (almost black)
  ACCENT_COLOR = "3B82F6"     # Blue
  MUTED_COLOR = "6B7280"      # Gray
  LIGHT_BG = "F9FAFB"         # Very light gray
  TABLE_HEADER_BG = "E5E7EB"  # Light gray for table header
  SUCCESS_COLOR = "10B981"    # Green for paid status

  def initialize(invoice)
    @invoice = invoice
    @setting = Setting.instance
  end

  def generate
    Prawn::Document.new(page_size: "A4", margin: [ 40, 40, 40, 40 ]) do |pdf|
      setup_fonts(pdf)
      create_watermark_stamp(pdf)
      draw_header(pdf)
      draw_invoice_info_box(pdf)
      draw_bill_to(pdf)
      draw_line_items(pdf)
      draw_totals(pdf)
      draw_notes(pdf) if @invoice.notes.present?
      draw_payment_terms(pdf)
      draw_footer(pdf)
      apply_watermark_stamp(pdf)
    end
  end

  private

  def setup_fonts(pdf)
    # Use built-in Helvetica family for clean look
    pdf.font "Helvetica"
  end

  def create_watermark_stamp(pdf)
    return unless @setting.logo.attached?

    begin
      logo_path = ActiveStorage::Blob.service.path_for(@setting.logo.key)
      if File.exist?(logo_path)
        pdf.create_stamp("watermark") do
          pdf.transparent(0.04) do
            # Stamps operate in absolute page coordinates by default
            # Center the image on an A4 page (roughly 595 x 842 points)
            w = 400
            pdf.image logo_path, width: w, position: :center, vposition: :center
          end
        end
      end
    rescue => e
      Rails.logger.error "Error creating watermark stamp: #{e.message}"
    end
  end

  def apply_watermark_stamp(pdf)
    return unless @setting.logo.attached?

    pdf.repeat(:all) do
      pdf.stamp("watermark")
    end
  end

  def draw_header(pdf)
    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width, height: 100) do
      # Left side - Company branding
      pdf.bounding_box([ 0, pdf.bounds.top ], width: pdf.bounds.width * 0.55, height: 100) do
        # Company Logo
        if @setting.logo.attached?
          begin
            logo_path = ActiveStorage::Blob.service.path_for(@setting.logo.key)
            if File.exist?(logo_path)
              pdf.image logo_path, width: 120, position: :left
              pdf.move_down 8
            end
          rescue => e
            Rails.logger.error "Error loading logo: #{e.message}"
          end
        end

        # Company Information
        pdf.text @setting.company_name || "Company Name", size: 16, style: :bold, color: PRIMARY_COLOR
        pdf.move_down 4

        if @setting.company_address.present?
          pdf.text @setting.company_address, size: 9, color: MUTED_COLOR, leading: 2
        end

        contact_parts = []
        contact_parts << @setting.company_phone if @setting.company_phone.present?
        contact_parts << @setting.company_email if @setting.company_email.present?
        if contact_parts.any?
          pdf.move_down 4
          pdf.text contact_parts.join("  •  "), size: 9, color: MUTED_COLOR
        end
      end

      # Right side - INVOICE title and number
      pdf.bounding_box([ pdf.bounds.width * 0.55, pdf.bounds.top ], width: pdf.bounds.width * 0.45, height: 100) do
        pdf.text "INVOICE", size: 28, style: :bold, align: :right, color: PRIMARY_COLOR
        pdf.move_down 6
        pdf.text "##{@invoice.invoice_number}", size: 14, align: :right, color: ACCENT_COLOR, style: :bold
      end
    end

    pdf.move_down 20
  end

  def draw_invoice_info_box(pdf)
    # Draw a styled info box with dates and status
    box_height = 60

    pdf.fill_color LIGHT_BG
    pdf.fill_rectangle [ 0, pdf.cursor ], pdf.bounds.width, box_height
    pdf.fill_color "000000"

    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width, height: box_height) do
      pdf.move_down 15

      # Three columns: Invoice Date, Due Date, Status
      col_width = pdf.bounds.width / 3

      # Invoice Date
      pdf.bounding_box([ 0, pdf.cursor ], width: col_width) do
        pdf.text "Invoice Date", size: 8, color: MUTED_COLOR, align: :center
        pdf.move_down 4
        pdf.text @invoice.invoice_date.strftime("%B %d, %Y"), size: 11, style: :bold, color: PRIMARY_COLOR, align: :center
      end

      # Due Date
      pdf.bounding_box([ col_width, pdf.cursor + 20 ], width: col_width) do
        pdf.text "Due Date", size: 8, color: MUTED_COLOR, align: :center
        pdf.move_down 4
        pdf.text @invoice.due_date.strftime("%B %d, %Y"), size: 11, style: :bold, color: PRIMARY_COLOR, align: :center
      end

      # Status
      pdf.bounding_box([ col_width * 2, pdf.cursor + 20 ], width: col_width) do
        pdf.text "Status", size: 8, color: MUTED_COLOR, align: :center
        pdf.move_down 4
        status_color = case @invoice.status
        when "paid" then SUCCESS_COLOR
        when "sent" then ACCENT_COLOR
        else MUTED_COLOR
        end
        pdf.text (@invoice.status || "draft").upcase, size: 11, style: :bold, color: status_color, align: :center
      end
    end

    pdf.move_down 25
  end

  def draw_bill_to(pdf)
    pdf.text "BILL TO", size: 9, style: :bold, color: MUTED_COLOR
    pdf.move_down 6

    # Draw a subtle left border
    pdf.stroke_color ACCENT_COLOR
    pdf.line_width = 2
    pdf.stroke_line [ 0, pdf.cursor ], [ 0, pdf.cursor - 50 ]
    pdf.line_width = 1

    pdf.bounding_box([ 10, pdf.cursor ], width: 250) do
      pdf.text @invoice.client_name, size: 12, style: :bold, color: PRIMARY_COLOR
      pdf.move_down 4

      if @invoice.client_address.present?
        pdf.text @invoice.client_address, size: 10, color: MUTED_COLOR, leading: 2
      end

      if @invoice.client_email.present?
        pdf.move_down 4
        pdf.text @invoice.client_email, size: 10, color: ACCENT_COLOR
      end
    end

    pdf.move_down 25
  end

  def draw_line_items(pdf)
    items_data = [ [ "Description", "Qty", "Unit Price", "Amount" ] ]

    @invoice.invoice_items.order(:position).each do |item|
      items_data << [
        item.description,
        format_quantity(item.quantity),
        format_currency(item.unit_price),
        format_currency(item.line_total)
      ]
    end

    pdf.table(items_data, header: true, width: pdf.bounds.width) do |table|
      # Header styling
      table.row(0).font_style = :bold
      table.row(0).background_color = TABLE_HEADER_BG
      table.row(0).text_color = PRIMARY_COLOR
      table.row(0).size = 9
      table.row(0).padding = [ 12, 10, 12, 10 ]

      # Alignment
      table.columns(0).align = :left
      table.columns(1..3).align = :right

      # Column widths
      table.column(0).width = pdf.bounds.width * 0.50
      table.column(1).width = pdf.bounds.width * 0.12
      table.column(2).width = pdf.bounds.width * 0.19
      table.column(3).width = pdf.bounds.width * 0.19

      # Body rows styling
      table.rows(1..-1).each_with_index do |row, idx|
        row.padding = [ 10, 10, 10, 10 ]
        row.size = 10
        row.text_color = PRIMARY_COLOR
        # Alternate row colors
        row.background_color = idx.even? ? "FFFFFF" : LIGHT_BG
      end

      # Border styling
      table.cells.borders = [ :bottom ]
      table.cells.border_width = 0.5
      table.cells.border_color = "E5E7EB"
      table.row(0).borders = [ :bottom ]
      table.row(0).border_width = 1
      table.row(-1).borders = [ :bottom ]
      table.row(-1).border_width = 1
    end

    pdf.move_down 20
  end

  def draw_totals(pdf)
    totals_width = 220
    totals_x = pdf.bounds.width - totals_width

    pdf.bounding_box([ totals_x, pdf.cursor ], width: totals_width) do
      # Subtotal
      draw_total_row(pdf, "Subtotal", format_currency(@invoice.subtotal), totals_width)

      # Tax (if applicable)
      if @invoice.tax_rate > 0
        pdf.move_down 8
        draw_total_row(pdf, "Tax (#{@invoice.tax_rate}%)", format_currency(@invoice.tax_amount), totals_width)
      end

      pdf.move_down 10

      # Divider
      pdf.stroke_color TABLE_HEADER_BG
      pdf.line_width = 1
      pdf.stroke_horizontal_line 0, totals_width

      pdf.move_down 10

      # Grand Total - no background

      pdf.bounding_box([ 0, pdf.cursor + 5 ], width: totals_width, height: 30) do
        pdf.move_down 8
        pdf.text_box "TOTAL DUE", at: [ 10, pdf.cursor ], width: totals_width * 0.5, size: 10, style: :bold, color: PRIMARY_COLOR
        pdf.text_box format_currency(@invoice.total), at: [ totals_width * 0.5, pdf.cursor ], width: totals_width * 0.5 - 10, size: 12, style: :bold, color: PRIMARY_COLOR, align: :right
      end
    end
  end

  def draw_total_row(pdf, label, value, width)
    pdf.text_box label, at: [ 0, pdf.cursor ], width: width * 0.6, size: 10, color: MUTED_COLOR
    pdf.text_box value, at: [ width * 0.6, pdf.cursor ], width: width * 0.4, size: 10, color: PRIMARY_COLOR, align: :right, style: :bold
  end

  def draw_notes(pdf)
    pdf.move_down 40

    pdf.text "NOTES", size: 9, style: :bold, color: MUTED_COLOR
    pdf.move_down 6

    pdf.fill_color LIGHT_BG
    notes_height = [ pdf.height_of(@invoice.notes, size: 9) + 20, 60 ].max
    pdf.fill_rectangle [ 0, pdf.cursor ], pdf.bounds.width, notes_height
    pdf.fill_color "000000"

    pdf.bounding_box([ 10, pdf.cursor - 10 ], width: pdf.bounds.width - 20) do
      pdf.text @invoice.notes, size: 9, color: MUTED_COLOR, leading: 3
    end

    pdf.move_down notes_height
  end

  def draw_payment_terms(pdf)
    if @setting.payment_terms.present?
      pdf.move_down 20
      pdf.text "Payment Terms: #{@setting.payment_terms}", size: 9, color: MUTED_COLOR
    end
  end

  def draw_footer(pdf)
    pdf.move_cursor_to 40

    pdf.stroke_color TABLE_HEADER_BG
    pdf.stroke_horizontal_line 0, pdf.bounds.width
    pdf.move_down 10

    pdf.text "Thank you for your business!", size: 10, align: :center, color: PRIMARY_COLOR, style: :bold

    if @setting.company_website.present?
      pdf.move_down 4
      pdf.text @setting.company_website, size: 8, align: :center, color: ACCENT_COLOR
    end
  end

  def format_currency(amount)
    "#{@setting.currency} #{sprintf('%.2f', amount)}"
  end

  def format_quantity(qty)
    qty == qty.to_i ? qty.to_i.to_s : sprintf("%.2f", qty)
  end
end
