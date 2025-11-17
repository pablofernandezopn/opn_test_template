// Test JWT generation with WordPress secret
const jwt = require('jsonwebtoken');

const secret = '{syqtT}C|,ENojj&BDXZE}Q+zCNd)Y,$8f!3o8zj8>PkTSl^<F_(wU^sb}FnQ[Cy';

const payload = {
  iss: 'https://oposicionesguardiacivil.online',
  iat: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + (365 * 24 * 60 * 60), // 1 year
  sub: '28',
  email: 'pablofernandezl@opn.es.off'
};

const token = jwt.sign(payload, secret, { algorithm: 'HS256' });

console.log('Generated Token:');
console.log(token);
console.log('\nPayload:', payload);

// Verify the token
try {
  const decoded = jwt.verify(token, secret, { algorithms: ['HS256'] });
  console.log('\n✅ Token verified successfully');
  console.log('Decoded:', decoded);
} catch (error) {
  console.log('\n❌ Token verification failed:', error.message);
}

// Test with the existing token
const existingToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL29wb3NpY2lvbmVzZ3VhcmRpYWNpdmlsLm9ubGluZSIsImlhdCI6MTczMTA3NzgyMywiZXhwIjoxNzYzMTQ5ODIzLCJzdWIiOiIyOCIsImVtYWlsIjoicGFibG9mZXJuYW5kZXpsQG9wbi5lcy5vZmYifQ.dWLhVk-qk1G23dNsgSGqbWEOkq5xBqJEcaJnN8cKnFU';

console.log('\n\nTesting existing token:');
try {
  const decoded = jwt.verify(existingToken, secret, { algorithms: ['HS256'] });
  console.log('✅ Existing token verified successfully');
  console.log('Decoded:', decoded);
} catch (error) {
  console.log('❌ Existing token verification failed:', error.message);
}
