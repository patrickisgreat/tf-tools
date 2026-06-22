// Conventional Commits enforcement. Linted on PRs by
// .github/workflows/commitlint.yml. See CLAUDE.md "Git workflow" for the rules.
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Allow a slightly longer header for scoped module commits.
    "header-max-length": [2, "always", 100],
  },
};
