# Linting Setup Guide

This project uses linting tools to maintain code quality and consistency.

## Available Linters

### 1. RuboCop (Ruby)
RuboCop is configured for Ruby code using the Rails Omakase style guide.

**Run RuboCop:**
```bash
bundle exec rubocop
```

**Auto-fix issues:**
```bash
bundle exec rubocop -a
```

**Check specific files:**
```bash
bundle exec rubocop app/models/invoice.rb
```

### 2. ESLint (JavaScript)
ESLint is configured for JavaScript/Stimulus controllers.

**Run ESLint:**
```bash
npm run lint:js
```

**Auto-fix issues:**
```bash
npm run lint:js:fix
```

## NPM Scripts

The following scripts are available in `package.json`:

- `npm run lint:js` - Lint JavaScript files
- `npm run lint:js:fix` - Auto-fix JavaScript linting issues
- `npm run lint:ruby` - Lint Ruby files with RuboCop
- `npm run lint:ruby:fix` - Auto-fix Ruby linting issues
- `npm run lint` - Run both JavaScript and Ruby linters
- `npm run lint:fix` - Auto-fix both JavaScript and Ruby issues

## Configuration Files

- `.rubocop.yml` - RuboCop configuration (uses Rails Omakase)
- `eslint.config.js` - ESLint configuration
- `.rubocop_todo.yml` - Tracks RuboCop offenses being gradually fixed

## IDE Integration

### VS Code / Cursor

Install these extensions:
- **Ruby**: `Shopify.ruby-lsp` or `rebornix.Ruby`
- **ESLint**: `dbaeumer.vscode-eslint`

The linters will run automatically on save if configured in your editor settings.

### Running Linters

### Quick Commands

The easiest way to run linters is using the `bin/lint` script:

```bash
# Run all linters
bin/lint

# Auto-fix all issues
bin/lint:fix
```

### Alternative Commands

You can also use npm scripts or direct commands:

```bash
# Lint everything (npm script)
npm run lint

# Auto-fix everything (npm script)
npm run lint:fix

# Lint only Ruby
bundle exec rubocop

# Lint only JavaScript
npm run lint:js
```

## Automatic Linting

Linting does **NOT** run automatically by default. You have several options:

### Option 1: IDE Integration (Recommended)
Install linting extensions in your IDE (VS Code/Cursor):
- **ESLint extension** - Runs automatically on save
- **Ruby LSP** - Provides inline linting

### Option 2: Pre-commit Hooks
Set up Git hooks to run linters before commits (see below)

### Option 3: CI/CD Pipeline
Add linting to your deployment pipeline

## Pre-commit Hooks (Optional)

To automatically run linters before committing, you can set up a pre-commit hook:

### Simple Git Hook

```bash
# Create .git/hooks/pre-commit
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
bin/lint
EOF

chmod +x .git/hooks/pre-commit
```

### Using Overcommit (Ruby-focused)

```bash
gem install overcommit
overcommit --install
```

Then add to `.overcommit.yml`:
```yaml
PreCommit:
  RuboCop:
    enabled: true
  ExecuteCommand:
    enabled: true
    required: true
    commands:
      - command: 'npm run lint:js'
        name: 'ESLint'
```

### Using Husky (Node-focused)

```bash
npm install --save-dev husky
npx husky init
```

Then add to `.husky/pre-commit`:
```bash
npm run lint
```

