// src/pages/og-image.png.ts
import satori from 'satori';
import { Resvg } from '@resvg/resvg-js';

export async function GET() {
    // 1. Define your "Code Based" Image Design (JSX syntax)
    const markup = {
        type: 'div',
        props: {
            style: {
                display: 'flex',
                height: '100%',
                width: '100%',
                backgroundColor: '#050505', // Your --dark color
                color: 'white',
                fontFamily: 'Inter',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                backgroundImage: 'radial-gradient(circle at center, rgba(255, 107, 53, 0.1) 0%, transparent 70%)',
            },
            children: [
                // The "Jumpstart" Label
                {
                    type: 'div',
                    props: {
                        children: 'FOR 7-FIGURE FOUNDERS',
                        style: {
                            color: '#FF6B35', // Your --primary color
                            fontSize: 20,
                            fontWeight: 700,
                            letterSpacing: '2px',
                            marginBottom: 20,
                            padding: '10px 20px',
                            border: '1px solid rgba(255, 107, 53, 0.3)',
                            borderRadius: 50,
                        }
                    }
                },
                // Main Title
                {
                    type: 'h1',
                    props: {
                        children: 'Scale Without The Burnout',
                        style: {
                            fontSize: 70,
                            fontWeight: 900,
                            textAlign: 'center',
                            margin: 0,
                            background: 'linear-gradient(to right, #FF6B35, #FFD93D)',
                            backgroundClip: 'text',
                            color: 'transparent',
                        }
                    }
                },
                // Subtitle
                {
                    type: 'p',
                    props: {
                        children: 'The 90-Day Methodology for 7-Figure Founders',
                        style: {
                            fontSize: 30,
                            color: '#9CA3AF', // Your --text-muted
                            marginTop: 20,
                        }
                    }
                }
            ],
        },
    };

    // 2. Load a font (Satori needs a font file to render text)
    const fontData = await fetch('https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hjp-Ek-_EeA.ttf').then(r => r.arrayBuffer());

    // 3. Generate SVG from the markup
    const svg = await satori(markup, {
        width: 1200,
        height: 630,
        fonts: [
            {
                name: 'Inter',
                data: fontData,
                style: 'normal',
            },
        ],
    });

    // 4. Convert SVG to PNG
    const resvg = new Resvg(svg);
    const png = resvg.render().asPng();

    // 5. Return the image
    return new Response(png, {
        headers: {
            'Content-Type': 'image/png',
            'Cache-Control': 'public, max-age=31536000, immutable',
        },
    });
}
