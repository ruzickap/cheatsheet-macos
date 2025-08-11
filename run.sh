#!/usr/bin/env bash

# LaTeX Document Builder
# This script builds LaTeX documents using Docker with TeXLive Full
# It compiles documents into multiple formats (PDF, JPG, PNG, SVG) and cleans up temporary files

set -euo pipefail

# Configuration
DOCKER_IMAGE="${LATEX_DOCKER_IMAGE:-ghcr.io/xu-cheng/texlive-full}"
MAKE_TARGETS="${LATEX_MAKE_TARGETS:-jpg pdf png svg mostlyclean}"
WORKING_DIR="/mnt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to check if command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Function to show usage
show_usage() {
  cat << EOF
Usage: $0 [OPTIONS] [MAKE_TARGETS...]

This script builds LaTeX documents using Docker with TeXLive Full.

OPTIONS:
    -h, --help          Show this help message
    -i, --image IMAGE   Docker image to use (default: ${DOCKER_IMAGE})
    -v, --verbose       Enable verbose output

ENVIRONMENT VARIABLES:
    LATEX_DOCKER_IMAGE     Docker image to use
    LATEX_MAKE_TARGETS     Make targets to run (default: ${MAKE_TARGETS})

EXAMPLES:
    $0                            # Build with default targets
    $0 pdf                        # Build only PDF
    $0 -i custom/texlive pdf png  # Use custom image and specific targets
    $0 --verbose pdf              # Build PDF with verbose output

EOF
}

# Parse command line arguments
VERBOSE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -h | --help)
      show_usage
      exit 0
      ;;
    -i | --image)
      DOCKER_IMAGE="$2"
      shift 2
      ;;
    -v | --verbose)
      VERBOSE=true
      shift
      ;;
    -*)
      print_error "Unknown option: $1"
      show_usage
      exit 1
      ;;
    *)
      # Remaining arguments are make targets
      MAKE_TARGETS="$*"
      break
      ;;
  esac
done

# Enable verbose mode if requested
if [[ "$VERBOSE" == "true" ]]; then
  set -x
fi

# Display configuration
print_info "Configuration:"
echo "  Docker Image: ${DOCKER_IMAGE}"
echo "  Make Targets: ${MAKE_TARGETS}"
echo "  Working Directory: ${PWD}"

# Pull/update Docker image if needed
print_info "Checking Docker image..."
if ! docker image inspect "${DOCKER_IMAGE}" > /dev/null 2>&1; then
  print_info "Docker image not found locally, pulling..."
  docker pull "${DOCKER_IMAGE}"
else
  print_info "Docker image found locally"
fi

# Build the documents
print_info "Starting LaTeX document build..."

# Create the container script that installs packages and runs make
CONTAINER_SCRIPT="
#!/bin/bash
set -euxo pipefail

# Install required packages
echo 'Installing poppler-utils...'
apk add --no-cache poppler-utils

# Run make targets
echo 'Running make targets: ${MAKE_TARGETS}'
exec make ${MAKE_TARGETS}
"

# Run the Docker container as root to allow package installation
if docker run --rm \
  --volume "${PWD}:${WORKING_DIR}" \
  --workdir "${WORKING_DIR}" \
  "${DOCKER_IMAGE}" \
  bash -c "${CONTAINER_SCRIPT}"; then

  print_success "LaTeX document build completed successfully!"

  # Show generated files
  print_info "Generated files:"
  find . -maxdepth 1 \( -name "*.pdf" -o -name "*.jpg" -o -name "*.png" -o -name "*.svg" \) -newer Makefile 2> /dev/null | sort || true

else
  print_error "LaTeX document build failed!"
  exit 1
fi
