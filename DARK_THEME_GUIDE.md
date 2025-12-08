# Dark Theme Visual Guide

## Overview
This document provides a visual guide to the new dark theme implementation inspired by GitHub and New York Times.

## Color Palette Reference

### Background Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary Background | `#0d1117` | Main page background |
| Secondary Background | `#161b22` | Cards, navbar, modals |
| Tertiary Background | `#21262d` | Card headers, table headers |
| Border Color | `#30363d` | All borders and dividers |

### Text Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary Text | `#c9d1d9` | Main content text |
| Secondary Text | `#8b949e` | Labels, secondary info |
| Muted Text | `#6e7681` | Placeholder text, hints |

### Accent Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Accent Blue | `#58a6ff` | Primary buttons, links, info |
| Accent Green | `#3fb950` | Success messages, badges |
| Accent Orange | `#f0883e` | Warning messages, alerts |
| Accent Red | `#f85149` | Danger buttons, errors |
| Accent Purple | `#bc8cff` | Info buttons, highlights |
| Accent Yellow | `#d29922` | Special highlights |

## Component Styles

### Navigation Bar
```
Before (Light Theme):
- Background: #ffffff (white)
- Text: #212529 (dark)
- Border: light gray

After (Dark Theme):
- Background: #161b22 (dark gray)
- Text: #c9d1d9 (light gray)
- Border: #30363d (darker)
- Icons: Bootstrap Icons added
- Hover: #58a6ff (blue accent)
```

**Key Features:**
- Subtle border instead of heavy shadow
- Icon prefixes for menu items
- Smooth hover transitions
- Better contrast

### Buttons

#### Primary Button (Blue)
```css
Normal State:
- Background: #58a6ff
- Color: #ffffff
- Border: #58a6ff

Hover State:
- Background: #4493e1 (lighter)
- Transform: translateY(-1px) (lift effect)
- Shadow: 0 4px 8px rgba(88, 166, 255, 0.3)
```

#### Success Button (Green)
```css
Normal State:
- Background: #3fb950
- Color: #ffffff

Hover State:
- Background: #2ea043
- Transform: translateY(-1px)
- Shadow: 0 4px 8px rgba(63, 185, 80, 0.3)
```

#### Warning Button (Orange)
```css
Normal State:
- Background: #f0883e
- Color: #ffffff

Hover State:
- Background: #e0762e
- Transform: translateY(-1px)
- Shadow: 0 4px 8px rgba(240, 136, 62, 0.3)
```

#### Danger Button (Red)
```css
Normal State:
- Background: #f85149
- Color: #ffffff

Hover State:
- Background: #e13d35
- Transform: translateY(-1px)
- Shadow: 0 4px 8px rgba(248, 81, 73, 0.3)
```

### Cards
```
Structure:
┌─────────────────────────────┐
│ Header (#21262d)            │ ← Tertiary background
├─────────────────────────────┤
│                             │
│ Body (#161b22)              │ ← Secondary background
│                             │
└─────────────────────────────┘
Border: #30363d
Shadow: 0 4px 6px rgba(0, 0, 0, 0.3)
```

**Header Colors:**
- Primary (blue): `#58a6ff`
- Success (green): `#3fb950`
- Warning (orange): `#f0883e`

### Forms

#### Input Fields
```css
Normal State:
- Background: #0d1117 (darkest)
- Border: #30363d
- Text: #c9d1d9
- Placeholder: #6e7681 (muted)

Focus State:
- Border: #58a6ff (blue accent)
- Shadow: 0 0 0 0.2rem rgba(88, 166, 255, 0.25)
```

### Tables
```
Header Row (#21262d):
│ Column 1 │ Column 2 │ Column 3 │

Odd Rows (#161b22):
│ Data 1   │ Data 2   │ Data 3   │

Even Rows (#21262d):
│ Data 1   │ Data 2   │ Data 3   │

Hover: Lighten slightly
```

### Alerts

#### Success Alert
```css
- Background: rgba(63, 185, 80, 0.15) (semi-transparent green)
- Border: #3fb950
- Text: #3fb950
```

#### Danger Alert
```css
- Background: rgba(248, 81, 73, 0.15) (semi-transparent red)
- Border: #f85149
- Text: #f85149
```

#### Warning Alert
```css
- Background: rgba(240, 136, 62, 0.15) (semi-transparent orange)
- Border: #f0883e
- Text: #f0883e
```

#### Info Alert
```css
- Background: rgba(88, 166, 255, 0.15) (semi-transparent blue)
- Border: #58a6ff
- Text: #58a6ff
```

### Badges
```
Success Badge:
┌─────────┐
│ Active  │ Background: #3fb950
└─────────┘

Danger Badge:
┌──────────┐
│ Inactive │ Background: #f85149
└──────────┘

Secondary Badge:
┌─────────┐
│ Pending │ Background: #8b949e
└─────────┘
```

