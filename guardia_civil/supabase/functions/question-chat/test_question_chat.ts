// =====================================================
// TEST FILE: question-chat edge function
// =====================================================
// Para ejecutar: deno run --allow-net --allow-env test_question_chat.ts
// =====================================================

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || 'http://localhost:54321'
const FUNCTION_URL = `${SUPABASE_URL}/functions/v1/question-chat`
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || 'your-anon-key'
const USER_JWT = Deno.env.get('TEST_USER_JWT') || 'your-test-jwt-token'

// =====================================================
// TEST UTILITIES
// =====================================================

interface TestResult {
  name: string
  passed: boolean
  error?: string
  response?: any
}

const results: TestResult[] = []

async function runTest(name: string, testFn: () => Promise<void>) {
  console.log(`\n🧪 Running: ${name}`)
  try {
    await testFn()
    results.push({ name, passed: true })
    console.log(`✅ PASSED: ${name}`)
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error)
    results.push({ name, passed: false, error: errorMsg })
    console.log(`❌ FAILED: ${name}`)
    console.log(`   Error: ${errorMsg}`)
  }
}

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(`Assertion failed: ${message}`)
  }
}

// =====================================================
// HELPER FUNCTIONS
// =====================================================

async function callFunction(method: string, path: string = '', body?: any) {
  const url = `${FUNCTION_URL}${path}`
  const options: RequestInit = {
    method,
    headers: {
      'Authorization': `Bearer ${USER_JWT}`,
      'Content-Type': 'application/json',
    }
  }

  if (body) {
    options.body = JSON.stringify(body)
  }

  const response = await fetch(url, options)
  const data = await response.json()

  return {
    status: response.status,
    data,
    ok: response.ok
  }
}

// =====================================================
// TEST CASES
// =====================================================

await runTest('Test 1: Create conversation without message', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)
  assert(result.data.conversation_id, 'Should return conversation_id')
  assert(result.data.ready === true, 'Should indicate ready state')
  assert(result.data.question_context, 'Should return question context')

  console.log(`   Conversation created: ${result.data.conversation_id}`)
})

await runTest('Test 2: Send message to question chat', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1,
    message: '¿Puedes explicarme esta pregunta?',
    include_user_stats: true
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)
  assert(result.data.conversation_id, 'Should return conversation_id')
  assert(result.data.message_id, 'Should return message_id')
  assert(result.data.response, 'Should return AI response')

  console.log(`   Message ID: ${result.data.message_id}`)
  console.log(`   Response length: ${result.data.response.length} chars`)

  if (result.data.citations && result.data.citations.length > 0) {
    console.log(`   Citations: ${result.data.citations.length}`)
  }
})

await runTest('Test 3: Send message with user answer (incorrect)', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1,
    message: '¿Por qué mi respuesta está mal?',
    user_answer: 0,  // Assuming option 0 is incorrect
    include_user_stats: true
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)
  assert(result.data.response, 'Should return AI response')

  console.log(`   Response includes error analysis`)
  console.log(`   Performance context: ${result.data.performance_context ? 'YES' : 'NO'}`)
})

await runTest('Test 4: Send message with test context', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1,
    message: '¿Qué ley se aplica aquí?',
    user_test_id: 1,  // Assuming test ID 1 exists
    include_user_stats: true
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)
  assert(result.data.response, 'Should return AI response')

  if (result.data.performance_context?.current_test) {
    console.log(`   Test context included`)
    console.log(`   Test score: ${result.data.performance_context.current_test.current_score}`)
  }
})

await runTest('Test 5: Get existing conversation', async () => {
  const result = await callFunction('GET', '/1')  // Question ID 1

  assert(result.ok, `Expected OK status, got ${result.status}`)

  if (result.data.conversation) {
    assert(result.data.messages, 'Should return messages')
    console.log(`   Found conversation: ${result.data.conversation.id}`)
    console.log(`   Message count: ${result.data.messages.length}`)
  } else {
    console.log(`   No conversation found (OK for first run)`)
  }
})

