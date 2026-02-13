# UX/UI Designer Agent Research - Findings

## Source 1: frontend-design Skill (Claude Engineer)

**URL:** https://github.com/le-dat/claude-skill-engineer/blob/master/skills/frontend-design/SKILL.md

### Key Insights

**Professional UI/UX Designer and Frontend Engineer mindset**

Create bold, high-end, production-grade frontend interfaces that are:
- Intentional and distinctive
- Non-generic ("no AI slop aesthetics")
- Implementation-ready
- Visually striking and memorable

### Design Thinking Process

**Before coding, understand context and commit to aesthetic direction:**

1. **Purpose** - What problem does this interface solve? Who uses it?
2. **Tone** - Pick a clear extreme:
   - Brutally minimal
   - Maximalist chaos
   - Luxury/refined
   - Brutalist/raw
   - Retro-futuristic
   - Organic/soft
3. **Constraints** - Technical requirements (framework, performance, accessibility)
4. **Differentiation** - What makes this unforgettable?

**CRITICAL:** Choose clear conceptual direction and execute with precision.

### Frontend Aesthetics Guidelines

**Focus areas:**

1. **Typography**
   - Choose distinctive fonts (avoid Arial/Inter/Roboto)
   - Pair bold display font with refined body font
   - Typographic hierarchy

2. **Color & Theme**
   - Commit to cohesive aesthetic
   - Use CSS variables/design tokens
   - Dominant colors with sharp accents

3. **Motion & Animation**
   - High-impact animations for page load
   - Staggered reveals
   - CSS @keyframes for HTML, Framer Motion for React
   - `@media (prefers-reduced-motion: reduce)` required

4. **Spatial Composition**
   - Unexpected layouts
   - Asymmetry, overlap, diagonal flow
   - Grid-breaking elements

5. **Backgrounds & Visual Details**
   - Gradient meshes
   - Noise textures
   - Patterns
   - Layered transparencies
   - Shadows

### Design Process

```
Discovery → Understand requirements/audience/constraints → Define 3 key visual principles
     ↓
Concept → Choose aesthetic direction → Select fonts/colors/spacing
     ↓
Implement → Design tokens → Semantic HTML → Visuals → Motion → Polish
     ↓
Verify → Accessibility, responsiveness, performance
```

### Design Token Detection

**Check for existing tokens:**
- `tailwind.config.js`
- CSS `:root` variables
- `theme.js`
- `styles/variables.css`
- styled-components themes

**If found:** Extract and use existing colors/typography/spacing
**If not found:** Create new tokens matching chosen aesthetic

**Design Token Structure:**
- Fonts (display, body, mono)
- Colors (primary, secondary, accent, neutral, semantic)
- Spacing scale (xs, sm, md, lg, xl, 2xl)
- Border radius
- Shadows
- Animation timings

### Accessibility (Non-Negotiable)

**WCAG 2.1 AA required:**
- **Contrast:** 4.5:1 text, 3:1 UI
- **Keyboard:** Tab/Enter/Escape work, visible focus, no traps
- **Semantic HTML:** h1-h6 hierarchy, landmarks, alt text
- **Motion:** `@media (prefers-reduced-motion: reduce)` for all animations
- **Forms:** Labels for all inputs, clear error messages

**Rule:** Accessibility wins over aesthetics

### Responsive Design

**Mobile-first approach:**
- Breakpoints: 640px (sm), 768px (md), 1024px (lg), 1280px (xl)
- Fluid typography: `clamp(1rem, 0.5rem + 2vw, 2rem)`
- CSS Grid/Flexbox over fixed widths
- Touch targets: 44x44px minimum
- Test on real devices

### Component Documentation Best Practices

**Sources:**
- https://www.uiprep.com/blog/the-best-way-to-document-ux-ui-design
- https://blog.stackblitz.com/posts/design-system-component-documentation/
- https://www.uxpin.com/studio/blog/design-system-documentation-guide/

**Design System Documentation Structure:**

1. **Global Component Page**
   - All non-workflow-specific components (buttons, inputs, avatars)
   - Common components need dedicated page for easy reference

2. **Component States & Variants**
   - Document every possible state (default, hover, focus, active, disabled, loading, error)
   - Document all variants (primary, secondary, danger, sizes)
   - Short description: when, why, and how to use

