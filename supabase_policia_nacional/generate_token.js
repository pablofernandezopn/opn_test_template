// Generate JWT with correct secret
const jwt = require('jsonwebtoken');

const secret = '5pV0uKhiWoMClkrfAZiBc2bPWAPT05trPCB7uYohxW+im7kT9mpZEzQGK/ee5fY/Pg1wfQr/H6MvLWWY6VT6zw==';

const payload = {
  iss: 'https://oposicionesguardiacivil.online',
  iat: Math.floor(Date.now() / 1000),
  nbf: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + (365 * 24 * 60 * 60), // 1 year
  data: {
    user: {
      id: '28'
    }
  }
};

const token = jwt.sign(payload, secret, { algorithm: 'HS256', header: { typ: 'JWT', alg: 'HS256' } });

console.log('\n✅ Token generado con el secret correcto:');
console.log(token);
console.log('\nPayload:', JSON.stringify(payload, null, 2));

// Verify
try {
  const decoded = jwt.verify(token, secret, { algorithms: ['HS256'] });
  console.log('\n✅ Token verificado correctamente');
} catch (error) {
  console.log('\n❌ Error verificando token:', error.message);
}
