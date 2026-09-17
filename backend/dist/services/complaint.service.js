"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ComplaintService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const db_1 = __importDefault(require("../config/db"));
const error_middleware_1 = require("../middlewares/error.middleware");
const notification_service_1 = require("./notification.service");
const auth_service_1 = require("./auth.service");
class ComplaintService {
    /**
     * Helper: Normalize status string from frontend (e.g. IN_REVIEW -> UNDER_REVIEW)
     */
    static normalizeStatus(rawStatus) {
        if (!rawStatus)
            return '';
        const s = String(rawStatus).toUpperCase().trim().replace(/[\s-]+/g, '_');
        if (s === 'IN_REVIEW' || s === 'UNDER_VERIFICATION' || s === 'UNDER_REVIEW')
            return 'UNDER_REVIEW';
        if (s === 'OFFICER_ASSIGNED' || s === 'ASSIGNED' || s === 'OFFICER')
            return 'OFFICER_ASSIGNED';
        if (s === 'IN_PROGRESS' || s === 'ACTION_TAKEN' || s === 'PROCESSING' || s === 'INPROGRESS')
            return 'IN_PROGRESS';
        if (s === 'RESOLVED' || s === 'COMPLETED')
            return 'RESOLVED';
        if (s === 'REJECTED' || s === 'CLOSED')
            return 'REJECTED';
        if (s === 'SUBMITTED' || s === 'NEW' || s === 'REGISTERED')
            return 'SUBMITTED';
        if (s === 'OTHERS' || s === 'NOTICE')
            return 'OTHERS';
        return s;
    }
    /**
     * Generate Next Sequential Grievance Token ID (e.g., TVK-KKI-26-0001)
     */
    static async generateReferenceId() {
        const currentYear = new Date().getFullYear().toString().slice(-2); // "26"
        const prefix = `TVK-KKI-${currentYear}-`;
        try {
            const result = await db_1.default.$queryRaw `SELECT nextval('complaint_ref_seq') as seq`;
            const seq = Number(result[0]?.seq || 1);
            return `${prefix}${String(seq).padStart(4, '0')}`;
        }
        catch {
            const count = await db_1.default.complaint.count();
            return `${prefix}${String(count + 1).padStart(4, '0')}`;
        }
    }
    /**
     * Register a new complaint for a citizen
     */
    static async registerComplaint(input) {
        // Validate or auto-resolve user account in database before proceeding
        let validUserId = input.userId;
        let existingUser = null;
        if (input.userId) {
            existingUser = await db_1.default.user.findUnique({
                where: { id: input.userId },
                select: { id: true },
            });
        }
        if (!existingUser && input.mobile) {
            existingUser = await db_1.default.user.findUnique({
                where: { mobile: input.mobile.trim() },
                select: { id: true },
            });
        }
        if (existingUser) {
            validUserId = existingUser.id;
        }
        else if (input.mobile && input.mobile.trim().length >= 10) {
            // Auto-register citizen in DB so grievances are never blocked or lost
            try {
                const userCode = await auth_service_1.AuthService.generateUserCode('CITIZEN');
                const defaultHash = await bcryptjs_1.default.hash('0000', 6);
                const newUser = await db_1.default.user.create({
                    data: {
                        userCode,
                        fullName: input.fullName?.trim() || 'Citizen',
                        mobile: input.mobile.trim(),
                        address: input.address?.trim() || null,
                        mpinHash: defaultHash,
                        role: 'CITIZEN',
                        status: 'ACTIVE',
                    },
                });
                validUserId = newUser.id;
            }
            catch (userCreateErr) {
                console.error('Error auto-creating citizen during complaint registration:', userCreateErr);
                const fallbackUser = await db_1.default.user.findUnique({
                    where: { mobile: input.mobile.trim() },
                    select: { id: true },
                });
                if (fallbackUser) {
                    validUserId = fallbackUser.id;
                }
                else {
                    throw new error_middleware_1.AppError('User not found. Please log in or register again.', 401);
                }
            }
        }
        else {
            throw new error_middleware_1.AppError('A valid mobile number is required to register a complaint.', 400);
        }
        const referenceId = await this.generateReferenceId();
        const createdComplaint = await db_1.default.complaint.create({
            data: {
                referenceId,
                userId: validUserId,
                fullName: input.fullName.trim(),
                mobile: input.mobile.trim(),
                taluk: input.taluk.trim(),
                village: input.village.trim(),
                address: input.address.trim(),
                pincode: input.pincode.trim(),
                category: input.category.trim(),
                description: input.description.trim(),
                attachment: input.attachment || null,
                latitude: input.latitude ? Number(input.latitude) : null,
                longitude: input.longitude ? Number(input.longitude) : null,
                locationUrl: input.locationUrl || (input.latitude && input.longitude ? `https://www.google.com/maps?q=${input.latitude},${input.longitude}` : null),
                status: 'SUBMITTED',
                timelineEvents: [
                    {
                        step: 1,
                        status: 'SUBMITTED',
                        titleEn: '1. Grievance Registered by Citizen',
                        titleTa: '1. மனுதாரரால் புகார் பதிவு செய்யப்பட்டது',
                        date: this.formatTimelineDate(new Date()),
                        isCompleted: true,
                        isNotice: false,
                    },
                ],
            },
        });
        return createdComplaint;
    }
    /**
     * Fetch all complaints filed by a specific user (Mobile History)
     */
    static async getUserComplaints(userId) {
        return db_1.default.complaint.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            include: {
                user: {
                    select: {
                        userCode: true,
                        fullName: true,
                        mobile: true,
                    },
                },
                assignedCadre: true,
            },
        });
    }
    static async getCitizenComplaints(userId) {
        return this.getUserComplaints(userId);
    }
    /**
     * Track complaints by Reference ID or Registered Mobile Number
     */
    static async trackComplaints(query) {
        const cleanQuery = query.trim();
        if (!cleanQuery) {
            throw new error_middleware_1.AppError('Reference ID or Mobile Number is required', 400);
        }
        const cleanPhone = cleanQuery.replace('+91', '').replace(/\s+/g, '').trim();
        const isNumericPhone = /^\d{7,15}$/.test(cleanPhone);
        if (isNumericPhone) {
            return db_1.default.complaint.findMany({
                where: {
                    OR: [
                        { mobile: { contains: cleanPhone } },
                        { user: { mobile: { contains: cleanPhone } } },
                    ],
                },
                orderBy: { createdAt: 'desc' },
                include: {
                    user: {
                        select: {
                            userCode: true,
                            fullName: true,
                            mobile: true,
                        },
                    },
                },
            });
        }
        // Search by Reference ID (exact match)
        const exact = await db_1.default.complaint.findMany({
            where: {
                referenceId: {
                    equals: cleanQuery,
                    mode: 'insensitive',
                },
            },
            orderBy: { createdAt: 'desc' },
            include: {
                user: {
                    select: {
                        userCode: true,
                        fullName: true,
                        mobile: true,
                    },
                },
            },
        });
        if (exact.length > 0) {
            return exact;
        }
        // Partial search
        return db_1.default.complaint.findMany({
            where: {
                referenceId: {
                    contains: cleanQuery,
                    mode: 'insensitive',
                },
            },
            orderBy: { createdAt: 'desc' },
            include: {
                user: {
                    select: {
                        userCode: true,
                        fullName: true,
                        mobile: true,
                    },
                },
            },
        });
    }
    /**
     * Admin: Fetch all complaints with filters
     */
    static async getAllComplaints(filters) {
        const where = {};
        if (filters.status)
            where.status = this.normalizeStatus(filters.status);
        if (filters.category)
            where.category = filters.category;
        if (filters.village)
            where.village = filters.village;
        return db_1.default.complaint.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            include: {
                user: {
                    select: {
                        userCode: true,
                        fullName: true,
                        mobile: true,
                    },
                },
                assignedCadre: true,
            },
        });
    }
    static formatTimelineDate(d = new Date()) {
        try {
            const formatter = new Intl.DateTimeFormat('en-IN', {
                timeZone: 'Asia/Kolkata',
                day: '2-digit',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                hour12: true,
            });
            const parts = formatter.formatToParts(d);
            const day = parts.find((p) => p.type === 'day')?.value || String(d.getDate()).padStart(2, '0');
            const month = parts.find((p) => p.type === 'month')?.value || 'Aug';
            const year = parts.find((p) => p.type === 'year')?.value || String(d.getFullYear());
            const hour = parts.find((p) => p.type === 'hour')?.value || '12';
            const minute = parts.find((p) => p.type === 'minute')?.value || '00';
            const dayPeriod = (parts.find((p) => p.type === 'dayPeriod')?.value || 'AM').toUpperCase();
            return `${day} ${month} ${year}, ${hour}:${minute} ${dayPeriod}`;
        }
        catch {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            const day = String(d.getDate()).padStart(2, '0');
            const month = months[d.getMonth()];
            const year = d.getFullYear();
            let hours = d.getHours();
            const minutes = String(d.getMinutes()).padStart(2, '0');
            const ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12 || 12;
            const hourStr = String(hours).padStart(2, '0');
            return `${day} ${month} ${year}, ${hourStr}:${minutes} ${ampm}`;
        }
    }
    /**
     * Admin: Update status, assigned cadre, and remarks of a complaint
     */
    static async updateComplaintStatus(id, data) {
        const complaint = await db_1.default.complaint.findUnique({ where: { id } });
        if (!complaint) {
            throw new error_middleware_1.AppError('Complaint not found', 404);
        }
        const updateData = {};
        const normalizedStatus = this.normalizeStatus(data.status);
        if (normalizedStatus) {
            updateData.status = normalizedStatus;
        }
        if (data.assignedCadreId !== undefined) {
            updateData.assignedCadreId = data.assignedCadreId || null;
        }
        if (data.adminRemarks !== undefined) {
            updateData.adminRemarks = data.adminRemarks;
        }
        if (data.statusReason !== undefined) {
            updateData.statusReason = data.statusReason;
        }
        // Timeline Configuration mapping
        const stepDefinitions = {
            SUBMITTED: {
                step: 1,
                titleEn: '1. Grievance Registered by Citizen',
                titleTa: '1. மனுதாரரால் புகார் பதிவு செய்யப்பட்டது',
            },
            UNDER_REVIEW: {
                step: 2,
                titleEn: '2. Grievance Under Review',
                titleTa: '2. சட்டமன்ற உறுப்பினர் அலுவலகத்தில் பரிசீலனை',
            },
            OFFICER_ASSIGNED: {
                step: 3,
                titleEn: '3. Officer Assigned for Action',
                titleTa: '3. களப் பொறுப்பாளர் ஆய்வு பணி ஒதுக்கீடு',
            },
            IN_PROGRESS: {
                step: 4,
                titleEn: '4. Action in Progress',
                titleTa: '4. களப்பணிகள் நடைபெற்று வருகின்றன',
            },
            RESOLVED: {
                step: 5,
                titleEn: '5. Grievance Successfully Resolved',
                titleTa: '5. புகார் வெற்றிகரமாக தீர்க்கப்பட்டது',
            },
            REJECTED: {
                step: 6,
                titleEn: '6. Grievance Rejected / Closed',
                titleTa: '6. புகார் பரிசீலிக்கப்பட்டு முடித்து வைக்கப்பட்டது',
            },
            OTHERS: {
                step: 99,
                titleEn: 'Official Notice / Administrative Update',
                titleTa: 'நிர்வாக அறிவிப்பு / காரண விளக்கம்',
            },
        };
        // Standard sequence of stages
        const progressiveStages = ['SUBMITTED', 'UNDER_REVIEW', 'OFFICER_ASSIGNED', 'IN_PROGRESS', 'RESOLVED'];
        // Load existing events
        let events = [];
        if (Array.isArray(complaint.timelineEvents) && complaint.timelineEvents.length > 0) {
            events = [...complaint.timelineEvents];
        }
        else {
            events = [
                {
                    step: 1,
                    status: 'SUBMITTED',
                    titleEn: stepDefinitions.SUBMITTED.titleEn,
                    titleTa: stepDefinitions.SUBMITTED.titleTa,
                    date: this.formatTimelineDate(complaint.createdAt),
                    isCompleted: true,
                    isNotice: false,
                },
            ];
        }
        const nowStr = this.formatTimelineDate();
        const notes = (data.statusReason && data.statusReason.trim()) || (data.adminRemarks && data.adminRemarks.trim()) || undefined;
        // Helper: Determine the active stage step number (1=SUBMITTED, 2=UNDER_REVIEW, 3=OFFICER_ASSIGNED, 4=IN_PROGRESS, 5=RESOLVED)
        const getActiveStageStep = () => {
            const standardSteps = events.filter((e) => !e.isNotice && typeof e.step === 'number' && e.step <= 10);
            if (standardSteps.length === 0)
                return 1;
            return Math.max(...standardSteps.map((e) => e.step));
        };
        if (normalizedStatus && stepDefinitions[normalizedStatus]) {
            if (normalizedStatus === 'OTHERS') {
                // Keep existing complaint status or set to OTHERS, but place notice right after active stage
                const currentStageStep = getActiveStageStep();
                const existingNoticesAtThisStage = events.filter((e) => e.isNotice && typeof e.step === 'number' && Math.floor(e.step) === currentStageStep);
                const noticeStep = Number((currentStageStep + (existingNoticesAtThisStage.length + 1) * 0.1).toFixed(2));
                events.push({
                    step: noticeStep,
                    status: 'OTHERS',
                    titleEn: 'Official Notice / Reason for Delay',
                    titleTa: 'நிர்வாக அறிவிப்பு / தாமத விளக்கம்',
                    notes: notes || 'Administrative notice issued',
                    date: nowStr,
                    isCompleted: true,
                    isNotice: true,
                });
                // Don't downgrade complaint status if already progressed
                updateData.status = complaint.status || 'SUBMITTED';
            }
            else {
                const targetIndex = progressiveStages.indexOf(normalizedStatus);
                if (targetIndex >= 0) {
                    // Ensure all progressive stages up to targetIndex exist in timeline
                    for (let i = 0; i <= targetIndex; i++) {
                        const st = progressiveStages[i];
                        const def = stepDefinitions[st];
                        const existingIdx = events.findIndex((e) => e.status === st && !e.isNotice);
                        if (existingIdx >= 0) {
                            // If it's the target step being updated now, refresh its timestamp & notes
                            if (st === normalizedStatus) {
                                events[existingIdx] = {
                                    ...events[existingIdx],
                                    date: nowStr,
                                    isCompleted: true,
                                    ...(notes ? { notes } : {}),
                                };
                            }
                        }
                        else {
                            // Add missing stage
                            events.push({
                                step: def.step,
                                status: st,
                                titleEn: def.titleEn,
                                titleTa: def.titleTa,
                                date: nowStr,
                                isCompleted: true,
                                isNotice: false,
                                ...(st === normalizedStatus && notes ? { notes } : {}),
                            });
                        }
                    }
                }
                else {
                    // For REJECTED
                    const def = stepDefinitions[normalizedStatus];
                    events.push({
                        step: def.step,
                        status: normalizedStatus,
                        titleEn: def.titleEn,
                        titleTa: def.titleTa,
                        date: nowStr,
                        isCompleted: true,
                        isNotice: false,
                        ...(notes ? { notes } : {}),
                    });
                }
            }
        }
        else if (data.statusReason && data.statusReason.trim().length > 0) {
            // Standalone delay/administrative notice
            const currentStageStep = getActiveStageStep();
            const existingNoticesAtThisStage = events.filter((e) => e.isNotice && typeof e.step === 'number' && Math.floor(e.step) === currentStageStep);
            const noticeStep = Number((currentStageStep + (existingNoticesAtThisStage.length + 1) * 0.1).toFixed(2));
            events.push({
                step: noticeStep,
                status: 'OTHERS',
                titleEn: 'Official Notice / Reason for Delay',
                titleTa: 'நிர்வாக அறிவிப்பு / தாமத விளக்கம்',
                notes: data.statusReason.trim(),
                date: nowStr,
                isCompleted: true,
                isNotice: true,
            });
        }
        // Sort events strictly by step number (e.g., 1 -> 1.1 -> 2 -> 2.1 -> 3 -> 4 -> 5)
        events.sort((a, b) => (Number(a.step) || 0) - (Number(b.step) || 0));
        updateData.timelineEvents = events;
        const updatedComplaint = await db_1.default.complaint.update({
            where: { id },
            data: updateData,
            include: {
                user: {
                    select: {
                        id: true,
                        userCode: true,
                        fullName: true,
                        mobile: true,
                        fcmToken: true,
                    },
                },
                assignedCadre: true,
            },
        });
        // 🚀 Automatically push notification to citizen's mobile phone
        if (normalizedStatus) {
            notification_service_1.NotificationService.sendComplaintStatusPush({
                userId: updatedComplaint.userId,
                referenceId: updatedComplaint.referenceId,
                status: normalizedStatus,
                cadreName: updatedComplaint.assignedCadre?.name,
                remarks: data.adminRemarks || data.statusReason || undefined,
            }).catch((err) => {
                console.error('Background automated push notification error:', err);
            });
        }
        return updatedComplaint;
    }
    /**
     * Admin: Delete a complaint
     */
    static async deleteComplaint(id) {
        const complaint = await db_1.default.complaint.findUnique({ where: { id } });
        if (!complaint) {
            throw new error_middleware_1.AppError('Complaint not found', 404);
        }
        return db_1.default.complaint.delete({
            where: { id },
        });
    }
}
exports.ComplaintService = ComplaintService;
