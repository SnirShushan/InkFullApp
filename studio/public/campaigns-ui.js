const InkCampaigns = (() => {
  const RANGES = [
    ['last_7d', '7 ימים'],
    ['last_30d', '30 יום'],
    ['last_90d', '90 יום'],
    ['maximum', 'כל הזמן'],
  ];
  const VERDICT = {
    good: ['עובד', 'good'],
    warn: ['לשיפור', 'warn'],
    bad: ['לא עובד', 'bad'],
    idle: ['לא רץ', ''],
  };

  let requestSeq = 0;
  let bound = false;
  let notice = '';

  function render(ctx) {
    const seq = ++requestSeq;
    ctx.section = ctx.section === 'videos' ? 'videos' : 'campaigns';
    ctx.eyebrow.textContent = 'Meta Ads';
    ctx.title.textContent = 'ניהול קמפיינים';
    ctx.topActions.innerHTML = `<button type="button" class="btn ghost" id="campaignRefresh">רענון</button>`;
    ctx.view.innerHTML = `<p class="empty">טוען קמפיינים מ-Meta…</p>`;
    ensureBound(ctx.view);
    ctx.topActions.querySelector('#campaignRefresh').onclick = () => load(ctx, seq);
    return load(ctx, seq);
  }

  async function load(ctx, seq = ++requestSeq) {
    ctx.view.innerHTML = `<p class="empty">טוען קמפיינים מ-Meta…</p>`;
    try {
      const res = await fetch(`/api/campaigns?range=${encodeURIComponent(ctx.range || 'last_30d')}`);
      const data = await res.json().catch(() => ({}));
      if (seq !== requestSeq) return;
      if (!res.ok) throw new Error(data.error || 'לא ניתן לטעון קמפיינים');
      paint(ctx, data);
    } catch (err) {
      if (seq !== requestSeq) return;
      ctx.view.innerHTML = `<p class="empty">${esc(err.message || 'לא ניתן לטעון קמפיינים')}</p>`;
    }
  }

  function paint(ctx, data) {
    const range = data.range || ctx.range || 'last_30d';
    const chips = RANGES.map(([id, label]) => `<button type="button" class="filter-chip${id === range ? ' active' : ''}" data-range="${id}">${label}</button>`).join('');
    const blocked = (data.blocked || []).map((row) => `<p class="banner-error">${esc(row.id)}: ${esc(row.error)}</p>`).join('');
    const errors = (data.errors || []).map((row) => `<p class="banner-error">${esc(row.name || row.id)}: ${esc(row.error)}</p>`).join('');
    const setup = data.setup ? setupHtml(data.setup) : '';
    const accounts = (data.accounts || []).map((account) => accountHtml(account, ctx.section)).join('');
    const who = data.systemUser?.name ? `<p class="notes">מחובר כ־${esc(data.systemUser.name)}</p>` : '';
    const flash = notice ? `<p class="banner-ok">${esc(notice)}</p>` : '';
    notice = '';
    ctx.view.innerHTML = `
      ${sectionTabs(ctx.section, range)}
      <div class="chip-row" style="margin-bottom:16px">${chips}</div>
      ${flash}
      ${who}
      ${blocked}
      ${errors}
      ${setup}
      ${accounts || (data.setup ? '' : '<p class="empty">אין קמפיינים בחשבון.</p>')}
    `;
  }

  function sectionTabs(section, range) {
    const query = range && range !== 'last_30d' ? `?range=${encodeURIComponent(range)}` : '';
    const run = `#/campaigns${query}`;
    const videos = `#/campaigns/videos${query}`;
    return `
      <div class="chip-row campaign-sections">
        <a class="filter-chip${section === 'videos' ? '' : ' active'}" href="${run}">קמפיינים</a>
        <a class="filter-chip${section === 'videos' ? ' active' : ''}" href="${videos}">ניהול סרטוני קמפיין</a>
      </div>
    `;
  }

  function setupHtml(setup) {
    return `
      <section class="section-card">
        <h2>${esc(setup.title || 'חיבור ל-Meta')}</h2>
        <p class="notes">${esc(setup.message || '')}</p>
        <ol class="setup-steps">
          ${(setup.steps || []).map((step) => `<li>${esc(step)}</li>`).join('')}
        </ol>
      </section>
    `;
  }

  function accountHtml(account, section) {
    if (section === 'videos') return videosAccountHtml(account);
    const currency = account.currency || 'ILS';
    const t = account.totals || {};
    const maxSpend = Math.max(...(account.trend || []).map((d) => d.spend), 0);
    const trend = (account.trend || []).map((day) => {
      const h = maxSpend ? Math.max(4, Math.round((day.spend / maxSpend) * 72)) : 4;
      return `<i style="height:${h}px" title="${esc(day.date)} · ${esc(money(day.spend, currency))}"></i>`;
    }).join('');
    const recs = (account.recommendations || []).map((rec) => `
      <article class="rec ${esc(rec.tone || '')}">
        <h3>${esc(rec.title)}</h3>
        <p>${esc(rec.body)}</p>
      </article>
    `).join('');
    return `
      <section class="section-card">
        <div class="account-head">
          <div>
            <h2>${esc(account.name)}</h2>
            <div class="campaign-meta">
              <span class="badge">${esc(account.status || 'חשבון')}</span>
              <span class="pill">${esc(currency)}</span>
              ${account.timezone ? `<span class="pill">${esc(account.timezone)}</span>` : ''}
            </div>
          </div>
          <p class="notes">הוצאה מצטברת ${esc(money(account.amountSpent, currency))}</p>
        </div>
        <div class="finance-grid">
          ${kpi('הוצאה', money(t.spend, currency))}
          ${kpi('חשיפות', fmt(t.impressions))}
          ${kpi('אנשים', fmt(t.reach))}
          ${kpi('תדירות', num(t.frequency, 2))}
          ${kpi('CTR', pct(t.linkCtr || t.ctr))}
          ${kpi('CPC', money(t.cpc, currency))}
          ${kpi(t.resultLabel || 'תוצאות', fmt(t.results), t.results > 0 ? 'good' : '')}
          ${kpi('עלות לתוצאה', t.costPerResult ? money(t.costPerResult, currency) : '—')}
        </div>
        ${trend ? `<div class="trend" aria-label="הוצאה יומית">${trend}</div>` : ''}
      </section>
      ${recs ? `<section class="section-card"><h2>מה לשפר</h2>${recs}</section>` : ''}
      ${comparisonTable(account)}
      <div class="campaign-list">
        ${(account.campaigns || []).map((campaign) => campaignHtml(campaign, currency)).join('') || '<p class="empty">אין קמפיינים בחשבון הזה.</p>'}
      </div>
    `;
  }

  function comparisonTable(account) {
    const currency = account.currency || 'ILS';
    const rows = account.campaigns || [];
    if (!rows.length) return '';
    return `
      <section class="section-card">
        <h2>השוואת קמפיינים</h2>
        <div class="table-wrap" style="max-height:none">
          <table class="mix-table campaign-table">
            <thead>
              <tr>
                <th>קמפיין</th><th>מצב</th><th>יעד</th><th>הוצאה</th><th>חשיפות</th><th>תדירות</th><th>CTR</th><th>תוצאות</th><th>עלות</th><th>הערכה</th>
              </tr>
            </thead>
            <tbody>
              ${rows.map((c) => {
                const [label, tone] = VERDICT[c.verdict] || VERDICT.idle;
                const m = c.metrics || {};
                return `<tr>
                  <td class="name">${esc(c.name)}</td>
                  <td>${esc(c.statusLabel)}</td>
                  <td>${esc(c.objectiveLabel)}</td>
                  <td class="num">${esc(money(m.spend, currency))}</td>
                  <td class="num">${esc(fmt(m.impressions))}</td>
                  <td class="num">${esc(num(m.frequency, 2))}</td>
                  <td class="num">${esc(pct(m.linkCtr || m.ctr))}</td>
                  <td class="num">${esc(fmt(m.results))} ${esc(m.resultLabel || '')}</td>
                  <td class="num">${m.costPerResult ? esc(money(m.costPerResult, currency)) : '—'}</td>
                  <td><span class="badge ${tone}">${label}</span></td>
                </tr>`;
              }).join('')}
            </tbody>
          </table>
        </div>
      </section>
    `;
  }

  function campaignHtml(campaign, currency) {
    const m = campaign.metrics || {};
    const [label, tone] = VERDICT[campaign.verdict] || VERDICT.idle;
    const canRun = campaign.configuredStatus === 'ACTIVE' || campaign.configuredStatus === 'PAUSED';
    const buttons = !canRun ? '' : campaign.configuredStatus === 'ACTIVE'
      ? `<button type="button" class="btn danger" data-campaign-status="PAUSED" data-id="${escAttr(campaign.id)}" data-name="${escAttr(campaign.name)}">עצור</button>`
      : `<button type="button" class="btn" data-campaign-status="ACTIVE" data-id="${escAttr(campaign.id)}" data-name="${escAttr(campaign.name)}">הפעל</button>`;
    const budget = campaign.lifetimeBudget
      ? `תקציב כולל ${money(campaign.lifetimeBudget, currency)}`
      : campaign.dailyBudget
        ? `תקציב יומי ${money(campaign.dailyBudget, currency)}`
        : 'תקציב ברמת קבוצות המודעות';
    return `
      <article class="section-card campaign-card">
        <div class="campaign-head">
          <div>
            <h2>${esc(campaign.name)}</h2>
            <div class="campaign-meta">
              <span class="badge ${tone}">${label}</span>
              <span class="badge">${esc(campaign.statusLabel)}</span>
              <span class="pill">${esc(campaign.objectiveLabel)}</span>
              ${campaign.bidStrategy ? `<span class="pill">${esc(campaign.bidStrategy)}</span>` : ''}
              <span class="pill">${esc(budget)}</span>
            </div>
          </div>
          <div class="campaign-actions">${buttons}</div>
        </div>
        <div class="finance-grid">
          ${kpi('הוצאה', money(m.spend, currency))}
          ${kpi('חשיפות', fmt(m.impressions))}
          ${kpi('אנשים', fmt(m.reach))}
          ${kpi('תדירות', num(m.frequency, 2), m.frequency >= 3.5 ? 'bad' : m.frequency >= 2.6 ? 'warn' : '')}
          ${kpi('CTR', pct(m.linkCtr || m.ctr))}
          ${kpi('CPC', money(m.cpc, currency))}
          ${kpi('CPM', money(m.cpm, currency))}
          ${kpi(m.resultLabel || 'תוצאות', fmt(m.results), m.results > 0 ? 'good' : '')}
          ${kpi('עלות לתוצאה', m.costPerResult ? money(m.costPerResult, currency) : '—', campaign.verdict === 'good' ? 'good' : campaign.verdict === 'bad' ? 'bad' : '')}
          ${m.roas ? kpi('ROAS', num(m.roas, 2), m.roas >= 2 ? 'good' : 'bad') : ''}
        </div>
        <ul class="advice-list">
          ${(campaign.notes || []).map((note) => `<li>${esc(note)}</li>`).join('')}
        </ul>
      </article>
    `;
  }

  function videosAccountHtml(account) {
    const currency = account.currency || 'ILS';
    const campaigns = account.campaigns || [];
    return `
      <section class="section-card">
        <h2>${esc(account.name)}</h2>
        <p class="notes">לכל קמפיין: הסטים, התקציב היומי, והסרטונים שאפשר להדליק או לכבות.</p>
      </section>
      <div class="campaign-list">
        ${campaigns.map((campaign) => videoCampaignHtml(campaign, currency)).join('') || '<p class="empty">אין קמפיינים בחשבון הזה.</p>'}
      </div>
    `;
  }

  function videoCampaignHtml(campaign, currency) {
    const budgetEditor = !campaign.budgetOnAdsets && !campaign.lifetimeBudget
      ? budgetForm('campaign', campaign.id, campaign.dailyBudget, currency)
      : '';
    const budget = campaign.lifetimeBudget
      ? `תקציב כולל ${money(campaign.lifetimeBudget, currency)}`
      : campaign.dailyBudget
        ? `תקציב יומי ${money(campaign.dailyBudget, currency)}`
        : 'תקציב על הסטים';
    return `
      <article class="section-card campaign-card">
        <div class="campaign-head">
          <div>
            <h2>${esc(campaign.name)}</h2>
            <div class="campaign-meta">
              <span class="badge">${esc(campaign.statusLabel)}</span>
              <span class="pill">${esc(campaign.objectiveLabel)}</span>
              <span class="pill">${esc(budget)}</span>
            </div>
          </div>
        </div>
        ${budgetEditor}
        ${videoSetsHtml(campaign, currency)}
      </article>
    `;
  }

  function budgetForm(level, id, amount, currency) {
    const value = amount ? String(Math.round(Number(amount) * 100) / 100) : '';
    return `
      <form class="budget-form" data-budget-level="${escAttr(level)}" data-id="${escAttr(id)}" data-currency="${escAttr(currency)}">
        <label>תקציב יומי (${esc(currency)})
          <input name="dailyBudget" type="number" min="1" max="100000" step="0.01" value="${escAttr(value)}" required />
        </label>
        <button class="btn" type="submit">שמור תקציב</button>
      </form>`;
  }

  function adButtons(row) {
    const canRun = row.configuredStatus === 'ACTIVE' || row.configuredStatus === 'PAUSED';
    if (!canRun) return '';
    const turnOff = row.configuredStatus === 'ACTIVE';
    const status = turnOff ? 'PAUSED' : 'ACTIVE';
    const label = turnOff ? 'כבה' : 'הפעל';
    const cls = turnOff ? 'btn danger small' : 'btn small';
    return `<button type="button" class="${cls}" data-ad-status="${status}" data-id="${escAttr(row.id)}" data-name="${escAttr(row.name)}">${label}</button>`;
  }

  function adsTable(ads, currency) {
    if (!ads.length) return '<p class="notes">אין עדיין מודעות בסט הזה.</p>';
    return `
      <table class="mix-table campaign-table">
        <thead><tr><th>מודעה</th><th>מצב</th><th>הוצאה</th><th>CTR</th><th>תוצאות</th><th>עלות</th><th></th></tr></thead>
        <tbody>
          ${ads.map((row) => `<tr>
            <td class="name"><div class="ad-cell">${row.thumbnail ? `<img class="ad-thumb" src="${escAttr(row.thumbnail)}" alt="" />` : ''}<span>${esc(row.name)}${row.videoCount > 1 ? `<small class="notes">כוללת ${esc(String(row.videoCount))} סרטונים, וכיבוי שלה עוצר את כולם</small>` : ''}</span></div></td>
            <td>${esc(row.statusLabel)}</td>
            <td class="num">${esc(money(row.metrics.spend, currency))}</td>
            <td class="num">${esc(pct(row.metrics.linkCtr || row.metrics.ctr))}</td>
            <td class="num">${esc(fmt(row.metrics.results))}</td>
            <td class="num">${row.metrics.costPerResult ? esc(money(row.metrics.costPerResult, currency)) : '—'}</td>
            <td>${adButtons(row)}</td>
          </tr>`).join('')}
        </tbody>
      </table>`;
  }

  function videoForm(adset) {
    return `
      <form class="video-form" data-video-adset="${escAttr(adset.id)}" data-name="${escAttr(adset.name)}">
        <p class="notes">הסרטון עולה כמודעה נפרדת בתוך הסט, עם אותו יעד של המודעות שכבר שם. בלי «הפעל מיד» הוא נשאר כבוי, ואפשר להדליק רק אותו.</p>
        <label>סרטון
          <input name="video" type="file" accept="video/mp4,video/quicktime,video/webm,.mp4,.mov,.m4v,.webm" required />
        </label>
        <label>שם המודעה
          <input name="name" type="text" maxlength="200" />
        </label>
        <label>כותרת
          <input name="title" type="text" maxlength="255" />
        </label>
        <label>טקסט
          <textarea name="message" maxlength="2000"></textarea>
        </label>
        <label>קישור
          <input name="link" type="url" inputmode="url" placeholder="ריק = הקישור שכבר בסט, למשל חנות האפליקציה" value="${escAttr(adset.defaultLink || '')}" />
        </label>
        <label class="check-line">
          <input name="activate" type="checkbox" value="1" />
          הפעל מיד
        </label>
        <button class="btn" type="submit">הוסף סרטון</button>
      </form>`;
  }

  function adsetManageHtml(adset, ads, campaign, currency) {
    let budget = '';
    if (campaign.budgetOnAdsets && !adset.lifetimeBudget) {
      budget = budgetForm('adset', adset.id, adset.dailyBudget, currency);
    } else if (adset.lifetimeBudget) {
      budget = `<p class="notes">תקציב כולל ${esc(money(adset.lifetimeBudget, currency))}</p>`;
    } else if (campaign.dailyBudget) {
      budget = '<p class="notes">התקציב היומי נקבע על הקמפיין.</p>';
    }
    return `
      <section class="adset-block">
        <h3>${esc(adset.name)}</h3>
        <div class="campaign-meta">
          <span class="badge">${esc(adset.statusLabel)}</span>
          ${adset.optimization ? `<span class="pill">${esc(adset.optimization)}</span>` : ''}
          <span class="pill">הוצאה ${esc(money(adset.metrics?.spend, currency))}</span>
          <span class="pill">${esc(fmt(adset.metrics?.results))} תוצאות</span>
        </div>
        ${budget}
        ${adsTable(ads, currency)}
        ${videoForm(adset)}
      </section>`;
  }

  function videoSetsHtml(campaign, currency) {
    const adsets = campaign.adsets || [];
    const ads = campaign.ads || [];
    if (!adsets.length && !ads.length) return '<p class="notes">אין סטים או מודעות בקמפיין הזה.</p>';
    const grouped = adsets.map((adset) => ({
      adset,
      ads: ads.filter((ad) => String(ad.adsetId) === String(adset.id)),
    }));
    const known = new Set(adsets.map((adset) => String(adset.id)));
    const orphans = ads.filter((ad) => !known.has(String(ad.adsetId)));
    return `
      ${grouped.map((group) => adsetManageHtml(group.adset, group.ads, campaign, currency)).join('')}
      ${orphans.length ? `<section class="adset-block"><h3>מודעות נוספות</h3>${adsTable(orphans, currency)}</section>` : ''}
    `;
  }

  function refreshCampaigns() {
    const refresh = document.getElementById('campaignRefresh');
    if (refresh) refresh.click();
  }

  async function postJson(url, body) {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || 'Meta לא עדכן');
    return data;
  }

  function ensureBound(view) {
    if (bound) return;
    bound = true;
    view.addEventListener('click', async (event) => {
      const rangeBtn = event.target.closest('[data-range]');
      if (rangeBtn && view.contains(rangeBtn)) {
        const range = rangeBtn.dataset.range;
        const path = location.hash.includes('/campaigns/videos') ? '/campaigns/videos' : '/campaigns';
        location.hash = range === 'last_30d' ? `#${path}` : `#${path}?range=${encodeURIComponent(range)}`;
        return;
      }
      const campaignButton = event.target.closest('[data-campaign-status]');
      const adButton = event.target.closest('[data-ad-status]');
      const button = campaignButton || adButton;
      if (!button || !view.contains(button)) return;
      const status = button.dataset.campaignStatus || button.dataset.adStatus;
      const name = button.dataset.name || (adButton ? 'המודעה' : 'הקמפיין');
      const question = adButton
        ? (status === 'PAUSED' ? `לכבות את «${name}»? שאר המודעות בסט ימשיכו לרוץ.` : `להפעיל את «${name}»?`)
        : (status === 'PAUSED' ? `לעצור את «${name}»? המודעות יפסיקו לרוץ.` : `להפעיל את «${name}»?`);
      if (!window.confirm(question)) return;
      button.disabled = true;
      try {
        const path = adButton ? 'ads' : 'campaigns';
        await postJson(`/api/${path}/${encodeURIComponent(button.dataset.id)}/status`, { status });
        if (adButton) notice = status === 'PAUSED' ? `«${name}» כבויה.` : `«${name}» פעילה.`;
        refreshCampaigns();
      } catch (err) {
        button.disabled = false;
        window.alert(err.message || 'לא ניתן לעדכן');
      }
    });
    view.addEventListener('submit', async (event) => {
      const budget = event.target.closest('[data-budget-level]');
      const video = event.target.closest('[data-video-adset]');
      if ((!budget && !video) || !view.contains(event.target)) return;
      event.preventDefault();
      if (budget) {
        const amount = budget.elements.dailyBudget.value;
        const currency = budget.dataset.currency || '';
        if (!window.confirm(`לעדכן את התקציב היומי ל־${amount} ${currency}?`)) return;
        const button = budget.querySelector('button');
        button.disabled = true;
        try {
          const level = budget.dataset.budgetLevel === 'adset' ? 'adsets' : 'campaigns';
          await postJson(`/api/${level}/${encodeURIComponent(budget.dataset.id)}/budget`, { dailyBudget: Number(amount) });
          notice = `התקציב היומי עודכן ל־${amount} ${currency}.`;
          refreshCampaigns();
        } catch (err) {
          button.disabled = false;
          window.alert(err.message || 'לא ניתן לעדכן את התקציב');
        }
        return;
      }
      const file = video.elements.video.files?.[0];
      if (!file) return;
      if (file.size > 200 * 1024 * 1024) {
        window.alert('הסרטון גדול מ-200MB');
        return;
      }
      const setName = video.dataset.name || 'הסט';
      const activate = video.elements.activate.checked;
      const question = activate
        ? `להעלות את הסרטון ל«${setName}» ולהפעיל אותו? Meta עדיין צריך לאשר את המודעה.`
        : `להעלות את הסרטון ל«${setName}» כמושהה? אפשר להפעיל אותו אחר כך.`;
      if (!window.confirm(question)) return;
      const button = video.querySelector('button[type="submit"]');
      button.disabled = true;
      button.textContent = 'מעלה ל-Meta…';
      try {
        const body = new FormData(video);
        if (!String(body.get('name') || '').trim()) body.set('name', file.name.replace(/\.[^.]+$/, ''));
        const res = await fetch(`/api/adsets/${encodeURIComponent(video.dataset.videoAdset)}/video`, {
          method: 'POST',
          body,
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.error || 'לא ניתן להוסיף את הסרטון');
        notice = activate
          ? `«${data.name || file.name}» נוסף לסט ומסומן כפעיל. Meta צריך לאשר אותו לפני שיופיע.`
          : `«${data.name || file.name}» נוסף לסט כמושהה. אפשר להפעיל אותו מהרשימה.`;
        refreshCampaigns();
      } catch (err) {
        button.disabled = false;
        button.textContent = 'הוסף סרטון';
        window.alert(err.message || 'לא ניתן להוסיף את הסרטון');
      }
    });
  }

  function kpi(label, value, tone = '') {
    return `<div class="kpi ${tone}"><b>${esc(value)}</b><span>${esc(label)}</span></div>`;
  }

  function money(amount, currency) {
    const value = Number(amount) || 0;
    try {
      return new Intl.NumberFormat('he-IL', { style: 'currency', currency: currency || 'ILS', maximumFractionDigits: 2 }).format(value);
    } catch {
      return `${value.toFixed(2)} ${currency || ''}`.trim();
    }
  }

  function pct(value) {
    return `${(Number(value) || 0).toLocaleString('he-IL', { maximumFractionDigits: 2 })}%`;
  }

  function num(value, digits) {
    return (Number(value) || 0).toLocaleString('he-IL', { maximumFractionDigits: digits, minimumFractionDigits: digits ? 0 : 0 });
  }

  function fmt(value) {
    return Math.round(Number(value) || 0).toLocaleString('he-IL');
  }

  function esc(s) {
    return String(s ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  }

  function escAttr(s) {
    return esc(s).replaceAll('"', '&quot;');
  }

  return { render };
})();
