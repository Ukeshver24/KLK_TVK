import { Request, Response, NextFunction } from 'express';
import { SystemSettingService } from '../services/system-setting.service';

export class SystemSettingController {
  /**
   * GET /api/v1/system/settings
   */
  static async getSettings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const settings = await SystemSettingService.getSettings();
      res.status(200).json({
        success: true,
        data: settings,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /api/v1/system/settings
   */
  static async updateSettings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const updated = await SystemSettingService.updateSettings(req.body);
      res.status(200).json({
        success: true,
        message: 'System settings updated successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }
}
