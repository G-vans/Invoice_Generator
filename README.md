# Invoice Generator

A modern, full-stack Ruby on Rails application for creating, managing, and exporting professional invoices. Built to streamline the invoice creation process and eliminate the risk of overwriting previous invoices when using template-based systems.

## 🎯 Problem We're Solving

Previously, invoices were created by manually editing a Google Docs template. This approach had several pain points:
- ❌ Each edit overwrote the previous invoice (no version history)
- ❌ Time-consuming manual data entry
- ❌ No centralized invoice management
- ❌ Difficult to track invoice numbers
- ❌ No easy way to generate PDFs

## ✨ Solution

This application provides:
- ✅ **Template-based system** - Set up your company logo and details once, reuse forever
- ✅ **Product catalog** - Create a library of common food items and products, click to add them to invoices
- ✅ **Independent invoices** - Each invoice is saved separately, no data loss
- ✅ **Auto-calculations** - Automatic totals, tax calculations, and invoice numbering
- ✅ **PDF export** - Professional, print-ready PDF invoices
- ✅ **Invoice management** - View, edit, search, and organize all your invoices
- ✅ **Simple interface** - Clean, intuitive UI built with Tailwind CSS

## 🚀 Features

### Core Features (MVP)
- **Invoice Template Management**
  - Upload and store company logo
  - Set company information (name, address, contact details)
  - Configure default settings (tax rate, currency, payment terms)

- **Product/Item Catalog** 🆕
  - Create a catalog of common food items and products
  - Store item name and description (no fixed prices - negotiate per client!)
  - Organize items by category (optional)
  - Search and filter catalog items
  - Edit or delete catalog items
  - Perfect for small catering businesses where prices vary per client

- **Invoice Creation**
  - Create invoices from template
  - Add client information
  - **Click to add items from catalog** - No more typing the same items repeatedly!
  - **Enter price when adding** - Perfect for negotiated pricing per client
  - Adjust quantity when adding catalog items
  - Manually add custom items (for one-off items not in catalog)
  - Automatic calculations (subtotal, tax, grand total)
  - Auto-incrementing invoice numbers
  - Set invoice and due dates

- **Invoice Management**
  - View all invoices in a list
  - Search and filter invoices
  - Edit existing invoices
  - Duplicate invoices for similar clients
  - Delete invoices (with confirmation)

- **PDF Export**
  - Generate professional PDF invoices
  - Print-friendly formatting
  - Download with proper filename

### Future Enhancements (Planned)
- Client database for reusable client information
- Invoice status tracking (draft/sent/paid)
- Email sending capabilities
- Multiple invoice templates
- Recurring invoices
- Reports and analytics

## 🛠️ Technology Stack

- **Backend:** Ruby on Rails 8.0.4
- **Database:** SQLite3 (development)
- **Frontend:** 
  - ERB templates
  - Tailwind CSS for styling
  - Hotwire (Turbo + Stimulus) for interactivity
- **PDF Generation:** Prawn gem
- **File Storage:** Active Storage

## 📋 Prerequisites

- Ruby 3.3+ (check `.ruby-version`)
- Rails 8.0.4
- Bundler
- Node.js (for Tailwind CSS)

## 🏃 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd invoice_generator
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Install Tailwind CSS** (if not already set up)
   ```bash
   # Follow Tailwind CSS setup instructions for Rails
   ```

5. **Start the server**
   ```bash
   bin/dev
   # or
   rails server
   ```

6. **Visit the application**
   ```
   http://localhost:3000
   ```

### First Time Setup

1. Navigate to Settings (`/settings`)
2. Upload your company logo
3. Enter your company information
4. Configure default settings (tax rate, currency, etc.)
5. Save settings

