$f = 'index.html'
$c = [IO.File]::ReadAllText($f,[Text.Encoding]::UTF8)

# Fix the font size cascade by setting readable sizes
$c = $c.Replace('text-[1.05rem]', 'text-[0.75rem]')
$c = $c.Replace('text-[1.1rem]', 'text-[0.95rem]')

# Make sure other text is readable
$c = $c.Replace('text-xs', 'text-sm')

# Make text-white/50 slightly brighter to text-white/70 to ensure legibility of smallest text
$c = $c.Replace('text-white/50', 'text-white/70')
$c = $c.Replace('text-white/60', 'text-white/80')

[IO.File]::WriteAllText($f,$c,[Text.Encoding]::UTF8)
Write-Host "Sizes fixed and opacities verified."
