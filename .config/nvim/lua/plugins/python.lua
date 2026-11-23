-- Files in lua/plugins/ are loaded automatically by lazy.nvim.
return {
  -- Python extra: Pyright (errors + completion), Ruff (lint/format), syntax.
  { import = "lazyvim.plugins.extras.lang.python" },
}
