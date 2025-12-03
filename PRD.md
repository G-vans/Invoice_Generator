# Product Requirements Document (PRD)
## Invoice Generator Application

### 1. Executive Summary

**Problem Statement:**
Currently, invoices are created by manually editing a Google Docs template. This process is inefficient because:
- Each edit overwrites the previous invoice (no version history)
- Time-consuming manual data entry
- No centralized invoice management
- Difficult to track invoice numbers and client information
- No easy way to generate PDFs or print invoices

**Solution:**
A web-based invoice generator application that allows users to create, manage, and export professional invoices with a reusable template system. Each invoice is saved independently, eliminating the risk of overwriting previous invoices.

**Target User:**
Primary user: A business owner (mum) who needs to create invoices regularly.
Secondary user: A full-stack developer (son) who helps manage invoices.

---

### 2. Product Goals

**Primary Goals:**
1. Streamline invoice creation process (reduce time from 10+ minutes to < 2 minutes)
2. Preserve all invoice history (no data loss)
3. Generate professional, printable PDF invoices
4. Provide a simple, intuitive user interface

**Success Metrics:**
- Time to create a new invoice: < 2 minutes
- Zero data loss incidents
- 100% of invoices exportable to PDF
- User satisfaction: Easy to use without training

---

### 3. User Stories

#### Epic 1: Invoice Template Management
- **US-1.1:** As a user, I want to upload and store my company logo so that it appears on all invoices
- **US-1.2:** As a user, I want to set my company details (name, address, contact info) once so that they auto-populate on all invoices
- **US-1.3:** As a user, I want to customize invoice settings (tax rate, currency, payment terms) so that they apply to all new invoices

#### Epic 2: Product/Item Catalog Management
- **US-2.1:** As a user, I want to create a catalog of common food items and products so that I can reuse them across invoices
- **US-2.2:** As a user, I want to add items to the catalog with name and description (no fixed price) so that I can quickly add them to invoices and negotiate prices per client
- **US-2.3:** As a user, I want to edit catalog items so that I can update descriptions or names
- **US-2.4:** As a user, I want to delete items from the catalog so that I can remove outdated items
- **US-2.5:** As a user, I want to organize items by category (e.g., "Food Items", "Beverages", "Services") so that I can find them easily
- **US-2.6:** As a user, I want to search/filter catalog items so that I can quickly find specific items

#### Epic 3: Invoice Creation
- **US-3.1:** As a user, I want to create a new invoice from a template so that I don't have to re-enter company details
- **US-3.2:** As a user, I want to add client information (name, address) so that the invoice is properly addressed
- **US-3.3:** As a user, I want to click on items from my catalog to add them to an invoice so that I don't have to type common items repeatedly
- **US-3.4:** As a user, I want to enter the price when adding catalog items so that I can negotiate different prices per client
- **US-3.5:** As a user, I want to manually add custom line items (description, quantity, price) so that I can include one-off items not in my catalog
- **US-3.6:** As a user, I want to adjust quantity when adding catalog items so that I can customize them per invoice
- **US-3.7:** As a user, I want the system to automatically calculate totals (subtotal, tax, grand total) so that I don't make calculation errors
- **US-3.8:** As a user, I want to set an invoice date and due date so that payment terms are clear
- **US-3.9:** As a user, I want automatic invoice numbering so that each invoice has a unique identifier