6. **Set up your Product Catalog** (recommended for catering businesses)
   - Navigate to Products (`/products`)
   - Add your common food items and products
   - Include name and description (no price needed - you'll enter it per invoice)
   - Add category if desired (e.g., "Main Courses", "Beverages", "Desserts")
   - Save items to your catalog

### Creating Your First Invoice

1. Click "New Invoice" from the dashboard
2. Enter client information
3. **Add items from catalog:**
   - Search or browse your product catalog
   - Click on items to add them
   - Enter the price (negotiated per client - no default price)
   - Adjust quantity as needed
4. **Or add custom items:**
   - Click "Add Custom Item" for items not in your catalog
   - Enter description, quantity, and price manually
5. Review auto-calculated totals
6. Add notes if needed
7. Click "Save Invoice"
8. Click "Download PDF" to export

## 📁 Project Structure

```
invoice_generator/
├── app/
│   ├── controllers/
│   │   ├── invoices_controller.rb      # Invoice CRUD operations
│   │   ├── invoice_items_controller.rb # Line items management
│   │   ├── settings_controller.rb      # Template settings
│   │   └── pdf_controller.rb           # PDF generation
│   ├── models/
│   │   ├── invoice.rb                   # Invoice model
│   │   ├── invoice_item.rb              # Line item model
│   │   └── setting.rb                   # Settings model
│   ├── views/
│   │   ├── invoices/                    # Invoice views
│   │   ├── settings/                    # Settings views
│   │   └── layouts/
│   └── assets/
│       └── stylesheets/                 # Tailwind CSS
├── config/
│   ├── routes.rb                        # Application routes
│   └── database.yml                     # Database configuration
├── db/
│   └── migrate/                         # Database migrations
└── PRD.md                               # Product Requirements Document
```

## 🗄️ Database Schema

### Settings (Invoice Template)
- Company information (name, address, contact)
- Logo (via Active Storage)
- Default tax rate, currency, payment terms
- Invoice number prefix

### Products (Item Catalog)
- Name (required)
- Description (optional)
- Category (optional, for organization)
- Active status
- Note: No price field - prices are negotiated per client and entered when adding to invoice

### Invoices
- Invoice number (unique, auto-generated)
- Dates (invoice date, due date)
- Client information
- Totals (subtotal, tax, grand total)
- Notes/terms
- Status

### Invoice Items
- Description
- Quantity
- Unit price
- Line total (auto-calculated)
- Product reference (optional - links to Products if added from catalog)
- Position (for ordering)

## 🎨 UI/UX Design

- **Design System:** Tailwind CSS utility classes
- **Color Scheme:** Professional blue/gray palette
- **Responsive:** Works on desktop, tablet, and mobile
- **Accessibility:** Semantic HTML, proper form labels

## 📝 Usage Examples

### Managing Product Catalog

```ruby
# Via UI:
1. Navigate to Products
2. Click "Add New Item"
3. Enter: name, description, category (optional)
4. Save (no price needed - you'll enter it per invoice)

# Items are now available to click when creating invoices
# Prices are entered when adding to invoice (supports negotiation per client)
```

### Creating an Invoice

```ruby
# Via UI:
1. Click "New Invoice"
2. Fill in client details
3. Add items:
   - Option A: Click items from catalog, then enter price (fast!)
   - Option B: Add custom items manually
4. Enter prices for catalog items (negotiate per client)
5. Adjust quantities as needed
6. Save

# Invoice number auto-generates: INV-001, INV-002, etc.
```

### Exporting to PDF

```ruby
# Via UI:
1. View invoice
2. Click "Download PDF"
3. File downloads as: invoice-INV-001.pdf
```

## 🧪 Testing

```bash
# Run tests
rails test

# Run system tests
rails test:system
```

## 🚢 Deployment

The application is configured for deployment with:
- Docker support (Dockerfile included)
- Kamal deployment configuration
- Production-ready database (PostgreSQL recommended)

See `config/deploy.yml` for deployment settings.

## 📚 Documentation

- **PRD.md** - Complete Product Requirements Document with detailed specifications
- **README.md** - This file

## 🤝 Contributing

This is a personal project, but suggestions and improvements are welcome!

## 📄 License

Private project - All rights reserved

## 🐛 Known Issues / Limitations

- Single-user application (no authentication in MVP)
- SQLite3 in development (consider PostgreSQL for production)
- No email sending (future feature)
- No client database (future feature)
- Product categories are basic (advanced categorization in future)

## 🔮 Roadmap

### Phase 1: MVP ✅ (Current)
- Basic invoice CRUD
- Product/item catalog with click-to-add functionality
- PDF generation
- Template management

### Phase 2: Enhancements (Next)
- Invoice duplication
- Advanced search/filtering
- Improved PDF styling

### Phase 3: Future Features
- Client management
- Invoice status tracking
- Email sending
- Multiple templates
- Recurring invoices

## 💡 Tips

- **Product Catalog:** Perfect for small catering businesses! Add all your common menu items once, then just click to add them to invoices
- **Flexible Pricing:** No fixed prices in catalog - enter price per invoice to support price negotiation per client
- **Invoice Numbers:** Automatically increment (INV-001, INV-002, etc.)
- **Calculations:** All totals are auto-calculated - no manual math needed
- **PDFs:** Generated on-the-fly, no storage required
- **Logo:** Upload once, appears on all invoices
- **Duplication:** Use "Duplicate" to quickly create similar invoices
- **Catalog Items:** Click to add items from catalog, then enter the negotiated price for that client

## 📞 Support

For issues or questions, please refer to the PRD.md for detailed specifications.

---

**Built with ❤️ using Ruby on Rails and Tailwind CSS**
