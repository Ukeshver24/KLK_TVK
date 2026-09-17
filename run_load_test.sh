#!/bin/bash
# ========================================================
# 🚀 TVK Application — K6 Speed & Load Test One-Click Runner
# ========================================================

echo "========================================================"
echo "⚡ TVK Backend API — 500 VUs Concurrency & Speed Test"
echo "========================================================"

# Check if k6 is installed
if ! command -v k6 &> /dev/null; then
    echo "❌ Error: k6 is not installed. Install it using: brew install k6"
    exit 1
fi

# Check if backend is running on port 4000
if ! lsof -i :4000 > /dev/null 2>&1; then
    echo "⚠️ Backend is not detected on port 4000!"
    echo "👉 Starting backend in another terminal: cd backend && npm run dev"
    echo "Please ensure the backend is running and re-run this script."
    exit 1
fi

echo "🟢 Backend is online on port 4000."
echo "🚀 Launching 500 Concurrent Users test (2,000 Total Transactions)..."
echo ""

k6 run local_load_test.js

echo ""
echo "========================================================"
echo "✅ Load Test Finished Successfully!"
echo "📈 Visual Graph Report: report.html"
echo "📑 Raw Tables Report:   k6_raw_report.html"
echo "📊 JSON Metrics:        summary.json"
echo "========================================================"
echo "🌐 Opening visual dashboard in your browser..."
open report.html
