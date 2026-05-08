local function apply_theme()
  local ok, theme = pcall(require, "themes.init")
  if not ok then
    vim.schedule(function()
      vim.notify("Theme configuration not found", vim.log.levels.WARN)
    end)
    return
  end

  if theme.setup then
    theme.setup()
  end
end

return { setup = apply_theme }
