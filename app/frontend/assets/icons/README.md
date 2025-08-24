# Landing Page Icons

This directory contains optimized icons for the RESP Gifts landing page.

## Icon Guidelines

### App Icons
- **app_icon.png** - Main application icon (512x512)
- **app_icon_192.png** - PWA icon (192x192)
- **app_icon_512.png** - PWA icon (512x512)
- **favicon.ico** - Browser favicon (32x32, 16x16)

### Feature Icons
- **savings.svg** - Tax-free growth icon
- **heart.svg** - Meaningful gifts icon
- **smartphone.svg** - Easy to use icon
- **family.svg** - Family friendly icon
- **trending_up.svg** - Growth tracking icon
- **school.svg** - Education focus icon

### Navigation Icons
- **menu.svg** - Mobile menu icon
- **close.svg** - Close/dismiss icon
- **arrow_up.svg** - Scroll to top icon
- **arrow_down.svg** - Scroll down icon
- **external_link.svg** - External link icon

### Social Icons
- **facebook.svg** - Facebook social icon
- **twitter.svg** - Twitter/X social icon
- **instagram.svg** - Instagram social icon
- **linkedin.svg** - LinkedIn social icon

### Trust Indicators
- **security.svg** - Security/lock icon
- **verified.svg** - Verification checkmark
- **canada.svg** - Canadian flag icon
- **bank.svg** - Banking/financial icon

## Technical Requirements

### Format
- **SVG**: Preferred for scalable icons
- **PNG**: For complex icons or when SVG isn't suitable
- **ICO**: For favicons only

### Sizing
- **SVG**: Scalable (designed at 24x24 base)
- **PNG**: Multiple sizes (16, 24, 32, 48, 64, 128, 256, 512)
- **ICO**: 16x16 and 32x32 embedded

### Optimization
- **SVG**: Minified, no unnecessary metadata
- **PNG**: Optimized with tools like TinyPNG
- **Colors**: Use CSS custom properties for theming

### Accessibility
- **Contrast**: Meet WCAG AA standards (4.5:1)
- **Size**: Minimum 24x24px touch targets
- **Labels**: Proper aria-labels and tooltips

## Current Status

🚧 **Using Material Design Icons** - The current implementation uses Material Design icons from Flutter's built-in icon set. These provide good coverage and accessibility but should be replaced with custom icons that match the RESP Gifts brand identity.

## Implementation Notes

Icons are currently implemented using Flutter's `Icons` class:
- `Icons.school_outlined` - Education/RESP theme
- `Icons.savings_outlined` - Financial growth
- `Icons.favorite_outline` - Meaningful gifts
- `Icons.smartphone_outlined` - Technology/ease
- `Icons.family_restroom_outlined` - Family focus
- `Icons.trending_up_outlined` - Growth tracking

Custom SVG icons can be added using the `flutter_svg` package when ready.