3. **Interactive Playgrounds**
   - Allow users to compose components together
   - Demonstrate permutations and compositions
   - Live preview of component usage

4. **Usage Guidelines**
   - When to use vs when not to use
   - Do's and don'ts
   - Accessibility considerations per component

5. **Code Examples**
   - Implementation snippets
   - Props/API documentation
   - Integration examples

### UI Component Library Best Practices

**Source:** https://uxplaybook.org/articles/ui-fundamentals-best-practices-for-ux-designers

**Component Library = UI's Recipe Book**

- Design it once, use it everywhere
- Standardize: buttons, form fields, modals, cards, etc.
- Keep behaviors predictable
- Keep styling on-brand

**Naming Conventions:**
- `PrimaryButton`, `SecondaryButton`
- `DangerAlert`, `WarningAlert`
- `InputField_Large`, `InputField_Small`

**Benefits:**
- Consistency across product
- Faster development handoff
- Easier maintenance

## Key Takeaways for Our UI/UX Expert Subagent

1. **Design Thinking First** - Understand purpose, tone, constraints before implementation
2. **Aesthetic Direction** - Choose clear conceptual direction (minimalist, maximalist, etc.)
3. **Component Library** - Document all states, variants, and usage guidelines
4. **Design Tokens** - Define fonts, colors, spacing, animations upfront
5. **Accessibility** - WCAG 2.1 AA non-negotiable (contrast, keyboard, semantic HTML)
6. **Responsive Design** - Mobile-first with fluid typography and touch targets
7. **Interactive Documentation** - Show component compositions and playgrounds

## Adaptation for Ralph-Planner Workflow

Our UI/UX Expert subagent should:

**Input:**
- design.md (from brainstorming)
- PRD.md (from Product Manager)
- ARCHITECTURE.md (from Architecture Expert) - to understand technical constraints

**Output:** UI-SPEC.md with:

1. **Design Thinking**
   - Purpose and audience
   - Aesthetic direction chosen (tone, mood, style)
   - Key visual principles (3-5)

2. **Design Tokens**
   - Typography scale (display, heading, body, caption)
   - Color palette (primary, secondary, accent, neutral, semantic)
   - Spacing scale
   - Border radius values
   - Shadow definitions
   - Animation timings

3. **Component Library**
   - List of required components (buttons, inputs, cards, modals, etc.)
   - For each component:
     - States (default, hover, focus, active, disabled, loading, error)
     - Variants (primary, secondary, sizes)
     - Props/configuration
     - Usage guidelines (when/when not to use)

4. **Layout Specifications**
   - Page structure (header, nav, main, footer)
   - Grid system (columns, gutters)
   - Responsive breakpoints
   - Layout patterns (cards, lists, tables)

5. **Interaction Flows**
   - User journey maps (from PRD)
   - Key interactions (click, hover, scroll, drag)
   - Transitions and animations
   - Loading states
   - Error states

6. **Accessibility Requirements**
   - WCAG 2.1 AA compliance checklist
   - Keyboard navigation requirements
   - Screen reader considerations
   - Reduced motion fallbacks

7. **Responsive Design Strategy**
   - Mobile-first approach
   - Breakpoint-specific layouts
   - Touch target sizes
   - Fluid typography

8. **Integration with Tech Stack**
   - CSS framework recommendations (Tailwind, styled-components, etc.)
   - Component library suggestions (shadcn/ui, MUI, etc.)
   - State management for UI (if needed)

This UI-SPEC.md will then feed into:
- Final epic/spec assembly (with UI implementation details)
- Ralph loop execution (with UI context and design tokens)

## Sources

- [Frontend Design Skill](https://github.com/le-dat/claude-skill-engineer/blob/master/skills/frontend-design/SKILL.md)
- [Best Way to Document UX/UI Design](https://www.uiprep.com/blog/the-best-way-to-document-ux-ui-design)
- [Design System Component Documentation](https://blog.stackblitz.com/posts/design-system-component-documentation/)
- [Design System Documentation Guide](https://www.uxpin.com/studio/blog/design-system-documentation-guide/)
- [UI Fundamentals Best Practices](https://uxplaybook.org/articles/ui-fundamentals-best-practices-for-ux-designers)
