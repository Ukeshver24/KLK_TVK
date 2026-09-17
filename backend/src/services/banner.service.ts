import path from 'path';
import fs from 'fs';
import prisma from '../config/db';
import { AppError } from '../middlewares/error.middleware';

export interface BannerInput {
  slot: number;
  imageUrl: string;
  title?: string | null;
}

export class BannerService {
  /**
   * Helper: Normalize image path to store ONLY relative folder path in DB (e.g. /uploads/banners/xxx.jpg)
   * Prevents hardcoding domain/localhost in PostgreSQL so live production deployment works seamlessly.
   */
  public static normalizeDbPath(url: string | null | undefined): string {
    if (!url) return '';
    const trimmed = url.trim();
    if (!trimmed || trimmed.startsWith('assets/')) return trimmed;

    // If starts with http:// or https://, extract the /uploads/... part
    const uploadIndex = trimmed.indexOf('/uploads/');
    if (uploadIndex !== -1) {
      return trimmed.substring(uploadIndex);
    }

    if (trimmed.startsWith('uploads/')) {
      return `/${trimmed}`;
    }

    return trimmed;
  }

  /**
   * Safe physical file deletion from disk
   */
  public static deletePhysicalBannerFile(imageUrl: string | null | undefined): void {
    if (!imageUrl) return;

    // Do NOT delete default bundled asset paths
    if (imageUrl.startsWith('assets/') || imageUrl.startsWith('data:') || imageUrl.trim() === '') return;

    try {
      // Extract filename from URL or relative path
      // e.g. "http://localhost:4000/uploads/banners/banner-slot-1-123.jpg" or "/uploads/banners/banner-slot-1-123.jpg"
      const urlWithoutQuery = imageUrl.split('?')[0];
      const filename = path.basename(urlWithoutQuery);

      if (!filename || filename.length < 5 || !filename.includes('.')) return;

      const bannersDir = path.resolve(process.cwd(), 'uploads/banners');
      const targetFilePath = path.join(bannersDir, filename);

      if (fs.existsSync(targetFilePath)) {
        fs.unlinkSync(targetFilePath);
        console.log(`[Disk Cleanup] Successfully deleted old banner file: ${targetFilePath}`);
      }
    } catch (err) {
      console.error(`[Disk Cleanup] Error deleting file for ${imageUrl}:`, err);
    }
  }

  /**
   * Get the 3 active banners (Strictly 3 slots)
   */
  static async getBanners() {
    let banners = await prisma.banner.findMany({
      orderBy: { slot: 'asc' },
    });

    // If no banners in DB yet, initialize the 3 default slots with empty paths
    if (banners.length === 0) {
      for (let i = 1; i <= 3; i++) {
        await prisma.banner.upsert({
          where: { slot: i },
          update: {},
          create: {
            slot: i,
            imageUrl: '',
            title: `TVK Announcement 0${i}`,
            isActive: true,
          },
        });
      }
      banners = await prisma.banner.findMany({
        orderBy: { slot: 'asc' },
      });
    }

    return banners;
  }

  /**
   * Save / update all 3 banners from Admin panel, auto-cleaning replaced files from disk
   * Storing strictly relative folder paths (/uploads/banners/...) in DB.
   */
  static async saveBanners(bannerList: BannerInput[]) {
    if (!Array.isArray(bannerList) || bannerList.length === 0) {
      throw new AppError('Banner list must be provided', 400);
    }

    for (const b of bannerList) {
      const slot = Number(b.slot);
      if (isNaN(slot) || slot < 1 || slot > 3) continue;

      const cleanRelativePath = this.normalizeDbPath(b.imageUrl);

      // Check existing banner in DB
      const existing = await prisma.banner.findUnique({
        where: { slot },
      });

      // If replacing an existing custom uploaded image with a different one, delete the old file
      if (existing && existing.imageUrl && existing.imageUrl !== cleanRelativePath) {
        this.deletePhysicalBannerFile(existing.imageUrl);
      }

      await prisma.banner.upsert({
        where: { slot },
        update: {
          imageUrl: cleanRelativePath,
          title: b.title?.trim() || `TVK Announcement 0${slot}`,
          isActive: true,
        },
        create: {
          slot,
          imageUrl: cleanRelativePath,
          title: b.title?.trim() || `TVK Announcement 0${slot}`,
          isActive: true,
        },
      });
    }

    return prisma.banner.findMany({
      orderBy: { slot: 'asc' },
    });
  }

  /**
   * Update a single banner slot with disk cleanup of previous file
   */
  static async updateBannerSlot(slot: number, newImageUrl: string, title?: string) {
    if (slot < 1 || slot > 3) {
      throw new AppError('Slot must be 1, 2, or 3', 400);
    }

    const cleanRelativePath = this.normalizeDbPath(newImageUrl);

    const existing = await prisma.banner.findUnique({
      where: { slot },
    });

    if (existing && existing.imageUrl && existing.imageUrl !== cleanRelativePath) {
      this.deletePhysicalBannerFile(existing.imageUrl);
    }

    return prisma.banner.upsert({
      where: { slot },
      update: {
        imageUrl: cleanRelativePath,
        title: title?.trim() || `TVK Announcement 0${slot}`,
        isActive: true,
      },
      create: {
        slot,
        imageUrl: cleanRelativePath,
        title: title?.trim() || `TVK Announcement 0${slot}`,
        isActive: true,
      },
    });
  }

  /**
   * Delete banner image for a slot: Deletes physical file from disk & resets slot to empty
   */
  static async deleteBannerSlot(slot: number) {
    if (slot < 1 || slot > 3) {
      throw new AppError('Slot must be 1, 2, or 3', 400);
    }

    const existing = await prisma.banner.findUnique({
      where: { slot },
    });

    if (existing && existing.imageUrl) {
      this.deletePhysicalBannerFile(existing.imageUrl);
    }

    await prisma.banner.upsert({
      where: { slot },
      update: {
        imageUrl: '',
        title: `TVK Announcement 0${slot}`,
        isActive: true,
      },
      create: {
        slot,
        imageUrl: '',
        title: `TVK Announcement 0${slot}`,
        isActive: true,
      },
    });

    return prisma.banner.findMany({
      orderBy: { slot: 'asc' },
    });
  }
}
