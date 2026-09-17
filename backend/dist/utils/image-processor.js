"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertToWebP = convertToWebP;
const sharp_1 = __importDefault(require("sharp"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
async function convertToWebP(inputPath, options = {}) {
    const { maxWidth = 1920, maxHeight = 1080, quality = 82 } = options;
    const dir = path_1.default.dirname(inputPath);
    const parsed = path_1.default.parse(inputPath);
    const webpFilename = `${parsed.name}.webp`;
    const outputPath = path_1.default.join(dir, webpFilename);
    try {
        const pipeline = (0, sharp_1.default)(inputPath).rotate(); // auto-orient from EXIF
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
        if (outputPath !== inputPath && fs_1.default.existsSync(inputPath)) {
            try {
                fs_1.default.unlinkSync(inputPath);
            }
            catch (_) { }
        }
        return {
            finalPath: outputPath,
            filename: webpFilename,
            size: info.size,
        };
    }
    catch (error) {
        // If sharp fails for any reason, fallback gracefully to existing file
        const stat = fs_1.default.existsSync(inputPath) ? fs_1.default.statSync(inputPath) : { size: 0 };
        return {
            finalPath: inputPath,
            filename: parsed.base,
            size: stat.size,
        };
    }
}
