import prisma from '../config/db';
import fs from 'fs';
import path from 'path';

async function run() {
  console.log('Generating tvk_production_clean_seed.sql...');
  const adminUsers = await prisma.adminUser.findMany();
  const mlaContacts = await prisma.mlaContact.findMany();
  const banners = await prisma.banner.findMany();
  const systemSettings = await prisma.systemSetting.findMany();
  const cadres = await prisma.cadre.findMany();
  const broadcasts = await prisma.broadcastAlert.findMany();

  let sql = `-- ==========================================================
-- TVK GRIEVANCE PORTAL DATABASE DUMP
-- Target: PostgreSQL Database (tvk_db)
-- Generated for aaPanel Production Deployment
-- ==========================================================

-- 1. Create Enums if not exist
DO $$ BEGIN
    CREATE TYPE "Role" AS ENUM ('SUPER_ADMIN', 'ADMIN', 'OPERATOR');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "ComplaintStatus" AS ENUM ('SUBMITTED', 'IN_REVIEW', 'OFFICER_ASSIGNED', 'ACTION_IN_PROGRESS', 'RESOLVED', 'REJECTED', 'OTHERS');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "AlertSeverity" AS ENUM ('EMERGENCY', 'ANNOUNCEMENT', 'WEATHER', 'EVENT');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "AlertFrequency" AS ENUM ('EVERY_OPEN', 'ONCE_PER_DAY');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Create Tables
CREATE TABLE IF NOT EXISTS "admin_users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "username" TEXT NOT NULL UNIQUE,
    "email" TEXT NOT NULL UNIQUE,
    "passwordHash" TEXT NOT NULL,
    "fullName" TEXT NOT NULL DEFAULT 'Kallakurichi MLA Office Admin',
    "role" "Role" NOT NULL DEFAULT 'ADMIN',
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "resetToken" TEXT UNIQUE,
    "resetTokenExpires" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "phone" TEXT NOT NULL UNIQUE,
    "fullName" TEXT NOT NULL,
    "voterId" TEXT,
    "taluk" TEXT NOT NULL DEFAULT 'Kallakurichi',
    "village" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "pincode" TEXT NOT NULL DEFAULT '606202',
    "dob" TEXT,
    "isVerified" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "otp_verifications" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "phone" TEXT NOT NULL,
    "otp" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "cadres" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "cadreCode" TEXT UNIQUE,
    "name" TEXT NOT NULL,
    "nameTa" TEXT,
    "phone" TEXT NOT NULL UNIQUE,
    "role" TEXT NOT NULL,
    "roleTa" TEXT,
    "taluk" TEXT NOT NULL DEFAULT 'Kallakurichi',
    "talukTa" TEXT,
    "village" TEXT NOT NULL,
    "villageTa" TEXT,
    "boothNumber" TEXT NOT NULL,
    "voterId" TEXT,
    "photoUrl" TEXT,
    "isVerified" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "banners" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "slot" INTEGER NOT NULL UNIQUE,
    "imageUrl" TEXT NOT NULL,
    "title" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "mla_contacts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL DEFAULT 'C. Arul Vignesh',
    "degree" TEXT NOT NULL DEFAULT 'M.Sc.,',
    "designationEn" TEXT NOT NULL DEFAULT 'MLA, KALLAKURICHI',
    "designationTa" TEXT NOT NULL DEFAULT 'சட்டப்பேரவை உறுப்பினர், கள்ளக்குறிச்சி',
    "addressEn" TEXT NOT NULL DEFAULT 'No 42, Main Road, Near Bus Stand, Kallakurichi, Tamil Nadu – 606202',
    "addressTa" TEXT NOT NULL DEFAULT 'எண் 42, பிரதான சாலை, பேருந்து நிலையம் அருகில், கள்ளக்குறிச்சி, தமிழ்நாடு – 606202',
    "phone" TEXT NOT NULL DEFAULT '+91 98765 43210',
    "email" TEXT NOT NULL DEFAULT 'mla.kallakurichi@tvk.in',
    "visitingHoursEn" TEXT NOT NULL DEFAULT 'Monday - Saturday: 09:00 AM - 06:00 PM',
    "visitingHoursTa" TEXT NOT NULL DEFAULT 'திங்கள் - சனி: காலை 09:00 - மாலை 06:00',
    "photoUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "system_settings" (
    "id" TEXT NOT NULL PRIMARY KEY DEFAULT 'singleton',
    "maintenanceMode" BOOLEAN NOT NULL DEFAULT false,
    "maintenanceTitleEn" TEXT NOT NULL DEFAULT 'Under Scheduled Maintenance',
    "maintenanceTitleTa" TEXT NOT NULL DEFAULT 'பராமரிப்பு பணியில் உள்ளது',
    "maintenanceMsgEn" TEXT NOT NULL DEFAULT 'We are currently upgrading our systems to serve you better. The app will be back online shortly.',
    "maintenanceMsgTa" TEXT NOT NULL DEFAULT 'சேவையக மேம்பாட்டு பணிகள் நடைபெற்று வருகின்றன. செயலி விரைவில் மீண்டும் பயன்பாட்டுக்கு வரும்.',
    "minAppVersion" TEXT NOT NULL DEFAULT '1.0.0',
    "latestAppVersion" TEXT NOT NULL DEFAULT '1.0.0',
    "forceUpdate" BOOLEAN NOT NULL DEFAULT false,
    "playStoreUrl" TEXT NOT NULL DEFAULT 'https://play.google.com/store/apps/details?id=com.example.tvk_application',
    "appStoreUrl" TEXT NOT NULL DEFAULT 'https://apps.apple.com/app/id6400000000',
    "updateTitleEn" TEXT NOT NULL DEFAULT 'Update Required',
    "updateTitleTa" TEXT NOT NULL DEFAULT 'புதிய பதிப்பு கிடைக்கிறது',
    "updateMsgEn" TEXT NOT NULL DEFAULT 'A new version of the app is available. Please update to continue using the app with the latest features and improvements.',
    "updateMsgTa" TEXT NOT NULL DEFAULT 'செயலியின் புதிய பதிப்பு கிடைக்கிறது. புதிய அம்சங்களுடன் தொடர்ந்து பயன்பாட்டிற்கு செயலியைப் புதுப்பிக்கவும்.',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "broadcast_alerts" (
    "id" TEXT NOT NULL PRIMARY KEY DEFAULT 'singleton',
    "title" TEXT NOT NULL DEFAULT 'கள்ளக்குறிச்சி பொதுமக்களுக்கு முக்கிய அவசர அறிவிப்பு!',
    "message" TEXT NOT NULL DEFAULT 'கள்ளக்குறிச்சி மற்றும் சின்னசேலம் பகுதிகளில் பெய்து வரும் கனமழை காரணமாக தாழ்வான பகுதிகளில் உள்ள பொதுமக்கள் பாதுகாப்பாக இருக்குமாறு கேட்டுக்கொள்ளப்படுகிறார்கள். ஏதேனும் அவசர உதவி தேவைப்பட்டால் உடனே நமது TVK 24x7 கட்டுப்பாட்டு அறையை தொடர்பு கொள்ளவும்.',
    "severity" "AlertSeverity" NOT NULL DEFAULT 'EMERGENCY',
    "imageUrl" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "targetScope" TEXT NOT NULL DEFAULT 'Entire Kallakurichi Constituency (79)',
    "showFrequency" "AlertFrequency" NOT NULL DEFAULT 'EVERY_OPEN',
    "authorTag" TEXT NOT NULL DEFAULT 'From the Desk of MLA',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "complaints" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "cadreId" TEXT REFERENCES "cadres"("id") ON DELETE SET NULL,
    "category" TEXT NOT NULL,
    "categoryTa" TEXT,
    "description" TEXT NOT NULL,
    "village" TEXT NOT NULL,
    "taluk" TEXT NOT NULL DEFAULT 'Kallakurichi',
    "pincode" TEXT NOT NULL DEFAULT '606202',
    "attachmentUrl" TEXT,
    "status" "ComplaintStatus" NOT NULL DEFAULT 'SUBMITTED',
    "assignedOfficer" TEXT,
    "adminRemarks" TEXT,
    "statusReason" TEXT,
    "timelineEvents" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- 3. INSERT CLEAN SEED DATA (Admin, MLA, Banners, Cadres, Settings)
-- ==========================================================
`;

  for (const u of adminUsers) {
    sql += `\nINSERT INTO "admin_users" ("id", "username", "email", "passwordHash", "fullName", "role", "status", "createdAt", "updatedAt") VALUES ('${u.id}', '${u.username}', '${u.email}', '${u.passwordHash}', '${u.fullName}', '${u.role}', '${u.status}', NOW(), NOW()) ON CONFLICT ("id") DO NOTHING;`;
  }
  for (const m of mlaContacts) {
    sql += `\nINSERT INTO "mla_contacts" ("id", "name", "degree", "designationEn", "designationTa", "addressEn", "addressTa", "phone", "email", "visitingHoursEn", "visitingHoursTa", "photoUrl", "createdAt", "updatedAt") VALUES ('${m.id}', '${m.name.replace(/'/g, "''")}', '${m.degree}', '${m.designationEn.replace(/'/g, "''")}', '${m.designationTa.replace(/'/g, "''")}', '${m.addressEn.replace(/'/g, "''")}', '${m.addressTa.replace(/'/g, "''")}', '${m.phone}', '${m.email}', '${m.visitingHoursEn.replace(/'/g, "''")}', '${m.visitingHoursTa.replace(/'/g, "''")}', ${m.photoUrl ? `'${m.photoUrl}'` : 'NULL'}, NOW(), NOW()) ON CONFLICT ("id") DO NOTHING;`;
  }
  for (const b of banners) {
    sql += `\nINSERT INTO "banners" ("id", "slot", "imageUrl", "title", "isActive", "createdAt", "updatedAt") VALUES ('${b.id}', ${b.slot}, '${b.imageUrl}', ${b.title ? `'${b.title.replace(/'/g, "''")}'` : 'NULL'}, ${b.isActive}, NOW(), NOW()) ON CONFLICT ("slot") DO NOTHING;`;
  }
  for (const s of systemSettings) {
    sql += `\nINSERT INTO "system_settings" ("id", "maintenanceMode", "maintenanceTitleEn", "maintenanceTitleTa", "maintenanceMsgEn", "maintenanceMsgTa", "minAppVersion", "latestAppVersion", "forceUpdate", "playStoreUrl", "appStoreUrl", "updateTitleEn", "updateTitleTa", "updateMsgEn", "updateMsgTa", "createdAt", "updatedAt") VALUES ('${s.id}', ${s.maintenanceMode}, '${s.maintenanceTitleEn.replace(/'/g, "''")}', '${s.maintenanceTitleTa.replace(/'/g, "''")}', '${s.maintenanceMsgEn.replace(/'/g, "''")}', '${s.maintenanceMsgTa.replace(/'/g, "''")}', '${s.minAppVersion}', '${s.latestAppVersion}', ${s.forceUpdate}, '${s.playStoreUrl}', '${s.appStoreUrl}', '${s.updateTitleEn.replace(/'/g, "''")}', '${s.updateTitleTa.replace(/'/g, "''")}', '${s.updateMsgEn.replace(/'/g, "''")}', '${s.updateMsgTa.replace(/'/g, "''")}', NOW(), NOW()) ON CONFLICT ("id") DO NOTHING;`;
  }
  for (const c of cadres) {
    sql += `\nINSERT INTO "cadres" ("id", "cadreCode", "name", "nameTa", "phone", "role", "roleTa", "taluk", "talukTa", "village", "villageTa", "boothNumber", "voterId", "photoUrl", "isVerified", "createdAt", "updatedAt") VALUES ('${c.id}', ${c.cadreCode ? `'${c.cadreCode}'` : 'NULL'}, '${c.name.replace(/'/g, "''")}', ${c.nameTa ? `'${c.nameTa.replace(/'/g, "''")}'` : 'NULL'}, '${c.phone}', '${c.role.replace(/'/g, "''")}', ${c.roleTa ? `'${c.roleTa.replace(/'/g, "''")}'` : 'NULL'}, '${c.taluk}', ${c.talukTa ? `'${c.talukTa.replace(/'/g, "''")}'` : 'NULL'}, '${c.village.replace(/'/g, "''")}', ${c.villageTa ? `'${c.villageTa.replace(/'/g, "''")}'` : 'NULL'}, '${c.boothNumber}', ${c.voterId ? `'${c.voterId}'` : 'NULL'}, ${c.photoUrl ? `'${c.photoUrl}'` : 'NULL'}, ${c.isVerified}, NOW(), NOW()) ON CONFLICT ("id") DO NOTHING;`;
  }
  for (const ba of broadcasts) {
    sql += `\nINSERT INTO "broadcast_alerts" ("id", "title", "message", "severity", "imageUrl", "isActive", "targetScope", "showFrequency", "authorTag", "createdAt", "updatedAt") VALUES ('${ba.id}', '${ba.title.replace(/'/g, "''")}', '${ba.message.replace(/'/g, "''")}', '${ba.severity}', ${ba.imageUrl ? `'${ba.imageUrl}'` : 'NULL'}, ${ba.isActive}, '${ba.targetScope.replace(/'/g, "''")}', '${ba.showFrequency}', '${ba.authorTag.replace(/'/g, "''")}', NOW(), NOW()) ON CONFLICT ("id") DO NOTHING;`;
  }

  const outPath = path.resolve(__dirname, '../../../tvk_production_clean_dump.sql');
  fs.writeFileSync(outPath, sql, 'utf8');
  console.log(`SUCCESS! Exported complete SQL dump to: ${outPath}`);
}

run()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
