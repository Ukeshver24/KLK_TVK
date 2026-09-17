import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request } from 'express';
import { AppError } from './error.middleware';

// Base uploads root consistently pointing to backend/uploads
const UPLOADS_ROOT = path.resolve(process.cwd(), 'uploads');

// Ensure complaints, banners, and mla upload folders exist
const complaintsUploadDir = path.join(UPLOADS_ROOT, 'complaints');
const bannersUploadDir = path.join(UPLOADS_ROOT, 'banners');
const mlaUploadDir = path.join(UPLOADS_ROOT, 'mla');
const broadcastsUploadDir = path.join(UPLOADS_ROOT, 'broadcasts');
const cadresUploadDir = path.join(UPLOADS_ROOT, 'cadres');

if (!fs.existsSync(complaintsUploadDir)) {
  fs.mkdirSync(complaintsUploadDir, { recursive: true });
}
if (!fs.existsSync(bannersUploadDir)) {
  fs.mkdirSync(bannersUploadDir, { recursive: true });
}
if (!fs.existsSync(mlaUploadDir)) {
  fs.mkdirSync(mlaUploadDir, { recursive: true });
}
if (!fs.existsSync(broadcastsUploadDir)) {
  fs.mkdirSync(broadcastsUploadDir, { recursive: true });
}
if (!fs.existsSync(cadresUploadDir)) {
  fs.mkdirSync(cadresUploadDir, { recursive: true });
}

// 1. Complaint Proof Image Storage
const complaintStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, complaintsUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const uniqueName = `proof-${Date.now()}-${Math.round(Math.random() * 1e6)}${ext}`;
    cb(null, uniqueName);
  },
});

// 2. Banner Poster Image Storage
const bannerStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, bannersUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const slot = req.body?.slot || req.query?.slot || '1';
    const uniqueName = `banner-slot-${slot}-${Date.now()}${ext}`;
    cb(null, uniqueName);
  },
});

// 3. MLA Avatar / Profile Image Storage
const mlaStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, mlaUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const uniqueName = `mla-avatar-${Date.now()}${ext}`;
    cb(null, uniqueName);
  },
});

// 4. Broadcast Poster Image Storage
const broadcastStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, broadcastsUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const uniqueName = `broadcast-poster-${Date.now()}${ext}`;
    cb(null, uniqueName);
  },
});

// 5. Cadre Avatar / ID Card Photo Storage
const cadreStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, cadresUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const uniqueName = `cadre-avatar-${Date.now()}-${Math.round(Math.random() * 1e5)}${ext}`;
    cb(null, uniqueName);
  },
});

const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/heic', 'image/heif', 'application/octet-stream'];
  const ext = path.extname(file.originalname).toLowerCase();
  const allowedExts = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif'];

  if (allowedMimeTypes.includes(file.mimetype) || allowedExts.includes(ext) || file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new AppError('Only image files (JPG, PNG, WebP) are allowed.', 400) as any, false);
  }
};

export const uploadSingleImage = multer({
  storage: complaintStorage,
  limits: {
    fileSize: 10 * 1024 * 1024, // Generous 10 MB limit (auto-converted to lightweight WebP)
  },
  fileFilter,
});

export const uploadBannerImageMiddleware = multer({
  storage: bannerStorage,
  limits: {
    fileSize: 5 * 1024 * 1024, // Up to 5 MB for high-res banners
  },
  fileFilter,
});

export const uploadMlaAvatarMiddleware = multer({
  storage: mlaStorage,
  limits: {
    fileSize: 5 * 1024 * 1024, // Up to 5 MB for high-res MLA profile photo
  },
  fileFilter,
});

export const uploadBroadcastPosterMiddleware = multer({
  storage: broadcastStorage,
  limits: {
    fileSize: 5 * 1024 * 1024, // Up to 5 MB for high-res broadcast poster
  },
  fileFilter,
});

export const uploadCadreAvatarMiddleware = multer({
  storage: cadreStorage,
  limits: {
    fileSize: 5 * 1024 * 1024, // Up to 5 MB for cadre ID photo
  },
  fileFilter,
});


