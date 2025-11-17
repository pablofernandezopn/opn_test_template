#!/bin/bash

TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL29wb3NpY2lvbmVzZ3VhcmRpYWNpdmlsLm9ubGluZSIsImlhdCI6MTc2MjU0NTAyMywibmJmIjoxNzYyNTQ1MDIzLCJleHAiOjE3NjMxNDk4MjMsImRhdGEiOnsidXNlciI6eyJpZCI6IjI4In19fQ.BAi4JbxCdF-q2--iMitE_C8RiPz84LNxTadmuBf2bzM"

echo "=== TEST: Respuesta incorrecta - Diferenciación clara ==="
echo ""
echo "Usuario 28, Question 72, respuesta incorrecta (opción 1)"
echo "Esperado: El AI debe distinguir claramente entre la opción elegida (1) y la correcta (2)"
echo ""

curl -s -X POST 'http://localhost:54321/functions/v1/question-chat' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "question_id": 72,
    "user_answer": 1,
    "message": "¿Por qué fallé?"
  }' | python3 -m json.tool 2>&1 | grep -A 10 '"response"'
