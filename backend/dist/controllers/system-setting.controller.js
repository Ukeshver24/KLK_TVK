"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SystemSettingController = void 0;
const system_setting_service_1 = require("../services/system-setting.service");
class SystemSettingController {
    /**
     * GET /api/v1/system/settings
     */
    static async getSettings(req, res, next) {
        try {
            const settings = await system_setting_service_1.SystemSettingService.getSettings();
            res.status(200).json({
                success: true,
                data: settings,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * PUT /api/v1/system/settings
     */
    static async updateSettings(req, res, next) {
        try {
            const updated = await system_setting_service_1.SystemSettingService.updateSettings(req.body);
            res.status(200).json({
                success: true,
                message: 'System settings updated successfully',
                data: updated,
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.SystemSettingController = SystemSettingController;
