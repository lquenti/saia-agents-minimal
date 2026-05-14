# Changelog

All notable changes to the Advanced Coding Agent project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-05-15

### Added
- Comprehensive test suite (28 script tests + 10 Docker tests)
- AGENTS.md templates (generic + Python/uv)
- Python-based HTML generator for GitLab Pages
- Usage Guide documentation
- Debugging Guide documentation
- Architecture Guide documentation
- Project Structure documentation
- Runtime Comparison documentation
- Testing Guide documentation
- Shell alias support in start scripts
- .env validation in start scripts
- Dockerfile existence checks in build scripts
- Code review document (REVIEW.md)

### Changed
- Removed docker-compose.yml (single-container deployment)
- Separated build and start scripts
- Consolidated Dockerfiles to root directory
- Removed duplicate Dockerfiles from subdirectories
- Moved advanced usage into Quick Start section
- Restructured documentation (moved detailed content to docs/)
- Cleaned up .gitignore (removed commented sections)
- Optimized .dockerignore
- Updated HEALTHCHECK commands
- Fixed skills directory structure in Dockerfiles

### Removed
- docker-compose.yml
- stop-opencode.sh, stop-openclaude.sh
- Duplicate Dockerfiles from opencode/ and openclaude/ subfolders
- Node.js dependencies (package.json, package-lock.json)
- convert-to-html.js (replaced with Python)
- node_modules from repository
- npm installation from Dockerfiles
- OpenCode/OpenClaude CLI placeholder installations

### Fixed
- HEALTHCHECK commands (pgrep not available in Ubuntu)
- Memory directory path inconsistency
- Skills directory structure in Dockerfiles
- Missing .env validation
- Build script error handling
- node_modules committed to git history

## [1.0.0] - 2026-05-14

### Added
- Initial release
- OpenCode runtime support
- OpenClaude runtime support
- 45+ pre-installed skills
- Security hardening (non-root user, read-only filesystem)
- AGENTS.md memory system
- GitLab Pages CI/CD pipeline
- Raindrop.io sync integration
- Linkding bookmark synchronization

---

## Version Guidelines

### [Major] - Breaking changes
- API changes that break existing workflows
- Removal of features
- Architecture changes

### [Minor] - New features
- New skills
- New documentation
- New scripts
- Feature enhancements

### [Patch] - Bug fixes
- Bug fixes
- Documentation updates
- Performance improvements

---

## Unreleased

### To Be Documented
- (Add upcoming changes here)
