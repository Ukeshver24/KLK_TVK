import dotenv from 'dotenv';
dotenv.config();

import app from './app';
import prisma from './config/db';

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    // Verify Database connection
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL database successfully.');

    app.listen(PORT, () => {
      console.log(`🚀 TVK Backend Server running on http://localhost:${PORT}`);
      console.log(`📡 Health check available at: http://localhost:${PORT}/api/v1/health`);
      console.log(`🔐 Auth API available at: http://localhost:${PORT}/api/v1/auth/register`);
    });
  } catch (error) {
    console.error('❌ Failed to connect to Database:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  console.log('\n🛑 Database disconnected. Server shut down.');
  process.exit(0);
});

startServer();
