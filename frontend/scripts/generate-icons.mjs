/**
 * Generate PWA icons as valid PNG files using pure Node.js (no external deps).
 * Creates simple colored squares with the "TM" branding color (#3f51b5).
 */
import { writeFileSync, mkdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import { deflateSync } from "zlib";

const __dirname = dirname(fileURLToPath(import.meta.url));
const iconsDir = join(__dirname, "..", "public", "icons");

mkdirSync(iconsDir, { recursive: true });

function createPNG(width, height, r, g, b, maskable = false) {
  // For maskable icons, we add padding (safe zone is inner 80%)
  const padding = maskable ? Math.floor(width * 0.1) : 0;

  // Build raw pixel data (RGBA)
  const rawData = Buffer.alloc(height * (1 + width * 4));

  for (let y = 0; y < height; y++) {
    const rowOffset = y * (1 + width * 4);
    rawData[rowOffset] = 0; // filter byte: None

    for (let x = 0; x < width; x++) {
      const pixelOffset = rowOffset + 1 + x * 4;

      // Background color (#3f51b5)
      let pr = r, pg = g, pb = b, pa = 255;

      if (maskable) {
        // Maskable: full bleed background
        // Add a lighter inner area to simulate the icon content
        const inPadding =
          x >= padding &&
          x < width - padding &&
          y >= padding &&
          y < height - padding;

        if (inPadding) {
          // Slightly lighter shade for the inner content area
          pr = Math.min(255, r + 30);
          pg = Math.min(255, g + 30);
          pb = Math.min(255, b + 30);
        }
      } else {
        // Standard icon: rounded-ish appearance with a simple design
        // Center area is the brand color, corners are slightly transparent
        const cx = width / 2;
        const cy = height / 2;
        const maxDist = Math.sqrt(cx * cx + cy * cy);
        const dist = Math.sqrt((x - cx) ** 2 + (y - cy) ** 2);

        if (dist > maxDist * 0.9) {
          pa = 0;
          pr = 0;
          pg = 0;
          pb = 0;
        }
      }

      // Draw "TM" text region (simplified block letters in center)
      const centerX = width / 2;
      const centerY = height / 2;
      const letterSize = Math.floor(width * 0.12);
      const letterThickness = Math.max(2, Math.floor(width * 0.04));

      // Letter T: horizontal bar + vertical bar
      const tLeft = Math.floor(centerX - letterSize * 1.8);
      const tTop = Math.floor(centerY - letterSize * 0.8);

      // T horizontal bar
      if (
        x >= tLeft &&
        x < tLeft + letterSize * 1.2 &&
        y >= tTop &&
        y < tTop + letterThickness &&
        pa > 0
      ) {
        pr = 255;
        pg = 255;
        pb = 255;
      }
      // T vertical bar
      if (
        x >= tLeft + Math.floor(letterSize * 0.4) &&
        x < tLeft + Math.floor(letterSize * 0.4) + letterThickness &&
        y >= tTop &&
        y < tTop + letterSize * 1.6 &&
        pa > 0
      ) {
        pr = 255;
        pg = 255;
        pb = 255;
      }

      // Letter M
      const mLeft = Math.floor(centerX + letterSize * 0.2);
      const mTop = tTop;
      const mHeight = Math.floor(letterSize * 1.6);

      // M left vertical
      if (
        x >= mLeft &&
        x < mLeft + letterThickness &&
        y >= mTop &&
        y < mTop + mHeight &&
        pa > 0
      ) {
        pr = 255;
        pg = 255;
        pb = 255;
      }
      // M right vertical
      if (
        x >= mLeft + letterSize &&
        x < mLeft + letterSize + letterThickness &&
        y >= mTop &&
        y < mTop + mHeight &&
        pa > 0
      ) {
        pr = 255;
        pg = 255;
        pb = 255;
      }
      // M left diagonal
      const mMidX = mLeft + letterSize / 2;
      const diagY = y - mTop;
      if (
        diagY >= 0 &&
        diagY < mHeight * 0.5 &&
        pa > 0
      ) {
        const expectedX1 = mLeft + (diagY / (mHeight * 0.5)) * (letterSize / 2);
        if (Math.abs(x - expectedX1) < letterThickness) {
          pr = 255;
          pg = 255;
          pb = 255;
        }
        const expectedX2 = mLeft + letterSize - (diagY / (mHeight * 0.5)) * (letterSize / 2);
        if (Math.abs(x - expectedX2) < letterThickness) {
          pr = 255;
          pg = 255;
          pb = 255;
        }
      }

      rawData[pixelOffset] = pr;
      rawData[pixelOffset + 1] = pg;
      rawData[pixelOffset + 2] = pb;
      rawData[pixelOffset + 3] = pa;
    }
  }

  // Compress pixel data
  const compressed = deflateSync(rawData);

  // Build PNG file
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  function createChunk(type, data) {
    const typeBuffer = Buffer.from(type);
    const length = Buffer.alloc(4);
    length.writeUInt32BE(data.length);

    const crcInput = Buffer.concat([typeBuffer, data]);
    const crc = crc32(crcInput);
    const crcBuffer = Buffer.alloc(4);
    crcBuffer.writeUInt32BE(crc >>> 0);

    return Buffer.concat([length, typeBuffer, data, crcBuffer]);
  }

  // CRC32 implementation
  function crc32(buf) {
    let crc = 0xffffffff;
    for (let i = 0; i < buf.length; i++) {
      crc ^= buf[i];
      for (let j = 0; j < 8; j++) {
        crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0);
      }
    }
    return (crc ^ 0xffffffff) >>> 0;
  }

  // IHDR chunk
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 6; // color type: RGBA
  ihdr[10] = 0; // compression
  ihdr[11] = 0; // filter
  ihdr[12] = 0; // interlace

  const ihdrChunk = createChunk("IHDR", ihdr);
  const idatChunk = createChunk("IDAT", compressed);
  const iendChunk = createChunk("IEND", Buffer.alloc(0));

  return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

// Brand color: #3f51b5
const r = 0x3f, g = 0x51, b = 0xb5;

// Generate icons
const icon192 = createPNG(192, 192, r, g, b, false);
const icon512 = createPNG(512, 512, r, g, b, false);
const iconMaskable = createPNG(512, 512, r, g, b, true);

writeFileSync(join(iconsDir, "icon-192x192.png"), icon192);
writeFileSync(join(iconsDir, "icon-512x512.png"), icon512);
writeFileSync(join(iconsDir, "icon-maskable-512x512.png"), iconMaskable);

process.stdout.write(
  `Generated PWA icons in ${iconsDir}:\n` +
  `  - icon-192x192.png (${icon192.length} bytes)\n` +
  `  - icon-512x512.png (${icon512.length} bytes)\n` +
  `  - icon-maskable-512x512.png (${iconMaskable.length} bytes)\n`
);
