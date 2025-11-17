#!/bin/bash

TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL29wb3NpY2lvbmVzZ3VhcmRpYWNpdmlsLm9ubGluZSIsImlhdCI6MTc2MjU0NTAyMywibmJmIjoxNzYyNTQ1MDIzLCJleHAiOjE3NjMxNDk4MjMsImRhdGEiOnsidXNlciI6eyJpZCI6IjI4In19fQ.BAi4JbxCdF-q2--iMitE_C8RiPz84LNxTadmuBf2bzM"

echo "=== TEST: ¿El AI conoce mi perfil? ==="
echo ""
echo "Usuario 28 (Pablo Fernandez - mathwithstylus@gmail.com)"
echo "Pregunta: ¿Sabes cómo me llamo?"
echo ""

curl -s -X POST 'http://localhost:54321/functions/v1/question-chat' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"question_id":72,"user_test_id":111,"message":"¿Sabes cómo me llamo?"}' | \
  python3 -m json.tool | grep -A 5 '"response"'
