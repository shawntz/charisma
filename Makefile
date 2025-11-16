.PHONY: all document build check install test clean format readme logo favicon vignettes pkgdown rebuild

# Default target - clean rebuild with all documentation
all: rebuild

# Complete rebuild: clean, regenerate all docs, build site
rebuild:
	@echo "======================================"
	@echo "Starting complete rebuild..."
	@echo "======================================"
	@$(MAKE) clean
	@$(MAKE) document
	@$(MAKE) readme
	@$(MAKE) pkgdown
	@echo "======================================"
	@echo "Rebuild complete!"
	@echo "View site at: docs/index.html"
	@echo "======================================"

# Generate documentation from roxygen2 comments
document:
	@echo "Generating documentation..."
	Rscript -e "devtools::document()"

# Build the package
build:
	@echo "Building package..."
	R CMD build .

# Run R CMD check
check:
	@echo "Running R CMD check..."
	Rscript -e "devtools::check()"
	@echo "Cleaning up check artifacts..."
	rm -rf *.Rcheck/
	rm -rf *.tar.gz

# Install the package locally
install:
	@echo "Installing package..."
	Rscript -e "devtools::install()"

# Run tests
test:
	@echo "Running tests..."
	Rscript -e "devtools::test()"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf *.tar.gz
	rm -rf *.Rcheck/
	rm -rf man/*.Rd
	rm -rf docs/
	rm -rf README.html

# Format R code with air
format:
	@echo "Formatting R code with air..."
	air format .

# Generate README.md from README.Rmd
readme:
	@echo "Generating README.md..."
	Rscript -e "rmarkdown::render('README.Rmd', output_file = 'README.md', clean = TRUE)"
	@rm -f README.html

# Create hex logo
logo:
	@echo "Creating hex logo..."
	Rscript man/figures/create_logo.R

# Generate favicons from logo
favicon:
	@echo "Generating favicons..."
	Rscript -e "pkgdown::build_favicons(pkg = '.', overwrite = TRUE)"

# Build vignettes
vignettes:
	@echo "Building vignettes..."
	Rscript -e "devtools::build_vignettes()"

# Build pkgdown site
pkgdown:
	@echo "Building pkgdown site..."
	Rscript -e "pkgdown::build_site()"

# Run CRAN check with --as-cran flag
cran-check:
	@echo "Running CRAN check..."
	R CMD build .
	R CMD check --as-cran *.tar.gz
	@echo "Cleaning up check artifacts..."
	rm -rf *.Rcheck/
	rm -rf *.tar.gz

# Full CRAN submission prep
cran-prep: clean document test check readme vignettes pkgdown
	@echo "Package is ready for CRAN submission!"
	@echo "Don't forget to:"
	@echo "  1. Update NEWS.md"
	@echo "  2. Update cran-comments.md"
	@echo "  3. Run make cran-check"

# Quick development cycle
dev: document install test
	@echo "Development cycle complete!"

# Help target
help:
	@echo "Available targets:"
	@echo "  all        - Complete rebuild: clean + docs + readme + pkgdown (default)"
	@echo "  rebuild    - Same as 'all' - complete clean rebuild"
	@echo "  document   - Generate documentation from roxygen2"
	@echo "  build      - Build the package tarball"
	@echo "  check      - Run R CMD check (with cleanup)"
	@echo "  install    - Install package locally"
	@echo "  test       - Run testthat tests"
	@echo "  clean      - Remove build artifacts"
	@echo "  format     - Format R code with air"
	@echo "  readme     - Generate README.md from README.Rmd"
	@echo "  logo       - Create hex logo"
	@echo "  favicon    - Generate favicons from logo"
	@echo "  vignettes  - Build vignettes"
	@echo "  pkgdown    - Build pkgdown website"
	@echo "  cran-check - Run R CMD check --as-cran (with cleanup)"
	@echo "  cran-prep  - Full CRAN submission preparation"
	@echo "  dev        - Quick development cycle (doc + install + test)"
	@echo "  help       - Show this help message"
