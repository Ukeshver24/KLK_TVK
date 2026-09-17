"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const db_1 = __importDefault(require("../config/db"));
async function seed() {
    console.log('🌱 Seeding production database defaults...');
    // 1. Admin User (Password: Admin@123)
    const passwordHash = '$2b$10$tV8Kf3E3UMBMl71Cym8j9emI/bIyD1wD6Cnm4MErG1bJMEpJ41EjG';
    await db_1.default.adminUser.upsert({
        where: { username: 'admin' },
        update: {
            passwordHash,
            role: 'ADMIN',
            status: 'ACTIVE',
        },
        create: {
            username: 'admin',
            email: 'admin@tvk.in',
            passwordHash,
            fullName: 'Kallakurichi MLA Office Admin',
            role: 'ADMIN',
            status: 'ACTIVE',
        },
    });
    console.log('✅ Admin user created/updated (Username: admin, Password: Admin@123)');
    // 2. MLA Contact Profile
    await db_1.default.mlaContact.upsert({
        where: { id: 'singleton-mla' },
        update: {},
        create: {
            id: 'singleton-mla',
            name: 'C. Arul Vignesh',
            degree: 'M.Sc.,',
            designationEn: 'MLA, KALLAKURICHI',
            designationTa: 'சட்டப்பேரவை உறுப்பினர், கள்ளக்குறிச்சி',
            addressEn: 'No 42, Main Road, Near Bus Stand, Kallakurichi, Tamil Nadu – 606202',
            addressTa: 'எண் 42, பிரதான சாலை, பேருந்து நிலையம் அருகில், கள்ளக்குறிச்சி, தமிழ்நாடு – 606202',
            phone: '+91 98765 43210',
            email: 'mla.kallakurichi@tvk.in',
            visitingHoursEn: 'Monday - Saturday: 09:00 AM - 06:00 PM',
            visitingHoursTa: 'திங்கள் - சனி: காலை 09:00 - மாலை 06:00',
            photoUrl: 'assets/images/mla_photo.jpg',
        },
    });
    console.log('✅ MLA Contact Profile verified.');
    // 3. 3 Default Banner Slots
    for (let slot = 1; slot <= 3; slot++) {
        await db_1.default.banner.upsert({
            where: { slot },
            update: {},
            create: {
                slot,
                imageUrl: `assets/images/tvk_banner${slot}.jpg`,
                title: `TVK Banner ${slot}`,
                isActive: true,
            },
        });
    }
    console.log('✅ 3 Banner slots initialized.');
    // 4. System Settings (Maintenance & App Versioning)
    await db_1.default.systemSetting.upsert({
        where: { id: 'singleton' },
        update: {},
        create: {
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
        },
    });
    console.log('✅ System Settings initialized.');
    console.log('🎉 Production database ready!');
}
seed()
    .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
})
    .finally(async () => {
    await db_1.default.$disconnect();
});
