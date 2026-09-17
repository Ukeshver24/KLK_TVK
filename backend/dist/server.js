"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app_1 = __importDefault(require("./app"));
const db_1 = __importDefault(require("./config/db"));
const PORT = process.env.PORT || 5000;
async function startServer() {
    try {
        // Verify Database connection
        await db_1.default.$connect();
        console.log('✅ Connected to PostgreSQL database successfully.');
        app_1.default.listen(PORT, () => {
            console.log(`🚀 TVK Backend Server running on http://localhost:${PORT}`);
            console.log(`📡 Health check available at: http://localhost:${PORT}/api/v1/health`);
            console.log(`🔐 Auth API available at: http://localhost:${PORT}/api/v1/auth/register`);
        });
    }
    catch (error) {
        console.error('❌ Failed to connect to Database:', error);
        process.exit(1);
    }
}
// Graceful shutdown
process.on('SIGINT', async () => {
    await db_1.default.$disconnect();
    console.log('\n🛑 Database disconnected. Server shut down.');
    process.exit(0);
});
startServer();
