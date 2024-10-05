#!/bin/bash

# Check if running in GitHub Actions
if [ -n "$GITHUB_REF" ]; then
  # Extract the branch name from GITHUB_REF
  BRANCH_NAME=${GITHUB_REF##*/}
else
  # Get the branch name from Git
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Output the branch name in JSON format
echo "{\"branch_name\": \"${BRANCH_NAME}\"}"
