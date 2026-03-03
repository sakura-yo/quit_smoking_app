"""
Resize app icon to 512x512, content inside 312px diameter circle, no alpha.
"""
from PIL import Image
import math

OUTPUT_SIZE = 512
CIRCLE_DIAMETER = 312
GREEN = (0x2E, 0x7D, 0x32)  # #2E7D32

def main():
    src = Image.open("assets/icons/app_icon_1024.png").convert("RGBA")
    w, h = src.size

    # Scale source so that it fits in CIRCLE_DIAMETER (content circle)
    scaled = src.resize((CIRCLE_DIAMETER, CIRCLE_DIAMETER), Image.Resampling.LANCZOS)

    # Create 512x512 canvas with solid green (no alpha)
    out = Image.new("RGB", (OUTPUT_SIZE, OUTPUT_SIZE), GREEN)

    # Circular mask: 1 inside circle, 0 outside
    mask = Image.new("L", (CIRCLE_DIAMETER, CIRCLE_DIAMETER), 0)
    center = CIRCLE_DIAMETER / 2.0
    radius = CIRCLE_DIAMETER / 2.0
    for y in range(CIRCLE_DIAMETER):
        for x in range(CIRCLE_DIAMETER):
            if (x - center) ** 2 + (y - center) ** 2 <= radius ** 2:
                mask.putpixel((x, y), 255)

    # Composite scaled image onto green background using circle mask, then paste onto out
    # First: composite scaled (RGBA) onto green within the circle
    box_bg = Image.new("RGB", (CIRCLE_DIAMETER, CIRCLE_DIAMETER), GREEN)
    box_bg.paste(scaled, (0, 0), scaled)  # paste with alpha from scaled
    # Now box_bg is RGB (no alpha) for the circle content. Apply mask: where mask=0 use green.
    paste_x = (OUTPUT_SIZE - CIRCLE_DIAMETER) // 2  # 100
    paste_y = paste_x
    for y in range(CIRCLE_DIAMETER):
        for x in range(CIRCLE_DIAMETER):
            if mask.getpixel((x, y)) == 255:
                out.putpixel((paste_x + x, paste_y + y), box_bg.getpixel((x, y)))
            # else keep out's pixel (already green)

    out.save("assets/icons/app_icon_512.png", "PNG")
    print("Saved assets/icons/app_icon_512.png (512x512, content in 312px circle, no alpha)")

if __name__ == "__main__":
    main()
