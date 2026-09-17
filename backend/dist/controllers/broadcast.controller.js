"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BroadcastController = void 0;
const broadcast_service_1 = require("../services/broadcast.service");
const error_middleware_1 = require("../middlewares/error.middleware");
class BroadcastController {
    /**
     * GET /api/v1/broadcasts/active
     */
    static async getActiveAlert(req, res, next) {
        try {
            const alert = await broadcast_service_1.BroadcastService.getActiveAlert();
            res.status(200).json({
                success: true,
                data: alert,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * PUT /api/v1/broadcasts/active
     */
    static async updateAlert(req, res, next) {
        try {
            const updated = await broadcast_service_1.BroadcastService.updateAlert(req.body);
            res.status(200).json({
                success: true,
                message: 'Broadcast alert updated successfully',
                data: updated,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/broadcasts/poster
     */
    static async uploadPoster(req, res, next) {
        try {
            if (!req.file) {
                throw new error_middleware_1.AppError('No poster file uploaded', 400);
            }
            const result = await broadcast_service_1.BroadcastService.uploadPoster(req.file);
            res.status(200).json({
                success: true,
                message: 'Poster uploaded successfully',
                data: result,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * DELETE /api/v1/broadcasts/poster
     */
    static async deletePoster(req, res, next) {
        try {
            const result = await broadcast_service_1.BroadcastService.deletePoster();
            res.status(200).json({
                success: true,
                message: 'Poster removed successfully',
                data: result,
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.BroadcastController = BroadcastController;
