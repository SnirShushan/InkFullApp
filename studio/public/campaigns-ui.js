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

  function render(ctx) {
    const seq = ++requestSeq;
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
    const accounts = (data.accounts || []).map((account) => accountHtml(account, data.currency)).join('');
    const who = data.systemUser?.name ? `<p class="notes">מחובר כ־${esc(data.systemUser.name)}</p>` : '';
    ctx.view.innerHTML = `
      <div class="chip-row" style="margin-bottom:16px">${chips}</div>
      ${who}
      ${blocked}
      ${errors}
      ${setup}
      ${accounts || (data.setup ? '' : '<p class="empty">אין קמפיינים בחשבון.</p>')}
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

  function accountHtml(account) {
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
        ${detailsHtml(campaign, currency)}
      </article>
    `;
  }

  function detailsHtml(campaign, currency) {
    const adsets = campaign.adsets || [];
    const ads = campaign.ads || [];
    if (!adsets.length && !ads.length) return '';
    return `
      <details class="campaign-more">
        <summary>קבוצות מודעות ומודעות (${adsets.length} / ${ads.length})</summary>
        ${adsets.length ? `
          <table class="mix-table campaign-table">
            <thead><tr><th>קבוצה</th><th>מצב</th><th>אופטימיזציה</th><th>תקציב יומי</th><th>הוצאה</th><th>תוצאות</th><th>עלות</th></tr></thead>
            <tbody>
              ${adsets.map((row) => `<tr>
                <td class="name">${esc(row.name)}</td>
                <td>${esc(row.statusLabel)}</td>
                <td>${esc(row.optimization || '—')}</td>
                <td class="num">${row.dailyBudget ? esc(money(row.dailyBudget, currency)) : '—'}</td>
                <td class="num">${esc(money(row.metrics.spend, currency))}</td>
                <td class="num">${esc(fmt(row.metrics.results))}</td>
                <td class="num">${row.metrics.costPerResult ? esc(money(row.metrics.costPerResult, currency)) : '—'}</td>
              </tr>`).join('')}
            </tbody>
          </table>` : ''}
        ${ads.length ? `
          <table class="mix-table campaign-table">
            <thead><tr><th>מודעה</th><th>מצב</th><th>הוצאה</th><th>CTR</th><th>תוצאות</th><th>עלות</th></tr></thead>
            <tbody>
              ${ads.map((row) => `<tr>
                <td class="name"><div class="ad-cell">${row.thumbnail ? `<img class="ad-thumb" src="${escAttr(row.thumbnail)}" alt="" />` : ''}<span>${esc(row.name)}</span></div></td>
                <td>${esc(row.statusLabel)}</td>
                <td class="num">${esc(money(row.metrics.spend, currency))}</td>
                <td class="num">${esc(pct(row.metrics.linkCtr || row.metrics.ctr))}</td>
                <td class="num">${esc(fmt(row.metrics.results))}</td>
                <td class="num">${row.metrics.costPerResult ? esc(money(row.metrics.costPerResult, currency)) : '—'}</td>
              </tr>`).join('')}
            </tbody>
          </table>` : ''}
      </details>
    `;
  }

  function ensureBound(view) {
    if (bound) return;
    bound = true;
    view.addEventListener('click', async (event) => {
      const rangeBtn = event.target.closest('[data-range]');
      if (rangeBtn && view.contains(rangeBtn)) {
        const range = rangeBtn.dataset.range;
        location.hash = range === 'last_30d' ? '#/campaigns' : `#/campaigns?range=${encodeURIComponent(range)}`;
        return;
      }
      const button = event.target.closest('[data-campaign-status]');
      if (!button || !view.contains(button)) return;
      const status = button.dataset.campaignStatus;
      const name = button.dataset.name || 'הקמפיין';
      const question = status === 'PAUSED'
        ? `לעצור את «${name}»? המודעות יפסיקו לרוץ.`
        : `להפעיל את «${name}»?`;
      if (!window.confirm(question)) return;
      button.disabled = true;
      try {
        const res = await fetch(`/api/campaigns/${encodeURIComponent(button.dataset.id)}/status`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ status }),
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.error || 'Meta לא עדכן את הקמפיין');
        const refresh = document.getElementById('campaignRefresh');
        if (refresh) refresh.click();
      } catch (err) {
        button.disabled = false;
        window.alert(err.message || 'לא ניתן לעדכן את הקמפיין');
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