#### Epic 4: Invoice Management
- **US-4.1:** As a user, I want to view a list of all invoices so that I can see my invoice history
- **US-4.2:** As a user, I want to search/filter invoices by client name, date, or invoice number so that I can find specific invoices quickly
- **US-4.3:** As a user, I want to edit existing invoices (before they're finalized) so that I can correct mistakes
- **US-4.4:** As a user, I want to delete draft invoices so that I can clean up unused invoices
- **US-4.5:** As a user, I want to duplicate an existing invoice so that I can create similar invoices quickly

#### Epic 5: Invoice Export & Printing
- **US-5.1:** As a user, I want to export an invoice as PDF so that I can send it to clients
- **US-5.2:** As a user, I want the PDF to be print-friendly with proper formatting so that it looks professional
- **US-5.3:** As a user, I want to preview the invoice before exporting so that I can verify it looks correct

#### Epic 6: Client Management (Future Enhancement)
- **US-6.1:** As a user, I want to save client information so that I can reuse it for future invoices
- **US-6.2:** As a user, I want to manage a list of clients so that I can select from existing clients when creating invoices

---

### 4. Functional Requirements

#### 4.1 Invoice Template
- **FR-1:** System must allow uploading a company logo (JPG, PNG, SVG formats, max 2MB)
- **FR-2:** System must store company information:
  - Company name (required)
  - Address (optional)
  - Phone number (optional)
  - Email (optional)
  - Website (optional)
- **FR-3:** System must allow configuration of:
  - Default tax rate (percentage, default: 0%)
  - Currency symbol (default: $)
  - Payment terms (default: "Net 30")
  - Invoice number prefix (optional, e.g., "INV-")

#### 4.2 Product/Item Catalog
- **FR-4:** System must allow creating a catalog of reusable products/items with:
  - Name (required, string)
  - Description (optional, text)
  - Category (optional, string, for organization)
  - Note: No fixed price - prices are negotiated per client and entered when adding to invoice
- **FR-5:** System must allow CRUD operations on catalog items (create, read, update, delete)
- **FR-6:** System must allow searching/filtering catalog items by name or category
- **FR-7:** System must display catalog items in an organized, clickable interface

#### 4.3 Invoice Creation
- **FR-8:** System must generate unique invoice numbers (auto-incrementing, e.g., INV-001, INV-002)
- **FR-9:** System must allow entering client information:
  - Client name (required)
  - Client address (optional)
  - Client email (optional)
- **FR-10:** System must allow adding line items in two ways:
  - **Option A:** Click to add items from catalog (pre-fills name/description, user enters price)
  - **Option B:** Manually add custom line items (for items not in catalog)
- **FR-11:** System must support adding unlimited line items with:
  - Description (required, text)
  - Quantity (required, decimal, default: 1)
  - Unit price (required, decimal - always entered by user, even for catalog items)
  - Line total (auto-calculated: quantity × unit price)
- **FR-12:** When adding catalog items, system must:
  - Pre-fill name/description from catalog
  - Require user to enter price (no default price, supports price negotiation per client)
  - Pre-fill quantity as 1 (user can modify)
  - Allow user to edit description if needed
- **FR-13:** System must automatically calculate:
  - Subtotal (sum of all line totals)
  - Tax amount (subtotal × tax rate)
  - Grand total (subtotal + tax)
- **FR-14:** System must allow setting:
  - Invoice date (default: today)
  - Due date (default: invoice date + payment terms days)
- **FR-15:** System must allow adding notes/terms (optional text field)

#### 4.4 Invoice Management
- **FR-16:** System must display a list of all invoices with:
  - Invoice number
  - Client name
  - Invoice date
  - Total amount
  - Status (draft/sent/paid - for future use)
- **FR-17:** System must allow filtering invoices by:
  - Date range
  - Client name (text search)
  - Invoice number (text search)
- **FR-18:** System must allow editing invoices (all fields editable)
- **FR-19:** System must allow deleting invoices with confirmation
- **FR-20:** System must allow duplicating an invoice (creates a new invoice with same data, new invoice number)

#### 4.5 PDF Export
- **FR-21:** System must generate PDF invoices with:
  - Company logo (if uploaded)
  - Company information
  - Client information
  - Invoice number and dates
  - Line items table
  - Totals section
  - Notes/terms (if provided)
- **FR-22:** PDF must be print-friendly (A4 size, proper margins)
- **FR-23:** PDF must be downloadable with filename: `invoice-{invoice_number}.pdf`

#### 4.6 Data Persistence
- **FR-24:** All invoices must be saved to database
- **FR-25:** Invoice template settings must persist across sessions
- **FR-26:** Product catalog items must persist across sessions
- **FR-27:** Logo must be stored securely and accessible for all invoices

---

### 5. Non-Functional Requirements

#### 5.1 Performance
- **NFR-1:** Invoice list page must load in < 1 second
- **NFR-2:** PDF generation must complete in < 3 seconds
- **NFR-3:** Application must support at least 1000 invoices without performance degradation

#### 5.2 Usability
- **NFR-4:** Interface must be intuitive (no training required)
- **NFR-5:** Application must be responsive (works on desktop, tablet, mobile)
- **NFR-6:** Form validation must provide clear error messages
- **NFR-7:** Auto-save draft invoices (optional future enhancement)

#### 5.3 Security
- **NFR-8:** Application must protect against SQL injection
- **NFR-9:** File uploads must be validated (type and size)
- **NFR-10:** No authentication required for MVP (single-user application)

#### 5.4 Compatibility
- **NFR-11:** Must work in modern browsers (Chrome, Firefox, Safari, Edge)
- **NFR-12:** PDFs must be viewable in standard PDF readers

---

### 6. Technical Architecture

#### 6.1 Technology Stack
- **Backend:** Ruby on Rails 8.0.4
- **Database:** SQLite3 (development), PostgreSQL (production-ready)
- **Frontend:** 
  - ERB templates
  - Tailwind CSS for styling
  - Hotwire (Turbo + Stimulus) for interactivity
- **PDF Generation:** Prawn gem (lightweight, Ruby-native)
- **File Storage:** Active Storage (local for development, S3 for production)

#### 6.2 Database Schema

**Settings Table (Invoice Template)**
```
- id (primary key)
- company_name (string, required)
- company_address (text)
- company_phone (string)
- company_email (string)
- company_website (string)
- logo (attachment via Active Storage)
- tax_rate (decimal, default: 0.0)
- currency (string, default: "$")
- payment_terms (string, default: "Net 30")
- invoice_prefix (string, default: "INV-")
- created_at
- updated_at
```

**Invoices Table**
```
- id (primary key)
- invoice_number (string, unique, required)
- invoice_date (date, required)
- due_date (date, required)
- client_name (string, required)
- client_address (text)
- client_email (string)
- subtotal (decimal, required)
- tax_rate (decimal, required)
- tax_amount (decimal, required)
- total (decimal, required)
- notes (text)
- status (string, default: "draft")
- created_at
- updated_at
```

**Products Table (Item Catalog)**
```
- id (primary key)
- name (string, required)
- description (text, optional)
- category (string, optional, e.g., "Food Items", "Beverages", "Services")
- active (boolean, default: true)
- created_at
- updated_at
Note: No price field - prices are negotiated per client and entered when adding to invoice
```

**Invoice Items Table**
```
- id (primary key)
- invoice_id (foreign key, required)
- product_id (foreign key, optional - links to Products if added from catalog)
- description (string, required)
- quantity (decimal, required, default: 1)
- unit_price (decimal, required)
- line_total (decimal, required)
- position (integer, for ordering)
- created_at
- updated_at
```

#### 6.3 Application Structure

**Models:**
- `Setting` - Invoice template/settings (singleton pattern)
- `Product` - Product/item catalog (reusable items)
- `Invoice` - Main invoice model
- `InvoiceItem` - Line items belonging to invoices (can link to Product)

**Controllers:**
- `SettingsController` - Manage invoice template
- `ProductsController` - CRUD operations for product catalog
- `InvoicesController` - CRUD operations for invoices
- `InvoiceItemsController` - Nested resource for line items
- `PdfController` - Handle PDF generation

**Views:**
- Settings: `index`, `edit`
- Products: `index`, `new`, `edit` (catalog management)
- Invoices: `index`, `show`, `new`, `edit` (with catalog item selector)
- PDF: `show` (PDF format)

**Routes:**
```
GET    /                              => invoices#index
GET    /invoices                      => invoices#index
GET    /invoices/new                  => invoices#new
POST   /invoices                      => invoices#create
GET    /invoices/:id                  => invoices#show
GET    /invoices/:id/edit             => invoices#edit
PATCH  /invoices/:id                  => invoices#update
DELETE /invoices/:id                  => invoices#destroy
POST   /invoices/:id/duplicate        => invoices#duplicate
GET    /invoices/:id.pdf              => invoices#show (PDF format)

GET    /products                      => products#index
GET    /products/new                  => products#new
POST   /products                      => products#create
GET    /products/:id/edit             => products#edit
PATCH  /products/:id                  => products#update
DELETE /products/:id                  => products#destroy

GET    /settings                      => settings#index
GET    /settings/edit                 => settings#edit
PATCH  /settings                      => settings#update
```

---

### 7. User Interface Design

#### 7.1 Design Principles
- Clean, minimal design
- Professional appearance
- Mobile-responsive
- Tailwind CSS utility classes
- Consistent color scheme (professional blue/gray palette)

#### 7.2 Key Pages

**Dashboard (Invoice List)**
- Header with "New Invoice" button
- Search/filter bar
- Table of invoices (responsive cards on mobile)
- Actions: View, Edit, Duplicate, Delete, Download PDF

**Product Catalog Page**
- List of all catalog items (grouped by category if used)
- Search/filter bar
- "Add New Item" button
- Each item shows: name, description, default price, category
- Actions: Edit, Delete
- Grid or list view (responsive)

**Invoice Form**
- Two-column layout (desktop)
- Left: Client information
- Right: Invoice details (dates, invoice number)
- **Product Catalog Selector:**
  - Searchable list of catalog items
  - Click to add item (opens form/modal)
  - Shows item name and description (no price shown)
  - User must enter price (supports price negotiation per client)
  - User can adjust quantity (default: 1)
- Line items table with add/remove buttons
- "Add Custom Item" button (for items not in catalog)
- Auto-calculating totals section
- Notes field
- Save and Preview buttons

**Invoice Preview/Show**
- Invoice display matching PDF layout
- Download PDF button
- Edit button
- Print-friendly styling

**Settings Page**
- Logo upload with preview
- Company information form
- Invoice defaults (tax rate, currency, etc.)
- Save button

---

### 8. Implementation Phases

#### Phase 1: MVP (Minimum Viable Product)
1. Database setup (migrations)
2. Settings model and controller (template management)
3. Product model and controller (item catalog)
4. Invoice and InvoiceItem models
5. Basic invoice CRUD
6. Product catalog integration (click to add items)
7. PDF generation
8. Simple UI with Tailwind CSS

#### Phase 2: Enhancements
1. Invoice duplication
2. Search and filtering
3. Improved PDF styling
4. Form validation and error handling
5. Responsive design polish

#### Phase 3: Future Features (Out of Scope for MVP)
1. Client management (reusable client database)
2. Invoice status tracking (draft/sent/paid)
3. Email sending
4. Multiple templates
5. Recurring invoices
6. Reports and analytics
7. User authentication (multi-user support)

---

### 9. Acceptance Criteria

**AC-1: Template Setup**
- User can upload logo and see preview
- User can save company information
- Settings persist after page refresh

**AC-2: Product Catalog**
- User can add items to catalog (name, description - no price)
- User can view all catalog items
- User can edit catalog items
- User can delete catalog items
- User can search/filter catalog items

**AC-3: Invoice Creation**
- User can create new invoice
- Invoice number auto-generates
- User can click catalog items to add them to invoice
- When adding catalog items, user must enter price (no default price, supports negotiation)
- User can adjust quantity when adding catalog items
- User can manually add custom line items (not in catalog)
- Totals calculate automatically
- Invoice saves successfully

**AC-4: Invoice Management**
- User can view list of all invoices
- User can edit existing invoice
- User can delete invoice with confirmation
- User can duplicate invoice

**AC-5: PDF Export**
- User can download invoice as PDF
- PDF contains all invoice information
- PDF is properly formatted and print-friendly
- PDF filename includes invoice number

**AC-6: Data Integrity**
- No invoices are lost when creating new ones
- Each invoice has unique invoice number
- Calculations are always accurate
- Catalog items persist and can be reused

---

### 10. Out of Scope (MVP)

- User authentication/login
- Multi-user support
- Client database/reusable clients (moved to future)
- Invoice status workflow
- Email sending
- Payment tracking
- Reports and analytics
- Recurring invoices
- Multiple templates
- Invoice numbering customization (beyond prefix)
- Internationalization (i18n)
- Dark mode
- Product categories (basic version in MVP, advanced categorization later)
- Product images
- Inventory tracking

---

### 11. Risks and Mitigations

**Risk 1:** PDF generation performance issues
- *Mitigation:* Use lightweight Prawn gem, test with large invoices

**Risk 2:** File storage limitations (logo)
- *Mitigation:* Implement file size validation, use Active Storage

**Risk 3:** Data loss
- *Mitigation:* Regular database backups, clear save/delete confirmations

**Risk 4:** Complex calculations errors
- *Mitigation:* Use decimal types, test edge cases, show calculation breakdown

---

### 12. Success Criteria

The application is considered successful when:
1. User can create a complete invoice in under 2 minutes
2. All invoices are preserved (no data loss)
3. PDFs are generated correctly and look professional
4. User can find and manage invoices easily
5. Application is stable and bug-free for daily use

---

**Document Version:** 1.0  
**Last Updated:** 2024  
**Status:** Ready for Implementation

