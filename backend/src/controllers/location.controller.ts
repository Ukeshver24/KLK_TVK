import { Request, Response, NextFunction } from 'express';
import { LocationService } from '../services/location.service';

export class LocationController {
  /**
   * GET /api/v1/locations/taluks
   * Fetch all distinct taluks (dynamic from DB merged with standard taluks)
   */
  static async getTaluks(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const taluks = await LocationService.getTaluks();
      res.status(200).json({
        success: true,
        count: taluks.length,
        data: taluks,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/locations/villages
   * Fetch active villages (optionally filtered by taluk in English or Tamil)
   */
  static async getVillages(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const taluk = req.query.taluk as string | undefined;
      const includeInactive = req.query.includeInactive === 'true';
      const villages = await LocationService.getVillages(taluk, includeInactive);
      res.status(200).json({
        success: true,
        count: villages.length,
        data: villages,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/locations/villages (Admin: Add single village)
   */
  static async createVillage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const village = await LocationService.createVillage(req.body);
      res.status(201).json({
        success: true,
        message: 'Village added successfully with dual-language support',
        data: village,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/locations/villages/bulk (Admin: Bulk upload villages)
   */
  static async bulkCreateVillages(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { villages } = req.body;
      if (!Array.isArray(villages)) {
        res.status(400).json({ success: false, message: 'Expected an array of villages' });
        return;
      }
      const result = await LocationService.bulkCreateVillages(villages);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /api/v1/locations/villages/:id (Admin: Edit/Update village)
   */
  static async updateVillage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      const updated = await LocationService.updateVillage(id, req.body);
      res.status(200).json({
        success: true,
        message: 'Village updated successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/v1/locations/villages/:id (Admin: Delete village)
   */
  static async deleteVillage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      await LocationService.deleteVillage(id);
      res.status(200).json({
        success: true,
        message: 'Village deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/locations/villages/bulk-delete (Admin: Bulk delete villages)
   */
  static async bulkDeleteVillages(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { ids } = req.body;
      if (!Array.isArray(ids) || ids.length === 0) {
        res.status(400).json({ success: false, message: 'Array of village IDs required' });
        return;
      }
      const result = await LocationService.bulkDeleteVillages(ids);
      res.status(200).json({
        success: true,
        count: result.count,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }
}