await runTest('Test 6: Send message with extra context', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1,
    message: 'Necesito más ayuda con esto',
    include_user_stats: true,
    extra_context: {
      is_review: true,
      previous_attempts: 3,
      custom_notes: 'Esta pregunta siempre me confunde'
    }
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)
  assert(result.data.response, 'Should return AI response')

  console.log(`   Extra context included`)
})

await runTest('Test 7: Send message without user stats', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1,
    message: '¿Cuál es la respuesta correcta?',
    include_user_stats: false
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)
  assert(result.data.response, 'Should return AI response')
  assert(!result.data.performance_context, 'Should not include performance context')

  console.log(`   Response without performance context`)
})

await runTest('Test 8: Invalid question ID', async () => {
  const result = await callFunction('POST', '', {
    question_id: 99999,
    message: 'Test'
  })

  assert(!result.ok, 'Should fail with invalid question ID')
  assert(result.status === 404, `Expected 404, got ${result.status}`)
})

await runTest('Test 9: Missing question_id', async () => {
  const result = await callFunction('POST', '', {
    message: 'Test without question_id'
  })

  assert(!result.ok, 'Should fail without question_id')
  assert(result.status === 400, `Expected 400, got ${result.status}`)
})

await runTest('Test 10: Check response structure', async () => {
  const result = await callFunction('POST', '', {
    question_id: 1,
    message: 'Test estructura de respuesta',
    include_user_stats: true
  })

  assert(result.ok, `Expected OK status, got ${result.status}`)

  // Check response structure
  assert(typeof result.data.conversation_id === 'number', 'conversation_id should be number')
  assert(typeof result.data.message_id === 'number', 'message_id should be number')
  assert(typeof result.data.response === 'string', 'response should be string')
  assert(Array.isArray(result.data.citations), 'citations should be array')

  if (result.data.performance_context) {
    assert(result.data.performance_context.user_stats, 'Should have user_stats')
    assert(typeof result.data.performance_context.user_stats.accuracy === 'number', 'accuracy should be number')
  }

  console.log(`   Response structure validated`)
})

// =====================================================
// PERFORMANCE TEST
// =====================================================

await runTest('Performance: Multiple sequential messages', async () => {
  const messages = [
    '¿Qué significa esta pregunta?',
    '¿Puedes dar un ejemplo?',
    '¿Hay excepciones?'
  ]

  const startTime = Date.now()

  for (const msg of messages) {
    const result = await callFunction('POST', '', {
      question_id: 1,
      message: msg,
      include_user_stats: false  // Faster
    })

    assert(result.ok, `Message failed: ${msg}`)
  }

  const totalTime = Date.now() - startTime
  console.log(`   Total time for ${messages.length} messages: ${totalTime}ms`)
  console.log(`   Average: ${Math.round(totalTime / messages.length)}ms per message`)
})

// =====================================================
// RESULTS SUMMARY
// =====================================================

console.log('\n' + '='.repeat(60))
console.log('TEST RESULTS SUMMARY')
console.log('='.repeat(60))

const passed = results.filter(r => r.passed).length
const failed = results.filter(r => !r.passed).length
const total = results.length

console.log(`\nTotal Tests: ${total}`)
console.log(`✅ Passed: ${passed}`)
console.log(`❌ Failed: ${failed}`)
console.log(`Success Rate: ${Math.round((passed / total) * 100)}%`)

if (failed > 0) {
  console.log('\n❌ Failed Tests:')
  results.filter(r => !r.passed).forEach(r => {
    console.log(`   - ${r.name}`)
    console.log(`     Error: ${r.error}`)
  })
}

console.log('\n' + '='.repeat(60))

// Exit with error code if tests failed
if (failed > 0) {
  Deno.exit(1)
}
