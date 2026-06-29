# Test: polish
mode: run
trigger: /polish check
setup:
  files:
    - package.json: |
        {
          "name": "polish-sandbox",
          "scripts": {
            "check": "node -e \"process.exit(0)\"",
            "lint": "node -e \"process.exit(0)\"",
            "format:check": "node -e \"process.exit(0)\""
          }
        }
confirm: yes
expect:
  - skill ran without error and reported a verdict
  - working tree clean (no file modified — read-only without --fix)
  - commits == 1   # only the sandbox's initial commit; polish never commits
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
