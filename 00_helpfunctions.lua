function CleanupText(text)
    return text:gsub("^%[([^#%]]+)[#%d]*%]$", "%1")
end