/**
 * Resolve media URLs for the new architecture.
 * Priority: absolute URL (Firebase/R2) -> R2 public base + key -> passthrough.
 */
export function publicBases() {
  const base = (process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');
  if (base) {
    return {
      style_img_url: `${base}/assets/images/styles/`,
      profile_img_url: `${base}/assets/uploads/profile_images/`,
      body_img_url: `${base}/assets/uploads/body_images/`,
      startup_img_url: `${base}/assets/uploads/`,
      default_img_url: `${base}/assets/img/defult.png`,
    };
  }
  // Until R2 is configured, keep Firebase URLs as stored in DB and use local/smartweb for styles
  return {
    style_img_url: 'https://smartweb-tech.com/apps/ink/assets/images/styles/',
    profile_img_url: '',
    body_img_url: '',
    startup_img_url: '',
    default_img_url: 'https://smartweb-tech.com/apps/ink/assets/img/defult.png',
  };
}

export function assetUrl(value, kind = '') {
  const raw = String(value || '').trim();
  if (!raw) {
    return publicBases().default_img_url;
  }
  if (/^https?:\/\//i.test(raw)) {
    // Rewrite dead domain if it ever appears
    if (raw.includes('inkisrael.co.il')) {
      const base = (process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');
      if (base) {
        return raw.replace(/https?:\/\/inkisrael\.co\.il/i, base);
      }
    }
    return raw;
  }
  const base = (process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');
  if (base) {
    if (kind === 'styles') return `${base}/assets/images/styles/${raw}`;
    if (kind === 'profile') return `${base}/assets/uploads/profile_images/${raw}`;
    if (kind === 'body') return `${base}/assets/uploads/body_images/${raw}`;
    if (kind === 'signature') return `${base}/assets/uploads/signature_images/${raw}`;
    if (kind === 'firebase') return `${base}/firebase/${raw}`;
    return `${base}/${raw.replace(/^\//, '')}`;
  }
  if (kind === 'styles') {
    return `https://smartweb-tech.com/apps/ink/assets/images/styles/${raw}`;
  }
  return raw;
}
