"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ComplaintController = void 0;
const complaint_service_1 = require("../services/complaint.service");
const image_processor_1 = require("../utils/image-processor");
class ComplaintController {
    /**
     * POST /api/v1/complaints/upload (Upload single proof image with WebP optimization)
     */
    static async uploadAttachment(req, res, next) {
        try {
            const files = [];
            if (req.file) {
                files.push(req.file);
            }
            else if (req.files) {
                if (Array.isArray(req.files)) {
                    files.push(...req.files);
                }
                else {
                    for (const key of Object.keys(req.files)) {
                        const val = req.files[key];
                        if (Array.isArray(val)) {
                            files.push(...val);
                        }
                        else if (val) {
                            files.push(val);
                        }
                    }
                }
            }
            if (files.length === 0) {
                res.status(400).json({ success: false, message: 'No image file uploaded' });
                return;
            }
            const host = req.get('host') || 'localhost:4000';
            const protocol = req.protocol || 'http';
            // Process all uploaded files with WebP optimization in parallel
            const processedList = await Promise.all(files.map(async (file) => {
                const { filename, size } = await (0, image_processor_1.convertToWebP)(file.path, {
                    maxWidth: 1280,
                    maxHeight: 1280,
                    quality: 80,
                });
                const fileUrl = `${protocol}://${host}/uploads/complaints/${filename}`;
                return {
                    filename,
                    originalName: file.originalname,
                    size,
                    url: fileUrl,
                };
            }));
            if (processedList.length === 1) {
                res.status(200).json({
                    success: true,
                    message: 'Image uploaded and optimized to WebP successfully',
                    data: {
                        filename: processedList[0].filename,
                        originalName: processedList[0].originalName,
                        size: processedList[0].size,
                        url: processedList[0].url,
                        filenames: processedList[0].filename,
                        urls: processedList[0].url,
                    },
                });
            }
            else {
                const filenamesStr = processedList.map((p) => p.filename).join(',');
                const urlsStr = processedList.map((p) => p.url).join(',');
                res.status(200).json({
                    success: true,
                    message: `${processedList.length} images uploaded and optimized to WebP successfully`,
                    data: {
                        filename: filenamesStr,
                        url: urlsStr,
                        filenames: filenamesStr,
                        urls: urlsStr,
                        files: processedList,
                    },
                });
            }
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/complaints/register
     */
    static async register(req, res, next) {
        try {
            // If citizen is authenticated, ensure complaint is bound to their authenticated userId
            const payload = { ...req.body };
            if (req.user?.userId && req.user.role === 'CITIZEN') {
                payload.userId = req.user.userId;
            }
            const complaint = await complaint_service_1.ComplaintService.registerComplaint(payload);
            res.status(201).json({
                success: true,
                message: 'Complaint registered successfully',
                data: complaint,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/complaints/my-complaints?userId=xxx (IDOR protected)
     */
    static async getMyComplaints(req, res, next) {
        try {
            // If authenticated as citizen, strictly use authenticated userId
            let userId;
            if (req.user?.role === 'CITIZEN') {
                userId = req.user.userId;
            }
            else {
                userId = req.query.userId || req.headers['x-user-id'] || req.user?.userId;
            }
            if (!userId) {
                res.status(400).json({ success: false, message: 'User ID is required' });
                return;
            }
            const complaints = await complaint_service_1.ComplaintService.getCitizenComplaints(userId);
            res.status(200).json({
                success: true,
                count: complaints.length,
                data: complaints,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/complaints/track/:referenceId (Supports Reference ID & Mobile Number)
     */
    static async track(req, res, next) {
        try {
            const query = String(req.params.referenceId);
            const complaints = await complaint_service_1.ComplaintService.trackComplaints(query);
            if (!complaints || complaints.length === 0) {
                res.status(404).json({
                    success: false,
                    message: 'No complaints found for this Reference ID or Mobile Number',
                    data: [],
                });
                return;
            }
            res.status(200).json({
                success: true,
                count: complaints.length,
                data: complaints,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/complaints/all (Admin / MLA Office only)
     */
    static async getAll(req, res, next) {
        try {
            const { status, category, village } = req.query;
            const complaints = await complaint_service_1.ComplaintService.getAllComplaints({
                status: status,
                category: category,
                village: village,
            });
            res.status(200).json({
                success: true,
                count: complaints.length,
                data: complaints,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * PATCH /api/v1/complaints/:id/status (Admin / MLA Office only)
     */
    static async updateStatus(req, res, next) {
        try {
            const id = String(req.params.id);
            const { status, assignedCadreId, adminRemarks, statusReason } = req.body;
            if (!status) {
                res.status(400).json({ success: false, message: 'Status is required' });
                return;
            }
            const updated = await complaint_service_1.ComplaintService.updateComplaintStatus(id, {
                status,
                assignedCadreId,
                adminRemarks,
                statusReason,
            });
            res.status(200).json({
                success: true,
                message: 'Complaint status updated successfully',
                data: updated,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * DELETE /api/v1/complaints/:id (Admin / MLA Office only)
     */
    static async delete(req, res, next) {
        try {
            const id = String(req.params.id);
            await complaint_service_1.ComplaintService.deleteComplaint(id);
            res.status(200).json({
                success: true,
                message: 'Complaint deleted successfully',
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.ComplaintController = ComplaintController;
