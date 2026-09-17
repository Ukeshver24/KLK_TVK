"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CadreController = void 0;
const cadre_service_1 = require("../services/cadre.service");
const error_middleware_1 = require("../middlewares/error.middleware");
class CadreController {
    /**
     * GET /api/v1/cadres
     */
    static async getAllCadres(req, res, next) {
        try {
            const cadres = await cadre_service_1.CadreService.getAllCadres({
                search: req.query.search,
                taluk: req.query.taluk,
                village: req.query.village,
                role: req.query.role,
            });
            res.status(200).json({
                success: true,
                data: cadres,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/cadres/:id
     */
    static async getCadreById(req, res, next) {
        try {
            const id = String(req.params.id);
            const cadre = await cadre_service_1.CadreService.getCadreById(id);
            res.status(200).json({
                success: true,
                data: cadre,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/cadres
     */
    static async createCadre(req, res, next) {
        try {
            const cadre = await cadre_service_1.CadreService.createCadre(req.body);
            res.status(201).json({
                success: true,
                message: 'Cadre member created successfully',
                data: cadre,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * PUT /api/v1/cadres/:id
     */
    static async updateCadre(req, res, next) {
        try {
            const id = String(req.params.id);
            const cadre = await cadre_service_1.CadreService.updateCadre(id, req.body);
            res.status(200).json({
                success: true,
                message: 'Cadre member updated successfully',
                data: cadre,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * DELETE /api/v1/cadres/:id
     */
    static async deleteCadre(req, res, next) {
        try {
            const id = String(req.params.id);
            const result = await cadre_service_1.CadreService.deleteCadre(id);
            res.status(200).json({
                success: true,
                message: result.message,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/cadres/:id/photo
     */
    static async uploadPhoto(req, res, next) {
        try {
            if (!req.file) {
                throw new error_middleware_1.AppError('No photo file uploaded', 400);
            }
            const id = String(req.params.id);
            const updated = await cadre_service_1.CadreService.uploadPhoto(id, req.file);
            res.status(200).json({
                success: true,
                message: 'Cadre photo uploaded successfully',
                data: updated,
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.CadreController = CadreController;
