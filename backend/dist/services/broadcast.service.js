"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BroadcastService = void 0;
const db_1 = __importDefault(require("../config/db"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const client_1 = require("@prisma/client");
const notification_service_1 = require("./notification.service");
class BroadcastService {
    static DEFAULT_ALERT = {
        id: 'singleton',
        title: 'கள்ளக்குறிச்சி பொதுமக்களுக்கு முக்கிய அவசர அறிவிப்பு!',
        message: 'கள்ளக்குறிச்சி மற்றும் சின்னசேலம் பகுதிகளில் பெய்து வரும் கனமழை காரணமாக தாழ்வான பகுதிகளில் உள்ள பொதுமக்கள் பாதுகாப்பாக இருக்குமாறு கேட்டுக்கொள்ளப்படுகிறார்கள். ஏதேனும் அவசர உதவி தேவைப்பட்டால் உடனே நமது TVK 24x7 கட்டுப்பாட்டு அறையை தொடர்பு கொள்ளவும்.',
        severity: client_1.AlertSeverity.EMERGENCY,
        imageUrl: null,
        isActive: true,
        targetScope: 'Entire Kallakurichi Constituency (79)',
        showFrequency: client_1.AlertFrequency.EVERY_OPEN,
        authorTag: 'From the Desk of MLA',
    };
    /**
     * Fetch singleton broadcast alert (auto-seeds default if not found)
     */
    static async getActiveAlert() {
        let alert = await db_1.default.broadcastAlert.findFirst({
            where: { id: 'singleton' },
        });
        if (!alert) {
            alert = await db_1.default.broadcastAlert.create({
                data: this.DEFAULT_ALERT,
            });
        }
        const fullImageUrl = alert.imageUrl
            ? (alert.imageUrl.startsWith('http') || alert.imageUrl.startsWith('data:')
                ? alert.imageUrl
                : `/uploads/broadcasts/${alert.imageUrl.replace(/^\/uploads\/broadcasts\//, '')}`)
            : null;
        return {
            ...alert,
            fullImageUrl,
        };
    }
    /**
     * Update active broadcast alert settings
     */
    static async updateAlert(data) {
        const existing = await this.getActiveAlert();
        // If new image url provided or cleared, delete old file from disk if replaced
        if (data.imageUrl !== undefined && existing.imageUrl && existing.imageUrl !== data.imageUrl) {
            this.deletePhysicalPosterFile(existing.imageUrl);
        }
        const updated = await db_1.default.broadcastAlert.update({
            where: { id: existing.id },
            data: {
                title: data.title !== undefined ? data.title.trim() : existing.title,
                message: data.message !== undefined ? data.message.trim() : existing.message,
                severity: data.severity !== undefined ? data.severity : existing.severity,
                imageUrl: data.imageUrl !== undefined ? data.imageUrl : existing.imageUrl,
                isActive: data.isActive !== undefined ? data.isActive : existing.isActive,
                targetScope: data.targetScope !== undefined ? data.targetScope.trim() : existing.targetScope,
                showFrequency: data.showFrequency !== undefined ? data.showFrequency : existing.showFrequency,
                authorTag: data.authorTag !== undefined ? data.authorTag.trim() : 'From the Desk of MLA',
            },
        });
        const fullImageUrl = updated.imageUrl
            ? (updated.imageUrl.startsWith('http') || updated.imageUrl.startsWith('data:')
                ? updated.imageUrl
                : `/uploads/broadcasts/${updated.imageUrl.replace(/^\/uploads\/broadcasts\//, '')}`)
            : null;
        // 🚀 Automatically broadcast push notification to all citizens when published live!
        if (updated.isActive) {
            notification_service_1.NotificationService.sendBroadcastAlertPush(updated.title, updated.message).catch((err) => {
                console.error('Error dispatching broadcast push notification:', err);
            });
        }
        return {
            ...updated,
            fullImageUrl,
        };
    }
    /**
     * Handle poster image upload
     */
    static async uploadPoster(file) {
        const existing = await this.getActiveAlert();
        if (existing.imageUrl) {
            this.deletePhysicalPosterFile(existing.imageUrl);
        }
        const relativePath = `/uploads/broadcasts/${file.filename}`;
        const updated = await db_1.default.broadcastAlert.update({
            where: { id: existing.id },
            data: { imageUrl: relativePath },
        });
        return {
            relativePath,
            fullImageUrl: relativePath,
            alert: updated,
        };
    }
    /**
     * Delete poster image
     */
    static async deletePoster() {
        const existing = await this.getActiveAlert();
        if (existing.imageUrl) {
            this.deletePhysicalPosterFile(existing.imageUrl);
        }
        const updated = await db_1.default.broadcastAlert.update({
            where: { id: existing.id },
            data: { imageUrl: null },
        });
        return {
            success: true,
            alert: updated,
        };
    }
    /**
     * Helper to delete physical file on disk
     */
    static deletePhysicalPosterFile(imagePath) {
        try {
            if (imagePath && !imagePath.startsWith('http') && !imagePath.startsWith('data:')) {
                const filename = imagePath.replace(/^\/uploads\/broadcasts\//, '').replace(/^uploads\/broadcasts\//, '');
                const fullDiskPath = path_1.default.resolve(process.cwd(), 'uploads', 'broadcasts', filename);
                if (fs_1.default.existsSync(fullDiskPath)) {
                    fs_1.default.unlinkSync(fullDiskPath);
                }
            }
        }
        catch (err) {
            console.error('Error cleaning old poster image from disk:', err);
        }
    }
}
exports.BroadcastService = BroadcastService;
