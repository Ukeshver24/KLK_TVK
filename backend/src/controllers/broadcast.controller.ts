import { Request, Response, NextFunction } from 'express';
import { BroadcastService } from '../services/broadcast.service';
import { AppError } from '../middlewares/error.middleware';

export class BroadcastController {
  /**
   * GET /api/v1/broadcasts/active
   */
  static async getActiveAlert(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const alert = await BroadcastService.getActiveAlert();
      res.status(200).json({
        success: true,
        data: alert,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /api/v1/broadcasts/active
   */
  static async updateAlert(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const updated = await BroadcastService.updateAlert(req.body);
      res.status(200).json({
        success: true,
        message: 'Broadcast alert updated successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/broadcasts/poster
   */
  static async uploadPoster(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.file) {
        throw new AppError('No poster file uploaded', 400);
      }

      const result = await BroadcastService.uploadPoster(req.file);
      res.status(200).json({
        success: true,
        message: 'Poster uploaded successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/v1/broadcasts/poster
   */
  static async deletePoster(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await BroadcastService.deletePoster();
      res.status(200).json({
        success: true,
        message: 'Poster removed successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}
