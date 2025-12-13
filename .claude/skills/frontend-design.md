# Frontend Design Skill

## Trigger Conditions
Aktifkan skill ini saat:
- Membuat atau memodifikasi HTML/CSS/JS
- Mengerjakan layout, komponen UI, atau styling
- User meminta desain, redesign, atau improvement visual

## Design Philosophy: Industrial Utilitarian

### Core Principles
1. **Bold & Distinctive** - Tidak generic, harus memorable
2. **Function Over Decoration** - Setiap elemen punya purpose
3. **Raw & Honest** - Tampilkan material apa adanya
4. **High Contrast** - Legibility adalah prioritas

### Visual Language

#### Typography
- Gunakan font bold/black untuk headings
- Hierarchy yang jelas: H1 > H2 > H3
- Uppercase untuk emphasis (sparingly)
- Letter-spacing untuk industrial feel

#### Colors
```
Primary:    #1a1a1a (Almost Black)
Secondary:  #f5f5f5 (Off White)
Accent:     #ff6b00 (Industrial Orange)
Warning:    #ffd700 (Caution Yellow)
```

#### Layout
- Grid-based, structured
- Generous whitespace
- Asymmetric balance acceptable
- Clear visual hierarchy

#### Components Style
- Sharp corners atau subtle radius (max 4px)
- Visible borders, defined edges
- No gradients, flat colors
- Shadow minimal atau none

### Do's
- Gunakan kontras tinggi untuk CTA
- Buat visual hierarchy yang jelas
- Prioritaskan mobile-first
- Test accessibility (contrast ratio)

### Don'ts
- Jangan pakai rounded corners berlebihan
- Hindari warna pastel
- Jangan overcrowd dengan decorative elements
- Hindari animasi yang tidak purposeful

## Implementation Guidelines

### CSS Approach
```css
/* Prefer utility-first atau semantic classes */
.btn-primary {
  background: #1a1a1a;
  color: #fff;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: none;
  padding: 1rem 2rem;
}

.section-header {
  border-left: 4px solid #ff6b00;
  padding-left: 1rem;
}
```

### HTML Structure
- Semantic HTML5 elements
- BEM atau utility naming convention
- Accessibility attributes (aria, alt, etc)

### Performance
- Lazy load images
- Minimize external dependencies
- Optimize untuk Core Web Vitals
