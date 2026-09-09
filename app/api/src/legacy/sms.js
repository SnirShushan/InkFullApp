import { ok, fail } from './helpers.js';

const UPSEND_URL =
  process.env.UPSEND_URL || 'https://capi.upsend.co.il/api/v2/SMS/SendSms';
const UPSEND_USER = process.env.UPSEND_USER || 'UPSEND110108';
const UPSEND_PASSWORD =
  process.env.UPSEND_PASSWORD || '1cb88b77-06db-40dd-bea0-98dfe4aeac10';
const UPSEND_SENDER = process.env.UPSEND_SENDER || 'Ink App';

/** Israeli mobile → 9725XXXXXXXX for Upsend. */
export function toUpsendPhone(raw) {
  let digits = String(raw || '').replace(/\D/g, '');
  if (!digits) return '';
  if (digits.startsWith('9720')) digits = `972${digits.slice(4)}`;
  else if (digits.startsWith('0')) digits = `972${digits.slice(1)}`;
  else if (digits.startsWith('5') && digits.length === 9) digits = `972${digits}`;
  else if (!digits.startsWith('972') && digits.length === 10 && digits.startsWith('05')) {
    digits = `972${digits.slice(1)}`;
  }
  return digits;
}

export async function handleSendSms(p) {
  const otp = String(p.otp || '').trim();
  const phone = toUpsendPhone(p.phone);
  if (!phone || !otp) {
    return fail('Missing phone or otp');
  }

  const message = `קוד האימות שלך הוא ${otp}, הקוד תקף ל-10 דקות`;
  const auth = Buffer.from(`${UPSEND_USER}:${UPSEND_PASSWORD}`).toString('base64');
  const body = {
    Data: {
      Message: message,
      Recipients: [{ Phone: phone }],
      Settings: { Sender: UPSEND_SENDER },
    },
  };

  try {
    const res = await fetch(UPSEND_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${auth}`,
      },
      body: JSON.stringify(body),
    });
    const text = await res.text();
    let parsed = null;
    try {
      parsed = text ? JSON.parse(text) : null;
    } catch (_) {
      parsed = { raw: text };
    }

    const statusId = Number(parsed?.StatusId);
    const sent = res.ok && statusId === 1;
    console.log(
      `SendSms phone=...${phone.slice(-4)} http=${res.status} statusId=${statusId}`
    );

    if (sent) {
      return ok(
        {
          sent: 1,
          res: {
            status: true,
            http_status: res.status,
            message: 'msg sent successfully',
            data: parsed,
          },
        },
        'Success'
      );
    }

    const desc = parsed?.StatusDescription || text || 'sms could not be sent';
    return fail(
      'אירעה שגיאה, יש לבדוק שמספר הטלפון נכון או לנסות שליחת קוד מחדש',
      0,
      {
        res: {
          status: false,
          http_status: res.status,
          message: desc === 'No valid recipients' ? 'Invalid phone number' : 'sms could not be sent',
          error: desc,
          data: parsed,
        },
        err_res: desc,
      }
    );
  } catch (e) {
    console.error('SendSms error', e?.message || e);
    return fail(
      'אירעה שגיאה, יש לבדוק שמספר הטלפון נכון או לנסות שליחת קוד מחדש'
    );
  }
}
