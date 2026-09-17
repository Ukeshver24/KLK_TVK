import { Request, Response, NextFunction } from 'express';
import { BannerService } from '../services/banner.service';
import { convertToWebP } from '../utils/image-processor';

export class BannerController {
  /**
   * GET /api/v1/banners (Get 3 active banners for mobile app and admin panel)
   */
  static async getBanners(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const banners = await BannerService.getBanners();
      const host = req.get('host') || 'localhost:4000';
      const protocol = req.protocol || 'http';
      const baseUrl = process.env.API_BASE_URL || `${protocol}://${host}`;

      // Dynamically attach fullUrl from dynamic baseUrl
      const formatted = banners.map((b) => {
        let fullUrl = '';
        if (b.imageUrl && b.imageUrl.trim().length > 0) {
          if (b.imageUrl.startsWith('http://') || b.imageUrl.startsWith('https://') || b.imageUrl.startsWith('assets/')) {
            fullUrl = b.imageUrl;
          } else {
            const cleanPath = b.imageUrl.startsWith('/') ? b.imageUrl : `/${b.imageUrl}`;
            fullUrl = `${baseUrl}${cleanPath}`;
          }
        }
        return {
          ...b,
          fullUrl,
        };
      });

      res.status(200).json({
        success: true,
        count: formatted.length,
        data: formatted,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/banners/upload (Upload banner image with instant WebP compression)
   */
  static async uploadBannerImage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.file) {
        res.status(400).json({ success: false, message: 'No banner image file uploaded' });
        return;
      }

      // Convert to WebP & compress (max width: 1920, quality: 85)
      const { filename, size } = await convertToWebP(req.file.path, {
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 85,
      });

      const host = req.get('host') || 'localhost:4000';
      const protocol = req.protocol || 'http';
      const baseUrl = process.env.API_BASE_URL || `${protocol}://${host}`;
      const relativePath = `/uploads/banners/${filename}`;
      const fullUrl = `${baseUrl}${relativePath}`;
      const slot = Number(req.body.slot || req.query.slot || 1);

      res.status(200).json({
        success: true,
        message: 'Banner image uploaded and optimized to WebP successfully',
        data: {
          slot,
          filename: filename,
          originalName: req.file.originalname,
          size: size,
          relativePath: relativePath,
          url: relativePath,
          fullUrl: fullUrl,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /api/v1/banners (Save / Update 3 banners from Admin)
   */
  static async saveBanners(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { banners } = req.body;
      if (!banners || !Array.isArray(banners)) {
        res.status(400).json({ success: false, message: 'Array of banners is required' });
        return;
      }

      const saved = await BannerService.saveBanners(banners);
      res.status(200).json({
        success: true,
        message: 'Banners updated successfully',
        data: saved,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/v1/banners/:slot (Delete banner, remove file from disk, reset slot)
   */
  static async deleteBanner(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const slot = Number(req.params.slot);
      if (isNaN(slot) || slot < 1 || slot > 3) {
        res.status(400).json({ success: false, message: 'Slot must be 1, 2, or 3' });
        return;
      }

      const updated = await BannerService.deleteBannerSlot(slot);
      res.status(200).json({
        success: true,
        message: `Banner Slot 0${slot} deleted and file removed from disk`,
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }
}
