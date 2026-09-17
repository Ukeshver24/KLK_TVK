"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SystemSettingService = void 0;
const db_1 = __importDefault(require("../config/db"));
class SystemSettingService {
    static DEFAULT_SETTINGS = {
        id: 'singleton',
        maintenanceMode: false,
        maintenanceTitleEn: 'Under Scheduled Maintenance',
        maintenanceTitleTa: 'பராமரிப்பு பணியில் உள்ளது',
        maintenanceMsgEn: 'We are currently upgrading our systems to serve you better. The app will be back online shortly.',
        maintenanceMsgTa: 'சேவையக மேம்பாட்டு பணிகள் நடைபெற்று வருகின்றன. செயலி விரைவில் மீண்டும் பயன்பாட்டுக்கு வரும்.',
        minAppVersion: '1.0.0',
        latestAppVersion: '1.0.0',
        forceUpdate: false,
        playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example.tvk_application',
        appStoreUrl: 'https://apps.apple.com/app/id6400000000',
        updateTitleEn: 'Update Required',
        updateTitleTa: 'புதிய பதிப்பு கிடைக்கிறது',
        updateMsgEn: 'A new version of the app is available. Please update to continue using the app with the latest features and improvements.',
        updateMsgTa: 'செயலியின் புதிய பதிப்பு கிடைக்கிறது. புதிய அம்சங்களுடன் தொடர்ந்து பயன்பாட்டிற்கு செயலியைப் புதுப்பிக்கவும்.',
    };
    static async getSettings() {
        let settings = await db_1.default.systemSetting.findFirst({
            where: { id: 'singleton' },
        });
        if (!settings) {
            settings = await db_1.default.systemSetting.create({
                data: this.DEFAULT_SETTINGS,
            });
        }
        return settings;
    }
    static async updateSettings(data) {
        const existing = await this.getSettings();
        const updated = await db_1.default.systemSetting.update({
            where: { id: existing.id },
            data: {
                maintenanceMode: data.maintenanceMode !== undefined ? data.maintenanceMode : existing.maintenanceMode,
                maintenanceTitleEn: data.maintenanceTitleEn !== undefined ? data.maintenanceTitleEn.trim() : existing.maintenanceTitleEn,
                maintenanceTitleTa: data.maintenanceTitleTa !== undefined ? data.maintenanceTitleTa.trim() : existing.maintenanceTitleTa,
                maintenanceMsgEn: data.maintenanceMsgEn !== undefined ? data.maintenanceMsgEn.trim() : existing.maintenanceMsgEn,
                maintenanceMsgTa: data.maintenanceMsgTa !== undefined ? data.maintenanceMsgTa.trim() : existing.maintenanceMsgTa,
                minAppVersion: data.minAppVersion !== undefined ? data.minAppVersion.trim() : existing.minAppVersion,
                latestAppVersion: data.latestAppVersion !== undefined ? data.latestAppVersion.trim() : existing.latestAppVersion,
                forceUpdate: data.forceUpdate !== undefined ? data.forceUpdate : existing.forceUpdate,
                playStoreUrl: data.playStoreUrl !== undefined ? data.playStoreUrl.trim() : existing.playStoreUrl,
                appStoreUrl: data.appStoreUrl !== undefined ? data.appStoreUrl.trim() : existing.appStoreUrl,
                updateTitleEn: data.updateTitleEn !== undefined ? data.updateTitleEn.trim() : existing.updateTitleEn,
                updateTitleTa: data.updateTitleTa !== undefined ? data.updateTitleTa.trim() : existing.updateTitleTa,
                updateMsgEn: data.updateMsgEn !== undefined ? data.updateMsgEn.trim() : existing.updateMsgEn,
                updateMsgTa: data.updateMsgTa !== undefined ? data.updateMsgTa.trim() : existing.updateMsgTa,
            },
        });
        return updated;
    }
}
exports.SystemSettingService = SystemSettingService;
