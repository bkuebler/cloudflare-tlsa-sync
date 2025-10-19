# Contributing Guidelines

Thank you for your interest in Cloudflare TLSA Sync!

To report bugs, suggest improvements, propose new alert hooks, or contribute code, please observe the following:

1. **Coding Style:**
   - Use Bash ≥ 4; prefer POSIX-compatible constructs where possible.
   - Comment your code for clarity.
   - Use shellcheck for linting your scripts

2. **Hooks:**
   - For new alert hooks, include a minimal, documented Bash script and a short README inside the script is enough.

3. **Issues:**
   - Please include a relevant excerpt from the log (`journalctl -t tlsa-cloudflare-sync` if on systemd).
   - Indicate affected config/domain/port/record (unless confidential).
   - State your script version, Bash version, OS/distribution (if relevant).

4. **Merge Requests/PRs:**
   - Use clear commit messages.
   - For major behavioral or architectural changes, please discuss via issue before submitting a PR.

5. **License & Attribution:**
   - By submitting code, you agree to license your contributions under the terms of the GNU General Public License, version 3 or later (GPLv3+).
   - Please add an author notice to your code.

6. **Security:**
   - Never post API tokens, certificate material or passwords in issues or PRs!

For major feature work, new interfaces, or complex hook systems, please open an issue/feature request first to discuss the integration.

Thank you for your interest and support!
