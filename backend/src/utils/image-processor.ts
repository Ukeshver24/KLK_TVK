import sharp from 'sharp';
import fs from 'fs';
import path from 'path';

export async function convertToWebP(
  inputPath: string,
  options: {
    maxWidth?: number;
    maxHeight?: number;
    quality?: number;
  } = {}
): Promise<{ finalPath: string; filename: string; size: number }> {
  const { maxWidth = 1920, maxHeight = 1080, quality = 82 } = options;
  const dir = path.dirname(inputPath);
  const parsed = path.parse(inputPath);
  const webpFilename = `${parsed.name}.webp`;
  const outputPath = path.join(dir, webpFilename);

  try {
    const pipeline = sharp(inputPath).rotate(); // auto-orient from EXIF

    if (maxWidth || maxHeight) {
      pipeline.resize({
        width: maxWidth,
        height: maxHeight,
        fit: 'inside',
        withoutEnlargement: true,
      });
    }

    const info = await pipeline
      .webp({ quality, effort: 4 })
      .toFile(outputPath);

    // If input was a different extension (e.g. .jpg, .png), safely delete raw uncompressed upload
    if (outputPath !== inputPath && fs.existsSync(inputPath)) {
      try {
        fs.unlinkSync(inputPath);
      } catch (_) {}
    }

    return {
      finalPath: outputPath,
      filename: webpFilename,
      size: info.size,
    };
  } catch (error) {
    // If sharp fails for any reason, fallback gracefully to existing file
    const stat = fs.existsSync(inputPath) ? fs.statSync(inputPath) : { size: 0 };
    return {
      finalPath: inputPath,
      filename: parsed.base,
      size: stat.size,
    };
  }
}