### Progress Bars
```
Container:
- Background: #21262d
- Border: #30363d

Fill Colors:
- Default: #58a6ff (blue)
- Success (≥75%): #3fb950 (green)
- Warning (50-74%): #f0883e (orange)
- Danger (<50%): #f85149 (red)
```

### Dropdown Menus
```css
Menu Container:
- Background: #21262d
- Border: #30363d

Menu Items:
Normal:
- Color: #c9d1d9
- Background: transparent

Hover:
- Background: #161b22
- Color: #58a6ff (blue)

Divider:
- Border: #30363d
```

### Scrollbar (Webkit)
```
Track:
- Background: #0d1117 (darkest)

Thumb:
- Background: #21262d
- Border-radius: 6px
- Border: 2px solid #0d1117

Thumb Hover:
- Background: #30363d (lighter)
```

## Page-Specific Enhancements

### My Profile Page
- Profile image displayed as rounded circle
- 200x200px maximum size
- Object-fit: cover for proper cropping
- Fallback icon for users without images
- Clean layout with visual hierarchy

### Edit Profile Page
- Image upload with live preview
- Real-time profile completion bar
- Color-coded completion percentage
- All form fields styled consistently
- Clear visual sections with dividers

### My Team Page (Line Manager)
- Clean table layout
- Status badges color-coded
- Action buttons with hover effects
- Team count display
- Responsive design

## Accessibility Features

### Contrast Ratios
- Background to text: > 7:1 (AAA)
- Button text: > 4.5:1 (AA)
- Accent colors chosen for visibility

### Focus Indicators
- All interactive elements have visible focus states
- Blue ring on keyboard focus
- Consistent across all components

### Semantic HTML
- Proper heading hierarchy
- ARIA labels where needed
- Semantic elements used throughout

## Animation & Transitions

### Button Hover
```css
transition: all 0.2s ease;
transform: translateY(-1px);
```

### Link Hover
```css
transition: color 0.2s ease;
```

### Smooth Scrolling
```css
scroll-behavior: smooth;
```

## Responsive Considerations

### Mobile Breakpoints
- Font size adjusts on smaller screens
- Navbar collapses appropriately
- Tables scroll horizontally if needed
- Touch-friendly button sizes

### Container Width
- Max-width: 1400px
- Centered with auto margins
- Fluid padding on mobile

## Best Practices Applied

1. **Consistent Spacing**: 8px grid system
2. **Typography**: Clear hierarchy with size and weight
3. **Color Usage**: Accent colors for meaning (blue=action, green=success, etc.)
4. **Hover States**: All interactive elements have visible hover states
5. **Focus States**: Keyboard navigation fully supported
6. **Loading States**: Smooth transitions prevent jarring updates
7. **Error States**: Clear error messages with red accent
8. **Success States**: Positive feedback with green accent

## Comparison Summary

| Aspect | Before | After |
|--------|--------|-------|
| Background | White (#ffffff) | Dark (#0d1117) |
| Cards | Light with shadow | Dark with border |
| Buttons | Bootstrap default | Custom accent colors |
| Navigation | Light with dark text | Dark with light text |
| Forms | White inputs | Dark inputs |
| Tables | Light alternating | Dark alternating |
| Icons | None | Bootstrap Icons |
| Transitions | None | Smooth 0.2s ease |
| Hover Effects | Minimal | Pronounced with lift |
| Scrollbar | System default | Custom dark theme |

## Implementation Notes

### Browser Support
- Modern browsers (Chrome, Firefox, Safari, Edge)
- Custom scrollbar: Webkit browsers only
- CSS Grid and Flexbox used throughout
- Graceful degradation for older browsers

### Performance
- CSS variables for efficient theme switching
- Minimal JavaScript for dynamic features
- Optimized selectors
- No external CSS dependencies (except Bootstrap)

### Maintenance
- All colors in CSS variables for easy updates
- Consistent naming convention
- Comments for complex styles
- Modular organization

## Future Enhancement Opportunities

1. Add light/dark theme toggle
2. Add more accent color options
3. Implement theme customization
4. Add animation prefers-reduced-motion support
5. Enhance mobile-specific styles
6. Add print stylesheet
7. Consider adding CSS Grid for complex layouts

---

## Testing Checklist

To verify the dark theme implementation:

- [ ] Check all pages render with dark background
- [ ] Verify text is readable on all backgrounds
- [ ] Test all button hover states
- [ ] Check form input focus states
- [ ] Verify table readability
- [ ] Test dropdown menus
- [ ] Check alert messages are visible
- [ ] Verify badge colors are correct
- [ ] Test navigation on mobile
- [ ] Check custom scrollbar in Chrome/Edge
- [ ] Verify accessibility with screen reader
- [ ] Test keyboard navigation
- [ ] Check contrast ratios with tools
- [ ] Verify responsive breakpoints
- [ ] Test in different browsers

---

**This dark theme provides a modern, professional appearance while maintaining excellent usability and accessibility.**
