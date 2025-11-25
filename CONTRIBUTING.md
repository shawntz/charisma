# Contributing to charisma

Thank you for your interest in contributing to `charisma`! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Bugs

- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) when opening an issue
- Include a minimal reproducible example
- Provide your session info with `sessionInfo()`
- Check existing issues to avoid duplicates

### Suggesting Features

- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) when opening an issue
- Clearly describe the use case and motivation
- Consider alternative approaches

### Code Contributions

1. **Fork the repository** and clone your fork
2. **Create a branch** for your changes:
   ```bash
   git checkout -b your-feature-name
   ```
3. **Make your changes** following the coding standards below
4. **Write or update tests** for new functionality
5. **Update documentation** if needed (roxygen comments, vignettes)
6. **Run checks** locally before submitting:
   ```r
   devtools::check()
   ```
7. **Commit your changes** with clear, descriptive commit messages
8. **Push to your fork** and open a pull request

## Coding Standards

### R Code Style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use `roxygen2` for function documentation
- Keep lines under 80 characters when possible
- Use meaningful variable and function names

### Documentation

- All exported functions must have complete roxygen documentation
- Include examples in documentation when possible
- Update `NEWS.md` with user-facing changes

### Testing

- Write tests for new functionality using `testthat`
- Aim for good test coverage
- Tests should be fast and independent
- Run `devtools::test()` to verify all tests pass

### Git Workflow

- Write clear, descriptive commit messages
- Keep commits focused on a single change
- Reference issue numbers in commit messages when applicable

## Pull Request Process

1. Ensure your code passes all checks (`devtools::check()`)
2. Update documentation as needed
3. Add tests for new functionality
4. Update `NEWS.md` with a brief description of changes
5. Fill out the pull request template completely
6. Ensure the PR description clearly explains:
   - What changed
   - Why it changed
   - How to test the changes

## Development Setup

### System Dependencies

Install required system libraries:

**macOS (via Homebrew):**

```bash
brew install udunits gdal proj geos
```

**Ubuntu/Debian:**

```bash
sudo apt-get install libudunits2-dev libgdal-dev libgeos-dev libproj-dev
```

**Fedora/RedHat:**

```bash
sudo dnf install udunits2-devel gdal-devel geos-devel proj-devel
```

### R Dependencies

Install development dependencies:

```r
devtools::install_dev_deps()
```

### Building Documentation

```r
devtools::document()  # Update roxygen documentation
devtools::build_readme()  # Rebuild README.md from README.Rmd
```

## Questions?

If you have questions about contributing, feel free to:

- Open an issue with the `question` label
- Check existing documentation and vignettes
- Review existing code for examples

Thank you for contributing to `charisma`!
