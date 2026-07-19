-- See: https://github.com/mason-org/mason.nvim/issues/1300#issuecomment-1555105398

local github_proxy_url = os.getenv("GITHUB_PROXY_URL")

return {
  "mason-org/mason.nvim",
  opts = {
    -- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
    -- multiple registries, the registry listed first will be used.
    registries = {
      "github:mason-org/mason-registry@2026-07-18-pesky-mink",
    },

    -- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
    -- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
    -- Builtin providers are:
    --   - mason.providers.registry-api  - uses the https://api.mason-registry.dev API
    --   - mason.providers.client        - uses only client-side tooling to resolve metadata
    providers = {
      "mason.providers.client",
    },

    github = {
      -- The template URL to use when downloading assets from GitHub.
      -- The placeholders are the following (in order):
      -- 1. The repository (e.g. "rust-lang/rust-analyzer")
      -- 2. The release version (e.g. "v0.3.0")
      -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
      download_url_template = github_proxy_url .. "/%s/releases/download/%s/%s",
    },
  }
}
