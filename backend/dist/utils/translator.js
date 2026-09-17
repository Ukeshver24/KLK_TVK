"use strict";
/**
 * Location Helpers & Known Taluks Mapping
 * Preserves EXACT Admin inputs for both English (nameEn) and Tamil (nameTa) fields
 * without any automated transliteration altering the names.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.KNOWN_TALUKS = void 0;
exports.normalizeTaluk = normalizeTaluk;
exports.resolveVillageNames = resolveVillageNames;
exports.KNOWN_TALUKS = [
    { nameEn: 'Kallakurichi', nameTa: 'கள்ளக்குறிச்சி' },
    { nameEn: 'Chinnasalem', nameTa: 'சின்னசேலம்' },
    { nameEn: 'Sankarapuram', nameTa: 'சங்கராபுரம்' },
    { nameEn: 'Tirukkoyilur', nameTa: 'திருக்கோவிலூர்' },
    { nameEn: 'Ulundurpet', nameTa: 'உளுந்தூர்பேட்டை' },
    { nameEn: 'Kalvarayan Hills', nameTa: 'கல்வராயன் மலை' },
    { nameEn: 'Rishivandiyam', nameTa: 'ரிஷிவந்தியம்' },
    { nameEn: 'Thiyagadurgam', nameTa: 'தியாகதுருகம்' },
];
/**
 * Normalizes Taluk input into English & Tamil pair
 */
function normalizeTaluk(talukInput, talukTaInput) {
    const clean = (talukInput || '').trim();
    const cleanTa = (talukTaInput || '').trim();
    if (!clean && !cleanTa) {
        return { talukEn: 'Kallakurichi', talukTa: 'கள்ளக்குறிச்சி' };
    }
    // Check known taluks
    const lower = (clean || cleanTa).toLowerCase();
    for (const t of exports.KNOWN_TALUKS) {
        if (t.nameEn.toLowerCase() === lower ||
            t.nameTa.toLowerCase() === lower ||
            clean === t.nameTa ||
            clean === t.nameEn ||
            cleanTa === t.nameTa) {
            return {
                talukEn: t.nameEn,
                talukTa: cleanTa.isNotEmpty() ? cleanTa : t.nameTa,
            };
        }
    }
    // Custom taluk - preserve exact inputs
    const talukEn = clean.isNotEmpty() ? clean : cleanTa;
    const talukTa = cleanTa.isNotEmpty() ? cleanTa : clean;
    return { talukEn, talukTa };
}
String.prototype.isNotEmpty = function () {
    return this.trim().length > 0;
};
/**
 * Preserves exact Admin dual-language input (nameEn & nameTa)
 */
function resolveVillageNames(input) {
    const nameEn = (input.nameEn || '').trim();
    const nameTa = (input.nameTa || '').trim();
    const fallback = (input.name || '').trim();
    if (nameEn && nameTa) {
        return { nameEn, nameTa };
    }
    if (nameEn && !nameTa) {
        return { nameEn, nameTa: nameEn };
    }
    if (!nameEn && nameTa) {
        return { nameEn: nameTa, nameTa };
    }
    if (fallback) {
        return { nameEn: fallback, nameTa: fallback };
    }
    return { nameEn: 'Unknown', nameTa: 'Unknown' };
}
