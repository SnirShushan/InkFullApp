import crypto from 'crypto';

let cachedToken = { value: '', exp: 0 };

function loadServiceAccount() {
  const raw = process.env.FCM_SERVICE_ACCOUNT_JSON || '';
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function b64urlJson(obj) {
  return Buffer.from(JSON.stringify(obj)).toString('base64url');
}

async function getAccessToken(sa) {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken.value && cachedToken.exp - 60 > now) return cachedToken.value;

  const header = { alg: 'RS256', typ: 'JWT' };
  const claim = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: sa.token_uri || 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${b64urlJson(header)}.${b64urlJson(claim)}`;
  const signer = crypto.createSign('RSA-SHA256');
  signer.update(unsigned);
  const jwt = `${unsigned}.${signer.sign(sa.private_key, 'base64url')}`;

  const res = await fetch(claim.aud, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!data.access_token) {
    throw new Error(data.error_description || data.error || 'FCM auth failed');
  }
  cachedToken = { value: data.access_token, exp: now + 3500 };
  return data.access_token;
}

export async function sendPush({
  token,
  title,
  body = '',
  data = {},
  deviceType = 'a',
} = {}) {
  const sa = loadServiceAccount();
  if (!sa || !token || token === 'dev' || token === 'dev-mode-udid') return false;

  const access = await getAccessToken(sa);
  const projectId = sa.project_id || process.env.FCM_PROJECT_ID || 'ink-flutter-app';
  const payloadData = {};
  for (const [k, v] of Object.entries(data)) {
    payloadData[k] = String(v ?? '');
  }

  const message = {
    token,
    notification: { title, body },
    data: payloadData,
  };
  if (String(deviceType).toLowerCase().startsWith('i')) {
    message.apns = { payload: { aps: { sound: 'default', 'content-available': 1 } } };
  } else {
    message.android = { priority: 'high' };
  }

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${access}`,
      },
      body: JSON.stringify({ message }),
    }
  );
  if (!res.ok) {
    const err = await res.text();
    console.error('FCM send failed', res.status, err.slice(0, 300));
    return false;
  }
  return true;
}
