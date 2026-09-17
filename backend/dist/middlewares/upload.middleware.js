"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadCadreAvatarMiddleware = exports.uploadBroadcastPosterMiddleware = exports.uploadMlaAvatarMiddleware = exports.uploadBannerImageMiddleware = exports.uploadSingleImage = void 0;
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const error_middleware_1 = require("./error.middleware");
// Base uploads root consistently pointing to backend/uploads
const UPLOADS_ROOT = path_1.default.resolve(process.cwd(), 'uploads');
// Ensure complaints, banners, and mla upload folders exist
const complaintsUploadDir = path_1.default.join(UPLOADS_ROOT, 'complaints');
const bannersUploadDir = path_1.default.join(UPLOADS_ROOT, 'banners');
const mlaUploadDir = path_1.default.join(UPLOADS_ROOT, 'mla');
const broadcastsUploadDir = path_1.default.join(UPLOADS_ROOT, 'broadcasts');
const cadresUploadDir = path_1.default.join(UPLOADS_ROOT, 'cadres');
if (!fs_1.default.existsSync(complaintsUploadDir)) {
    fs_1.default.mkdirSync(complaintsUploadDir, { recursive: true });
}
if (!fs_1.default.existsSync(bannersUploadDir)) {
    fs_1.default.mkdirSync(bannersUploadDir, { recursive: true });
}
if (!fs_1.default.existsSync(mlaUploadDir)) {
    fs_1.default.mkdirSync(mlaUploadDir, { recursive: true });
}
if (!fs_1.default.existsSync(broadcastsUploadDir)) {
    fs_1.default.mkdirSync(broadcastsUploadDir, { recursive: true });
}
if (!fs_1.default.existsSync(cadresUploadDir)) {
    fs_1.default.mkdirSync(cadresUploadDir, { recursive: true });
}
// 1. Complaint Proof Image Storage
const complaintStorage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, complaintsUploadDir);
    },
    filename: (req, file, cb) => {
        const ext = path_1.default.extname(file.originalname).toLowerCase();
        const uniqueName = `proof-${Date.now()}-${Math.round(Math.random() * 1e6)}${ext}`;
        cb(null, uniqueName);
    },
});
// 2. Banner Poster Image Storage
const bannerStorage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, bannersUploadDir);
    },
    filename: (req, file, cb) => {
        const ext = path_1.default.extname(file.originalname).toLowerCase();
        const slot = req.body?.slot || req.query?.slot || '1';
        const uniqueName = `banner-slot-${slot}-${Date.now()}${ext}`;
        cb(null, uniqueName);
    },
});
// 3. MLA Avatar / Profile Image Storage
const mlaStorage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, mlaUploadDir);
    },
    filename: (req, file, cb) => {
        const ext = path_1.default.extname(file.originalname).toLowerCase();
        const uniqueName = `mla-avatar-${Date.now()}${ext}`;
        cb(null, uniqueName);
    },
});
// 4. Broadcast Poster Image Storage
const broadcastStorage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, broadcastsUploadDir);
    },
    filename: (req, file, cb) => {
        const ext = path_1.default.extname(file.originalname).toLowerCase();
        const uniqueName = `broadcast-poster-${Date.now()}${ext}`;
        cb(null, uniqueName);
    },
});
// 5. Cadre Avatar / ID Card Photo Storage
const cadreStorage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, cadresUploadDir);
    },
    filename: (req, file, cb) => {
        const ext = path_1.default.extname(file.originalname).toLowerCase();
        const uniqueName = `cadre-avatar-${Date.now()}-${Math.round(Math.random() * 1e5)}${ext}`;
        cb(null, uniqueName);
    },
});
const fileFilter = (req, file, cb) => {
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/heic', 'image/heif', 'application/octet-stream'];
    const ext = path_1.default.extname(file.originalname).toLowerCase();
    const allowedExts = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif'];
    if (allowedMimeTypes.includes(file.mimetype) || allowedExts.includes(ext) || file.mimetype.startsWith('image/')) {
        cb(null, true);
    }
    else {
        cb(new error_middleware_1.AppError('Only image files (JPG, PNG, WebP) are allowed.', 400), false);
    }
};
exports.uploadSingleImage = (0, multer_1.default)({
    storage: complaintStorage,
    limits: {
        fileSize: 10 * 1024 * 1024, // Generous 10 MB limit (auto-converted to lightweight WebP)
    },
    fileFilter,
});
exports.uploadBannerImageMiddleware = (0, multer_1.default)({
    storage: bannerStorage,
    limits: {
        fileSize: 5 * 1024 * 1024, // Up to 5 MB for high-res banners
    },
    fileFilter,
});
exports.uploadMlaAvatarMiddleware = (0, multer_1.default)({
    storage: mlaStorage,
    limits: {
        fileSize: 5 * 1024 * 1024, // Up to 5 MB for high-res MLA profile photo
    },
    fileFilter,
});
exports.uploadBroadcastPosterMiddleware = (0, multer_1.default)({
    storage: broadcastStorage,
    limits: {
        fileSize: 5 * 1024 * 1024, // Up to 5 MB for high-res broadcast poster
    },
    fileFilter,
});
exports.uploadCadreAvatarMiddleware = (0, multer_1.default)({
    storage: cadreStorage,
    limits: {
        fileSize: 5 * 1024 * 1024, // Up to 5 MB for cadre ID photo
    },
    fileFilter,
});
