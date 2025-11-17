#!/bin/bash

TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL29wb3NpY2lvbmVzZ3VhcmRpYWNpdmlsLm9ubGluZSIsImlhdCI6MTc2MjU0NTAyMywibmJmIjoxNzYyNTQ1MDIzLCJleHAiOjE3NjMxNDk4MjMsImRhdGEiOnsidXNlciI6eyJpZCI6IjI4In19fQ.BAi4JbxCdF-q2--iMitE_C8RiPz84LNxTadmuBf2bzM"

curl -X POST 'http://localhost:54321/functions/v1/question-chat' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"question_id": 1, "message": "Hola"}'
