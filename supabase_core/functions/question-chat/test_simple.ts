// Simple test for question-chat edge function
// Run with: deno run --allow-net test_simple.ts

const FUNCTION_URL = 'http://127.0.0.1:54321/functions/v1/question-chat'
const ANON_KEY = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'

async function testQuestionChat() {
  console.log('🧪 Testing question-chat edge function\n')

  // Test 1: Initialize conversation (no message)
  console.log('Test 1: Initialize conversation without message')
  try {
    const response1 = await fetch(FUNCTION_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ANON_KEY}`
      },
      body: JSON.stringify({
        question_id: 1,
        include_user_stats: false
      })
    })

    const data1 = await response1.json()
    console.log('Status:', response1.status)
    console.log('Response:', JSON.stringify(data1, null, 2))
    console.log('')
  } catch (error) {
    console.error('Error in test 1:', error)
  }

  // Test 2: Send a message
  console.log('\nTest 2: Send a message to RAG')
  try {
    const response2 = await fetch(FUNCTION_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ANON_KEY}`
      },
      body: JSON.stringify({
        question_id: 1,
        message: '¿Puedes explicarme esta pregunta?',
        include_user_stats: false
      })
    })

    const data2 = await response2.json()
    console.log('Status:', response2.status)
    console.log('Response:', JSON.stringify(data2, null, 2))
  } catch (error) {
    console.error('Error in test 2:', error)
  }
}

// Run tests
testQuestionChat()
