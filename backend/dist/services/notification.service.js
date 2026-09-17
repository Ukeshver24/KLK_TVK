"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationService = void 0;
const app_1 = require("firebase-admin/app");
const messaging_1 = require("firebase-admin/messaging");
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const db_1 = __importDefault(require("../config/db"));
class NotificationService {
    static app = null;
    /**
     * Safe initialization of Firebase Admin SDK using Service Account Key
     */
    static initFirebase() {
        if (this.app)
            return true;
        try {
            const existingApps = (0, app_1.getApps)();
            if (existingApps.length > 0) {
                this.app = existingApps[0];
                return true;
            }
            const serviceAccountPath = path_1.default.resolve(__dirname, '../config/firebase-service-account.json');
            if (!fs_1.default.existsSync(serviceAccountPath)) {
                console.warn('⚠️ Firebase Service Account Key not found at:', serviceAccountPath);
                return false;
            }
            const serviceAccount = JSON.parse(fs_1.default.readFileSync(serviceAccountPath, 'utf8'));
            this.app = (0, app_1.initializeApp)({
                credential: (0, app_1.cert)(serviceAccount),
            });
            console.log('✅ Firebase Admin SDK initialized successfully for Automated Push Notifications.');
            return true;
        }
        catch (error) {
            console.error('❌ Failed to initialize Firebase Admin SDK:', error);
            return false;
        }
    }
    /**
     * Send High-Priority Push Notification to a single device token
     */
    static async sendPushToToken(fcmToken, title, body, dataPayload = {}) {
        if (!this.initFirebase() || !this.app || !fcmToken || fcmToken.trim().length === 0) {
            return false;
        }
        try {
            const message = {
                token: fcmToken.trim(),
                notification: {
                    title,
                    body,
                },
                data: {
                    ...dataPayload,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                android: {
                    priority: 'high',
                    notification: {
                        icon: 'ic_notification',
                        color: '#8C0000',
                        channelId: 'tvk_high_importance_channel',
                        sound: 'default',
                        priority: 'max',
                        defaultSound: true,
                        defaultVibrateTimings: true,
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
            };
            const response = await (0, messaging_1.getMessaging)(this.app).send(message);
            console.log(`🚀 [PUSH NOTIFICATION SENT] Message ID: ${response} | Title: "${title}"`);
            return true;
        }
        catch (error) {
            console.error(`⚠️ [PUSH NOTIFICATION FAILED]:`, error?.message || error);
            return false;
        }
    }
    /**
     * Automatically generate and dispatch a push notification when Admin updates a Complaint Status
     */
    static async sendComplaintStatusPush(params) {
        try {
            const user = await db_1.default.user.findUnique({
                where: { id: params.userId },
                select: { fcmToken: true, fullName: true },
            });
            if (!user || !user.fcmToken) {
                console.log(`ℹ️ [PUSH SKIPPED] No FCM device token registered for user ${params.userId}`);
                return false;
            }
            let title = 'TVK குறைதீர்ப்பு மையம்';
            let body = `உங்கள் புகார் ${params.referenceId} நிலை புதுப்பிக்கப்பட்டுள்ளது.`;
            switch (params.status) {
                case 'UNDER_REVIEW':
                    title = 'புகார் பரிசீலனையில் உள்ளது ⏳';
                    body = `வணக்கம் ${user.fullName}, உங்கள் புகார் (${params.referenceId}) சட்டமன்ற உறுப்பினர் அலுவலகத்தில் பரிசீலனைக்கு ஏற்றுக்கொள்ளப்பட்டது.`;
                    break;
                case 'OFFICER_ASSIGNED':
                    title = 'TVK களப்பணியாளர் நியமிக்கப்பட்டுள்ளார் 🤝';
                    body = `உங்கள் புகார் (${params.referenceId})-க்கு பொறுப்பாளர் ${params.cadreName || ''} களப்பணிக்கு நியமிக்கப்பட்டுள்ளார்.`;
                    break;
                case 'IN_PROGRESS':
                    title = 'புகார் மீது நடவடிக்கை எடுக்கப்படுகிறது 🚩';
                    body = `உங்கள் புகார் (${params.referenceId}) மீது களப்பணிகள் மற்றும் ஆய்வுகள் விறுவிறுப்பாக நடைபெற்று வருகின்றன.`;
                    break;
                case 'RESOLVED':
                    title = 'உங்கள் புகார் வெற்றிகரமாக தீர்க்கப்பட்டது! 🎉';
                    body = `உங்கள் புகார் (${params.referenceId}) வெற்றிகரமாக தீர்க்கப்பட்டு நிறைவடைந்தது. TVK எப்போதும் உங்கள் சேவையில்!`;
                    break;
                case 'REJECTED':
                    title = 'புகார் நிலை பற்றிய தகவல் 📋';
                    body = `உங்கள் புகார் (${params.referenceId}) பரிசீலிக்கப்பட்டு முடிவு தெரிவிக்கப்பட்டுள்ளது. ${params.remarks ? `காரணம்: ${params.remarks}` : ''}`;
                    break;
                case 'OTHERS':
                    title = 'நிர்வாக அறிவிப்பு / விளக்கம் 📢';
                    body = `உங்கள் புகார் (${params.referenceId}) பற்றி நிர்வாக அறிவிப்பு வெளியிடப்பட்டுள்ளது: ${params.remarks || ''}`;
                    break;
            }
            return await this.sendPushToToken(user.fcmToken, title, body, {
                type: 'COMPLAINT_STATUS_UPDATE',
                referenceId: params.referenceId,
                status: params.status,
            });
        }
        catch (error) {
            console.error('Error dispatching automated complaint push:', error);
            return false;
        }
    }
    /**
     * Broadcast push notification to all registered citizens
     */
    static async sendBroadcastAlertPush(title, messageText) {
        try {
            const users = await db_1.default.user.findMany({
                where: {
                    fcmToken: { not: null },
                    status: 'ACTIVE',
                },
                select: { fcmToken: true },
            });
            const tokens = users.map((u) => u.fcmToken).filter((t) => t && t.trim().length > 0);
            if (tokens.length === 0) {
                console.log('ℹ️ [BROADCAST PUSH] No registered FCM tokens found.');
                return;
            }
            if (!this.initFirebase() || !this.app) {
                console.log('⚠️ [BROADCAST PUSH] Firebase not initialized. Skipping broadcast.');
                return;
            }
            console.log(`📢 [BROADCAST PUSH] Dispatching to ${tokens.length} registered citizens...`);
            // FCM sendEachForMulticast accepts max 500 tokens per call
            const batchSize = 500;
            let totalSuccess = 0;
            let totalFailure = 0;
            for (let i = 0; i < tokens.length; i += batchSize) {
                const tokenBatch = tokens.slice(i, i + batchSize);
                const multicastPayload = {
                    tokens: tokenBatch,
                    notification: { title, body: messageText },
                    android: {
                        priority: 'high',
                        notification: {
                            channelId: 'tvk_high_importance_channel',
                            icon: 'ic_notification',
                            color: '#8C0000',
                            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                            sound: 'default',
                            priority: 'max',
                            defaultSound: true,
                            defaultVibrateTimings: true,
                        },
                    },
                    data: {
                        type: 'BROADCAST_ALERT',
                        title,
                        message: messageText,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                };
                const response = await (0, messaging_1.getMessaging)(this.app).sendEachForMulticast(multicastPayload);
                totalSuccess += response.successCount;
                totalFailure += response.failureCount;
            }
            console.log(`📢 [BROADCAST PUSH COMPLETED]: ${totalSuccess} sent successfully, ${totalFailure} failed.`);
        }
        catch (error) {
            console.error('Error in sendBroadcastAlertPush:', error);
        }
    }
}
exports.NotificationService = NotificationService;
