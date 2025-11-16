#!/bin/bash

TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL29wb3NpY2lvbmVzZ3VhcmRpYWNpdmlsLm9ubGluZSIsImlhdCI6MTc2MjU0NTAyMywibmJmIjoxNzYyNTQ1MDIzLCJleHAiOjE3NjMxNDk4MjMsImRhdGEiOnsidXNlciI6eyJpZCI6IjI4In19fQ.BAi4JbxCdF-q2--iMitE_C8RiPz84LNxTadmuBf2bzM"

echo "=== TEST: Verificando búsqueda de respuesta en base de datos ==="
echo ""
echo "Usuario 28, Test ID 111, Question 72"
echo "Respuesta esperada: Opción 2 (correcta)"
echo ""

curl -s -X POST 'http://localhost:54321/functions/v1/question-chat' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "question_id": 72,
    "user_test_id": 111,
    "message": "Hola, ¿por qué es correcta esta opción?"
  }'
