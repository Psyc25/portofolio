

$f = 'index.html'
$c = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
$c = $c.Replace("`r`n", "`n")

# Skills grid gap
$c = $c.Replace('grid sm:grid-cols-2 lg:grid-cols-3 gap-4', 'grid sm:grid-cols-2 lg:grid-cols-3 gap-5')

# Skill card classes
$c = $c.Replace('"hover-card rounded-sm bg-surface/40 p-5 reveal">', '"glass-card p-6 reveal group">')
$c = $c.Replace('"hover-card rounded-sm bg-surface/40 p-5 reveal reveal-delay-1">', '"glass-card p-6 reveal reveal-delay-1 group">')
$c = $c.Replace('"hover-card rounded-sm bg-surface/40 p-5 reveal reveal-delay-2">', '"glass-card p-6 reveal reveal-delay-2 group">')
$c = $c.Replace('"hover-card rounded-sm bg-surface/40 p-5 reveal reveal-delay-3">', '"glass-card p-6 reveal reveal-delay-3 group">')

# Wrap skill icons in icon-glow
$icons = @('mdi:clipboard-check-outline', 'mdi:wrench-outline', 'mdi:package-variant-closed', 'mdi:account-supervisor-outline', 'mdi:headset', 'mdi:code-braces')
foreach ($ic in $icons) {
    $old = "<iconify-icon icon=`"$ic`" class=`"text-accent/35 text-xl mb-3`"></iconify-icon>"
    $new = "<div class=`"icon-glow mb-4`"><iconify-icon icon=`"$ic`" class=`"text-accent text-xl`"></iconify-icon></div>"
    $c = $c.Replace($old, $new)
}

# Update p class in skill cards and add progress bars
$skills = @(
    @('Product inspection, defect identification, and quality standard enforcement.', '85'),
    @('Team leadership, maintenance coordination, and operational troubleshooting.', '80'),
    @('Inventory management, invoice processing, stock opname, and delivery coordination.', '92'),
    @('Performance monitoring, task delegation, and team guidance for improved efficiency.', '83'),
    @('Client communication, inquiry handling, and service-oriented problem solving.', '88'),
    @('Currently studying programming, algorithms, and software engineering principles.', '65')
)
foreach ($sk in $skills) {
    $desc = $sk[0]; $pct = $sk[1]
    $bar = "`n                    <div class=`"skill-track`"><div class=`"skill-fill`" style=`"--sw:${pct}%`"></div></div>`n                    <div class=`"flex justify-between mt-1.5`"><span class=`"font-mono text-[0.44rem] tracking-[0.15em] uppercase text-white/20`">Proficiency</span><span class=`"font-mono text-[0.44rem] text-accent/55`">${pct}%</span></div>"
    $old = "<p class=`"text-[0.75rem] text-white/25 leading-relaxed`">$desc</p>"
    $new = "<p class=`"text-[0.72rem] text-white/30 leading-relaxed mb-5`">$desc</p>$bar"
    $c = $c.Replace($old, $new)
}

# Contact: replace displayed data with "Tap to open" 
$nums = @('0856 9300 9756', 'salvanandos.123@gmail.com', '@psyc.25')
foreach ($n in $nums) {
    $c = [regex]::Replace($c, "<p class=`"text-\[0\.8rem\][^`"]*`">" + [regex]::Escape($n) + "</p>", '<p class="text-[0.72rem] text-white/25 group-hover:text-accent/50 transition-colors duration-300">Tap to open &rarr;</p>')
}

# Remove address card
$c = [regex]::Replace($c, '(?s)<!-- Address -->.*?</div>\s*</div>\s*</div>', '')

# Photo 3D
$c = $c.Replace('<div class="relative group">', '<div class="relative group photo-wrap">', 1)
$c = $c.Replace('"aspect-[3/4] rounded-sm overflow-hidden relative"', '"aspect-[3/4] rounded-sm overflow-hidden relative photo-inner"')

# Add photo CSS before </style>
$photoCss = "        .photo-wrap{perspective:900px}
        .photo-inner{transform-style:preserve-3d;animation:ph3d 7s ease-in-out infinite;position:relative}
        @keyframes ph3d{0%,100%{transform:rotateY(-10deg) rotateX(5deg) translateY(0)}50%{transform:rotateY(-5deg) rotateX(2deg) translateY(-12px)}}
        .photo-inner::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(103,232,249,0.18) 0%,transparent 45%,rgba(167,139,250,0.1) 100%);z-index:2;mix-blend-mode:screen;pointer-events:none}"
$c = $c.Replace("    </style>", $photoCss + "`n    </style>")

# Add skill bar JS
$skillJs = "        /* skill bars */
        const sfObs=new IntersectionObserver(entries=>{entries.forEach(e=>{if(e.isIntersecting){e.target.querySelectorAll('.skill-fill').forEach(b=>b.classList.add('on'));sfObs.unobserve(e.target);}})},{threshold:0.2});
        document.querySelectorAll('.glass-card').forEach(c=>sfObs.observe(c));"
$c = $c.Replace("        /* -- Year -- */", $skillJs + "`n        /* -- Year -- */")
$c = $c.Replace("        /* Year */", $skillJs + "`n        /* Year */")
$c = $c.Replace("        /* -- Year -- */", $skillJs + "`n        /* -- Year -- */")

# Find year JS more robustly
if (!$c.Contains($skillJs)) {
    $c = $c.Replace("document.getElementById('yr')", $skillJs + "`n        document.getElementById('yr')")
}

$c = $c.Replace("`n", "`r`n")
[IO.File]::WriteAllText($f, $c, [Text.Encoding]::UTF8)
Write-Host "Done!"
