module InvoiceHelper
  def status_badge_class(status)
    case status
    when "draft"
      "bg-gray-100 text-gray-800"
    when "sent"
      "bg-blue-100 text-blue-800"
    when "paid"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
