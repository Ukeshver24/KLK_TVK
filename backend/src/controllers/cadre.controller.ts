import { Request, Response, NextFunction } from 'express';
import { CadreService } from '../services/cadre.service';
import { AppError } from '../middlewares/error.middleware';

export class CadreController {
  /**
   * GET /api/v1/cadres
   */
  static async getAllCadres(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const cadres = await CadreService.getAllCadres({
        search: req.query.search as string,
        taluk: req.query.taluk as string,
        village: req.query.village as string,
        role: req.query.role as string,
      });

      res.status(200).json({
        success: true,
        data: cadres,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/cadres/:id
   */
  static async getCadreById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      const cadre = await CadreService.getCadreById(id);
      res.status(200).json({
        success: true,
        data: cadre,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/cadres
   */
  static async createCadre(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const cadre = await CadreService.createCadre(req.body);
      res.status(201).json({
        success: true,
        message: 'Cadre member created successfully',
        data: cadre,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /api/v1/cadres/:id
   */
  static async updateCadre(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      const cadre = await CadreService.updateCadre(id, req.body);
      res.status(200).json({
        success: true,
        message: 'Cadre member updated successfully',
        data: cadre,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/v1/cadres/:id
   */
  static async deleteCadre(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      const result = await CadreService.deleteCadre(id);
      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/cadres/:id/photo
   */
  static async uploadPhoto(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.file) {
        throw new AppError('No photo file uploaded', 400);
      }

      const id = String(req.params.id);
      const updated = await CadreService.uploadPhoto(id, req.file);
      res.status(200).json({
        success: true,
        message: 'Cadre photo uploaded successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }
}
