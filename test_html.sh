#!/bin/bash
# Test script to fetch and examine the HTML

echo "Fetching HTML from http://localhost:4000/"
curl -s http://localhost:4000/ > /tmp/rumbl_page.html

echo ""
echo "=== HEAD section ==="
grep -A 20 "<head>" /tmp/rumbl_page.html | head -25

echo ""
echo "=== Looking for CSS link ==="
grep -i "stylesheet\|app.css" /tmp/rumbl_page.html

echo ""
echo "=== Looking for JS script ==="
grep -i "app.js" /tmp/rumbl_page.html
