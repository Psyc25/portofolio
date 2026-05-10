import re

with open('index.html', 'r', encoding='utf-8') as f:
    c = f.read()

# 1. Skills grid: gap-4 -> gap-5
c = c.replace('grid sm:grid-cols-2 lg:grid-cols-3 gap-4', 'grid sm:grid-cols-2 lg:grid-cols-3 gap-5')

# 2. Replace skill cards with glass-card + progress bars
CARDS = [
    ('mdi:clipboard-check-outline','text-accent/35','Quality Assurance','Product inspection, defect identification, and quality standard enforcement.','','85','reveal'),
    ('mdi:wrench-outline','text-accent/35','Mechanical Supervision','Team leadership, maintenance coordination, and operational troubleshooting.','','80','reveal reveal-delay-1'),
    ('mdi:package-variant-closed','text-accent/35','Admin &amp; Operations','Inventory management, invoice processing, stock opname &amp; delivery coordination.','','92','reveal reveal-delay-2'),
    ('mdi:account-supervisor-outline','text-accent/35','Team Leadership','Performance monitoring, task delegation, and team guidance for improved efficiency.','','83','reveal reveal-delay-1'),
    ('mdi:headset','text-accent/35','Customer Service','Client communication, inquiry handling, and service-oriented problem solving.','','88','reveal reveal-delay-2'),
    ('mdi:code-braces','text-accent/35','Informatics Engineering','Currently studying programming, algorithms, and software engineering principles.','','65','reveal reveal-delay-3'),
]

for icon,_,title,desc,_2,pct,rev in CARDS:
    # old card pattern
    old = re.compile(
        r'<div class="hover-card rounded-sm bg-surface/40 p-5 ' + re.escape(rev) + r'">\s*'
        r'<iconify-icon icon="' + re.escape(icon) + r'"[^/]*/>\s*'
        r'<h4[^>]*>[^<]*</h4>\s*'
        r'<p[^>]*>[^<]*</p>\s*'
        r'</div>',
        re.DOTALL
    )
    new = (
        f'<div class="glass-card p-6 {rev} group">'
        f'<div class="icon-glow mb-4"><iconify-icon icon="{icon}" class="text-accent text-xl"></iconify-icon></div>'
        f'<h4 class="font-display text-[0.95rem] font-semibold text-white/82 mb-2">{title}</h4>'
        f'<p class="text-[0.72rem] text-white/30 leading-relaxed mb-5">{desc}</p>'
        f'<div class="skill-track"><div class="skill-fill" style="--sw:{pct}%"></div></div>'
        f'<div class="flex justify-between mt-1.5">'
        f'<span class="font-mono text-[0.44rem] tracking-[0.15em] uppercase text-white/20">Proficiency</span>'
        f'<span class="font-mono text-[0.44rem] text-accent/55">{pct}%</span></div>'
        f'</div>'
    )
    c, n = old.subn(new, c)
    print(f'{"OK" if n else "MISS"}: {title}')

# 3. Contact: hide displayed text, show only icon links
# Remove address card (no link)
c = re.sub(r'<!-- Address -->.*?</div>\s*</div>\s*</div>', '', c, flags=re.DOTALL)
# Remove phone/email/number text from contact cards (keep links but remove p tags with actual data)
c = re.sub(r'(<div class="min-w-0">.*?<div[^>]*>(?:WhatsApp|Phone|Email|Instagram|TikTok)[^<]*</div>)\s*<p[^>]*>[^<]*</p>', r'\1', c, flags=re.DOTALL)

# 4. Photo: add 3D classes
c = c.replace('aspect-[3/4] rounded-sm overflow-hidden relative', 'aspect-[3/4] rounded-sm overflow-hidden relative photo-inner')
c = c.replace('<div class="relative group">', '<div class="relative group photo-wrap">', 1)
c = c.replace('class="w-full h-full object-cover grayscale opacity-60 group-hover:grayscale-0 group-hover:opacity-85 transition-all duration-[1.2s]"',
              'class="w-full h-full object-cover grayscale-[0.3] opacity-75 group-hover:grayscale-0 group-hover:opacity-90 transition-all duration-[1.2s]"')

# 5. Add skill-fill JS observer before closing script
skill_js = """
        /* skill bars */
        const sfObs = new IntersectionObserver(entries => {
            entries.forEach(e => { if(e.isIntersecting) { e.target.querySelectorAll('.skill-fill').forEach(b=>b.classList.add('on')); sfObs.unobserve(e.target); } });
        },{threshold:0.2});
        document.querySelectorAll('.glass-card').forEach(c=>sfObs.observe(c));
"""
c = c.replace("document.getElementById('yr').textContent", skill_js + "\n        document.getElementById('yr').textContent")

# 6. Add 3D photo CSS before </style>
photo_css = """
        .photo-wrap { perspective: 900px; }
        .photo-inner { transform-style: preserve-3d; animation: ph3d 7s ease-in-out infinite; }
        @keyframes ph3d { 0%,100%{transform:rotateY(-10deg) rotateX(5deg) translateY(0)} 50%{transform:rotateY(-5deg) rotateX(2deg) translateY(-12px)} }
        .photo-inner::after { content:''; position:absolute; inset:0; background:linear-gradient(135deg,rgba(103,232,249,0.14) 0%,transparent 45%,rgba(167,139,250,0.08) 100%); z-index:2; mix-blend-mode:screen; pointer-events:none; }
"""
c = c.replace('        /* ── Backdrop on existing hover-cards ── */\n        .hover-card {\n            backdrop-filter: blur(8px);\n            -webkit-backdrop-filter: blur(8px);\n        }\n    </style>', '        /* ── Backdrop on existing hover-cards ── */\n        .hover-card {\n            backdrop-filter: blur(8px);\n            -webkit-backdrop-filter: blur(8px);\n        }\n' + photo_css + '    </style>')

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(c)
print('Done.')
