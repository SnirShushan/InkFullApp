const view = document.getElementById('view');
const nav = document.getElementById('nav');
const title = document.getElementById('title');
const eyebrow = document.getElementById('eyebrow');
const topActions = document.getElementById('topActions');
const drawer = document.getElementById('drawer');
const drawerBody = document.getElementById('drawerBody');
const navSearch = document.getElementById('navSearch');
const sourceNote = document.getElementById('sourceNote');

let overview = null;
let compare = null;
let studio = null;
let state = { mode: 'tables', source: 'live', table: null, page: 1, q: '', sort: '', dir: 'desc', limit: 50, adminSection: 'home' };

document.getElementById('drawerClose').onclick = closeDrawer;
drawer.addEventListener('click', (e) => {
  if (e.target === drawer) closeDrawer();
});
navSearch.addEventListener('input', () => renderNav());
document.getElementById('srcMuseum').onclick = () => setSource('museum');
document.getElementById('srcLive').onclick = () => setSource('live');
document.querySelector('.brand').addEventListener('click', (e) => {
  e.preventDefault();
  location.hash = '#/tables';
});

window.addEventListener('hashchange', onRoute);
init();

async function init() {
  parseHash();
  studio = await fetch('/api/studio').then((r) => r.json()).catch(() => ({ adminUrl: 'http://127.0.0.1:8080/admin/', adminUp: false }));
  if (state.mode === 'tables') await loadSources();
  onRoute();
}

async function loadSources() {
  const qs = `source=${encodeURIComponent(state.source)}`;
  const [ov, cmp] = await Promise.all([
    fetch(`/api/overview?${qs}`).then((r) => r.json()),
    fetch('/api/compare').then((r) => r.json()),
  ]);
  overview = ov;
  compare = cmp;
  renderSourceChrome();
  renderNav();
}

function setWorkspaceChrome() {
  document.body.classList.remove('mode-admin', 'mode-tables', 'mode-finance', 'mode-spec', 'mode-legacy');
  document.body.classList.add(`mode-${state.mode}`);
  if (state.mode === 'admin' && state.adminSection === 'legacy') {
    document.body.classList.add('mode-legacy');
  }
  document.getElementById('tabAdmin').classList.toggle('active', state.mode === 'admin');
  document.getElementById('tabTables').classList.toggle('active', state.mode === 'tables');
  document.getElementById('tabFinance').classList.toggle('active', state.mode === 'finance');
  document.getElementById('tabSpec').classList.toggle('active', state.mode === 'spec');
}

function renderSourceChrome() {
  document.getElementById('srcMuseum').classList.toggle('active', state.source === 'museum');
  document.getElementById('srcLive').classList.toggle('active', state.source === 'live');
  const liveOk = compare?.liveAvailable ?? overview?.liveAvailable;
  if (state.source === 'live') {
    sourceNote.textContent = liveOk ? 'Railway MySQL · נתונים חיים' : 'המקור החי לא זמין';
  } else {
    sourceNote.textContent = 'קובץ SQL · ארכיון ינואר 2026';
  }
}

function deltaOf(name) {
  return compare?.tables?.find((t) => t.name === name)?.delta ?? null;
}

function renderNav() {
  if (!overview) return;
  const filter = navSearch.value.trim().toLowerCase();
  const groups = overview.groups
    .map((g) => ({
      ...g,
      tables: g.tables.filter(
        (t) =>
          t.name.toLowerCase().includes(filter) ||
          t.label.toLowerCase().includes(filter)
      ),
    }))
    .filter((g) => g.tables.length);

  nav.innerHTML = groups
    .map(
      (g) => `
      <h3>${esc(g.label)}</h3>
      ${g.tables
        .map((t) => {
          const delta = deltaOf(t.name);
          const mark = delta ? `<span class="diff">${delta > 0 ? '+' : ''}${delta}</span>` : '';
          return `
        <a href="${hashFor({ mode: 'tables', table: t.name })}" data-table="${esc(t.name)}">
          <span>${esc(t.label)}${mark}</span>
          <span class="count">${fmt(t.rows)}</span>
        </a>`;
        })
        .join('')}
    `
    )
    .join('');
  highlightNav();
}

function highlightNav() {
  nav.querySelectorAll('a').forEach((a) => {
    a.classList.toggle('active', a.dataset.table === state.table);
  });
}

function parseHash() {
  const raw = location.hash.replace(/^#/, '') || '/tables';
  const [path, query] = raw.split('?');
  const params = new URLSearchParams(query || '');
  const tableMatch = path.match(/^\/tables?\/table\/([^/]+)/) || path.match(/^\/table\/([^/]+)/);
  if (path.startsWith('/admin')) {
    state.mode = 'admin';
    if (path.startsWith('/admin/users/business')) state.adminSection = 'business';
    else if (path.startsWith('/admin/users')) state.adminSection = 'users';
    else if (path.startsWith('/admin/reports/users')) state.adminSection = 'report-users';
    else if (path.startsWith('/admin/reports/posts')) state.adminSection = 'report-posts';
    else if (path.startsWith('/admin/requests')) state.adminSection = 'requests';
    else if (path.startsWith('/admin/settings')) state.adminSection = 'settings';
    else if (path.startsWith('/admin/legacy')) state.adminSection = 'legacy';
    else state.adminSection = 'home';
  }
  else if (path.startsWith('/finance')) state.mode = 'finance';
  else if (path.startsWith('/spec')) state.mode = 'spec';
  else state.mode = 'tables';
  state.source = params.get('source') === 'museum' ? 'museum' : (state.mode === 'finance' || state.mode === 'spec') ? (params.get('source') || 'live') : (params.get('source') === 'live' ? 'live' : params.get('source') === 'museum' ? 'museum' : state.source || 'live');
  if (state.mode === 'tables' && !params.get('source') && !tableMatch) {
    state.source = state.source || 'live';
  }
  state.table = tableMatch ? decodeURIComponent(tableMatch[1]) : null;
  state.page = Number(params.get('page')) || 1;
  state.q = params.get('q') || '';
  state.sort = params.get('sort') || '';
  state.dir = params.get('dir') || 'desc';
  state.limit = Number(params.get('limit')) || 50;
}

function hashFor(patch = {}) {
  const next = { ...state, ...patch };
  const qs = new URLSearchParams({ source: next.source });
  if (next.mode === 'admin') {
    const section = next.adminSection || 'home';
    const adminPath = {
      home: '#/admin',
      users: '#/admin/users',
      business: '#/admin/users/business',
      'report-users': '#/admin/reports/users',
      'report-posts': '#/admin/reports/posts',
      requests: '#/admin/requests',
      settings: '#/admin/settings',
      legacy: '#/admin/legacy',
    }[section] || '#/admin';
    const adminQs = new URLSearchParams();
    if (next.q) adminQs.set('q', next.q);
    if (next.page && next.page > 1) adminQs.set('page', String(next.page));
    const suffix = adminQs.toString();
    return suffix ? `${adminPath}?${suffix}` : adminPath;
  }
  if (next.mode === 'finance') return `#/finance?${qs}`;
  if (next.mode === 'spec') return `#/spec?${qs}`;
  if (next.table) {
    if (next.page) qs.set('page', String(next.page));
    if (next.limit) qs.set('limit', String(next.limit));
    if (next.q) qs.set('q', next.q);
    if (next.sort) qs.set('sort', next.sort);
    if (next.dir) qs.set('dir', next.dir);
    return `#/tables/table/${encodeURIComponent(next.table)}?${qs}`;
  }
  return `#/tables?${qs}`;
}

function setSource(source) {
  if (state.source === source) return;
  location.hash = hashFor({ source, page: 1 });
}

async function onRoute() {
  const prevSource = state.source;
  const prevMode = state.mode;
  parseHash();
  setWorkspaceChrome();
  if (state.mode === 'admin') {
    await renderAdmin();
    return;
  }
  if (state.mode === 'finance') {
    await renderFinance();
    return;
  }
  if (state.mode === 'spec') {
    await renderSpec();
    return;
  }
  if (!overview || overview.source !== state.source || prevMode !== 'tables') {
    await loadSources();
  } else {
    renderSourceChrome();
    renderNav();
  }
  if (state.table) loadTable();
  else renderOverview();
  highlightNav();
  if (prevSource !== state.source) closeDrawer();
}

function renderAdmin() {
  return InkAdmin.render({
    view,
    title,
    eyebrow,
    topActions,
    studio,
    section: state.adminSection,
    page: state.page,
    q: state.q,
  });
}

async function renderFinance() {
  eyebrow.textContent = 'מעקב פיננסי';
  title.textContent = 'הכנסות והוצאות';
  topActions.innerHTML = '';
  view.innerHTML = `<p class="empty">טוען נתונים חיים…</p>`;
  const res = await fetch(`/api/finance?source=${encodeURIComponent(state.source || 'live')}`);
  const data = await res.json();
  if (!res.ok) {
    view.innerHTML = `<p class="empty">${esc(data.error || 'לא ניתן לטעון כספים')}</p>`;
    return;
  }
  const m = data.money;
  const s = data.subscriptions;
  const u = data.users;
  const netClass = m.netAfterCosts >= 0 ? 'good' : 'bad';
  topActions.innerHTML = `<span class="mono">${data.source === 'live' ? 'נתונים חיים מ-Railway' : 'ארכיון SQL'}${
    data.fallbackReason ? ` · נפל לחי: ${esc(data.fallbackReason)}` : ''
  }</span>`;

  view.innerHTML = `
    <div class="section-card growth-card">
      <h2>משתמשים ופעילות</h2>
      <section class="finance-grid growth-grid">
        <div class="kpi growth"><b>${fmt(u.total)}</b><span>סה״כ משתמשים</span></div>
        <div class="kpi growth good"><b>${fmt(u.new7d)}</b><span>נרשמו 7 ימים</span></div>
        <div class="kpi growth good"><b>${fmt(u.new30d)}</b><span>נרשמו 30 ימים</span></div>
        <div class="kpi growth"><b>${fmt(u.logged7d)}</b><span>התחברו השבוע</span></div>
      </section>
      <section class="finance-grid growth-grid">
        <div class="kpi growth"><b>${fmt(u.regular)}</b><span>קהל</span></div>
        <div class="kpi growth"><b>${fmt(u.business)}</b><span>עסקיים</span></div>
        <div class="kpi growth"><b>${fmt(u.studios)}</b><span>סטודיו</span></div>
        <div class="kpi growth"><b>${fmt(u.artists)}</b><span>אמנים</span></div>
      </section>
      <section class="finance-grid growth-grid">
        <div class="kpi growth"><b>${fmt(u.approvedBusiness)}</b><span>עסקים מאושרים</span></div>
        <div class="kpi growth"><b>${fmt(data.activity.posts)}</b><span>פוסטים</span></div>
        <div class="kpi growth"><b>${fmt(data.activity.reports)}</b><span>דיווחים</span></div>
        <div class="kpi growth"><b>${fmt(data.activity.requests)}</b><span>בקשות</span></div>
      </section>
    </div>

    <section class="finance-grid">
      <div class="kpi good"><b>${ils(m.netMrr)}</b><span>הכנסה חודשית נטו אחרי חנות</span></div>
      <div class="kpi"><b>${ils(m.operatingMonthly)}</b><span>הוצאות תפעול חודשיות</span></div>
      <div class="kpi ${netClass}"><b>${ils(m.netAfterCosts)}</b><span>רווח / הפסד חודשי משוער</span></div>
      <div class="kpi"><b>${fmt(s.payingActive)}</b><span>משתמשים משלמים פעילים</span></div>
    </section>
    <section class="finance-grid">
      <div class="kpi"><b>${ils(m.listGrossMrr)}</b><span>הכנסה ברוטו לפי מחירון</span></div>
      <div class="kpi"><b>${ils(m.storeFeeMonthly)}</b><span>עמלת חנות (${m.storeFeePercent}%)</span></div>
      <div class="kpi"><b>${ils(m.estimatedAnnualGross)}</b><span>הכנסה שנתית ברוטו משוערת</span></div>
      <div class="kpi"><b>${ils(m.arpu)}</b><span>הכנסה נטו למשלם (ARPU)</span></div>
    </section>

    <div class="section-card">
      <h2>הכנסות לפי תוכנית</h2>
      <p>
        <span class="pill-he">חדשים 7 ימים: ${fmt(s.newPaying7d)}</span>
        <span class="pill-he">חדשים 30 ימים: ${fmt(s.newPaying30d)}</span>
        <span class="pill-he">ותיקים: ${fmt(s.oldPaying)}</span>
        <span class="pill-he">מנויי מתנה: ${fmt(s.complimentary)}</span>
        <span class="pill-he">פג תוקף: ${fmt(s.expired)}</span>
        <span class="pill-he">חינם: ${fmt(s.free)}</span>
        <span class="pill-he">Sandbox: ${fmt(s.sandboxActive)}</span>
        <span class="pill-he">iOS: ${fmt(s.iosPaying)}</span>
        <span class="pill-he">Android: ${fmt(s.androidPaying)}</span>
      </p>
      <table class="mix-table">
        <thead><tr><th>סעיף</th><th>פירוט</th><th>סכום חודשי</th></tr></thead>
        <tbody>
          ${
            data.plans.length
              ? data.plans
                  .map(
                    (p) => `<tr>
                      <td>${esc(p.labelHe)}</td>
                      <td>${fmt(p.count)} משלמים · ${ils(p.listPrice)}${p.period === 'year' ? ' לשנה' : p.period === 'month' ? ' לחודש' : ''}</td>
                      <td class="num">${ils(p.monthlyIls)}</td>
                    </tr>`
                  )
                  .join('')
              : '<tr><td colspan="3">אין כרגע מנויים משלמים פעילים — אין הכנסה ממנויים</td></tr>'
          }
        </tbody>
        <tfoot>
          <tr><td>סה״כ ברוטו לפי מחירון</td><td></td><td class="num">${ils(m.listGrossMrr)}</td></tr>
          <tr class="neg"><td>עמלת חנות (${m.storeFeePercent}%)</td><td>Apple / Google</td><td class="num">− ${ils(m.storeFeeMonthly)}</td></tr>
          <tr class="total"><td>הכנסה נטו אחרי חנות</td><td></td><td class="num">${ils(m.netMrr)}</td></tr>
        </tfoot>
      </table>
    </div>

    <div class="section-card">
      <h2>הוצאות לפי סעיף</h2>
      <p class="notes">כל שורה היא הוצאה חודשית משוערת. עמלת החנות מופיעה גם בטבלת ההכנסות כי היא יורדת מהמכירות.</p>
      <table class="mix-table">
        <thead><tr><th>סעיף</th><th>פירוט</th><th>סכום חודשי</th></tr></thead>
        <tbody>
          <tr>
            <td>עמלת חנות (${m.storeFeePercent}%)</td>
            <td>עמלה על מכירות בפועל</td>
            <td class="num">${ils(m.storeFeeMonthly)}</td>
          </tr>
          ${
            (data.costs.items || [])
              .map(
                (item) => `<tr>
                  <td>${esc(item.label)}</td>
                  <td class="notes">${esc(item.note || '')}</td>
                  <td class="num">${ils(item.monthlyIls)}</td>
                </tr>`
              )
              .join('')
          }
        </tbody>
        <tfoot>
          <tr><td>סה״כ תפעול (בלי עמלת חנות)</td><td></td><td class="num">${ils(m.operatingMonthly)}</td></tr>
          <tr><td>סה״כ יוצא מהכיס</td><td>תפעול + עמלת חנות</td><td class="num">${ils(m.operatingMonthly + m.storeFeeMonthly)}</td></tr>
          <tr class="total ${netClass}"><td>רווח / הפסד אחרי הכול</td><td>הכנסה נטו פחות תפעול</td><td class="num">${ils(m.netAfterCosts)}</td></tr>
        </tfoot>
      </table>
    </div>

    <div class="section-card">
      <h2>עריכת הוצאות תפעול</h2>
      <p class="notes">אפשר לעדכן סכומים והערות. בפרודקשן השמירה נשארת עד הדיפלוי הבא.</p>
      <form id="costForm">
        <div class="cost-row">
          <label>עמלת חנות %</label>
          <input name="storeFeePercent" type="number" min="0" max="40" step="0.5" value="${escAttr(data.costs.storeFeePercent)}" />
          <span class="notes">Apple / Google. 15% הוא ברירת מחדל לעסק קטן.</span>
        </div>
        ${data.costs.items
          .map(
            (item, i) => `
          <div class="cost-row">
            <input name="label_${i}" value="${escAttr(item.label)}" data-id="${escAttr(item.id)}" />
            <input name="amount_${i}" type="number" min="0" step="1" value="${escAttr(item.monthlyIls)}" />
            <input name="note_${i}" value="${escAttr(item.note || '')}" placeholder="הערה" />
          </div>`
          )
          .join('')}
        <button class="btn" type="submit">שמור הוצאות</button>
      </form>
      ${data.costs.updatedAt ? `<p class="notes">עודכן לאחרונה: ${esc(new Date(data.costs.updatedAt).toLocaleString('he-IL'))}</p>` : ''}
    </div>

    <div class="section-card notes">
      <h2>איך לחשב</h2>
      <ul>${data.notes.map((n) => `<li>${esc(n)}</li>`).join('')}</ul>
      <p>עלות למשתמש משלם: <b>${ils(m.costPerPayingUser)}</b>. אם המספר הזה גבוה מה-ARPU, כל מנוי מפסיד כסף.</p>
    </div>
  `;

  view.querySelector('#costForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const form = e.target;
    const items = data.costs.items.map((item, i) => ({
      id: item.id,
      label: form[`label_${i}`].value,
      monthlyIls: Number(form[`amount_${i}`].value),
      note: form[`note_${i}`].value,
    }));
    const resSave = await fetch('/api/finance/costs', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        storeFeePercent: Number(form.storeFeePercent.value),
        items,
      }),
    });
    if (!resSave.ok) {
      alert('שמירה נכשלה');
      return;
    }
    renderFinance();
  });
}

async function renderSpec() {
  eyebrow.textContent = 'איך המערכת מתנהגת';
  title.textContent = 'אפיון המודל העסקי';
  topActions.innerHTML = '';
  view.innerHTML = `<p class="empty">טוען אפיון…</p>`;
  const res = await fetch(`/api/spec?source=${encodeURIComponent(state.source || 'live')}`);
  const data = await res.json();
  if (!res.ok) {
    view.innerHTML = `<p class="empty">${esc(data.error || 'לא ניתן לטעון אפיון')}</p>`;
    return;
  }
  const spec = data.spec;
  const snap = data.snapshot;
  topActions.innerHTML = `<span class="mono">${data.source === 'live' ? 'נתונים חיים מ-Railway' : 'ארכיון SQL'} · עודכן ${esc(spec.updatedAt)}${
    data.fallbackReason ? ` · נפל לארכיון: ${esc(data.fallbackReason)}` : ''
  }</span>`;

  view.innerHTML = `
    <p class="spec-lead">${esc(spec.statusLine)}</p>

    <section class="finance-grid">
      <div class="kpi"><b>${fmt(snap.businesses)}</b><span>עסקים במסד</span></div>
      <div class="kpi warn"><b>${fmt(snap.complimentary)}</b><span>מנויי מתנה פעילים</span></div>
      <div class="kpi"><b>${fmt(snap.paying)}</b><span>משלמים פעילים</span></div>
      <div class="kpi"><b>${fmt(snap.free)}</b><span>חבילה חינמית אמיתית</span></div>
    </section>

    <div class="spec-layers">
      ${spec.layers
        .map(
          (layer) => `
        <article class="spec-layer ${escAttr(layer.tone)}">
          <h3>${esc(layer.title)}</h3>
          <p>${esc(layer.body)}</p>
        </article>`
        )
        .join('')}
    </div>

    <div class="section-card">
      <h2>סוגי משתמשים</h2>
      <div class="spec-cards">
        ${spec.users
          .map(
            (u) => `
          <article class="spec-card">
            <h3>${esc(u.title)}</h3>
            <p class="mono">${esc(u.fields)}</p>
            <p>${esc(u.body)}</p>
          </article>`
          )
          .join('')}
      </div>
    </div>

    <div class="section-card">
      <h2>הזרימה שתוכננה</h2>
      <div class="spec-flow">
        ${spec.designedFlow
          .map(
            (step) => `
          <div class="spec-step">
            <b>${esc(step.step)}</b>
            <div>
              <h3>${esc(step.title)}</h3>
              <p>${esc(step.body)}</p>
            </div>
          </div>`
          )
          .join('')}
      </div>
    </div>

    <div class="section-card">
      <h2>חבילות ומחירון באפליקציה</h2>
      <table class="mix-table">
        <thead><tr><th>חבילה</th><th>מזהה</th><th>מחיר</th><th>פרימיום</th><th>הערה</th></tr></thead>
        <tbody>
          ${spec.plans
            .map(
              (p) => `<tr>
                <td>${esc(p.label)}</td>
                <td class="mono">${esc(p.id)}</td>
                <td>${esc(p.price)}</td>
                <td>${esc(p.premium)}</td>
                <td>${esc(p.notes)}</td>
              </tr>`
            )
            .join('')}
        </tbody>
      </table>
    </div>

    <div class="section-card">
      <h2>מה רץ בפועל ב-API החי</h2>
      <div class="spec-cards">
        ${spec.runningToday
          .map(
            (item) => `
          <article class="spec-card">
            <h3>${esc(item.title)}</h3>
            <p>${esc(item.body)}</p>
          </article>`
          )
          .join('')}
      </div>
    </div>

    <div class="section-card">
      <h2>מה פתוח ומה נעול</h2>
      <div class="spec-cards">
        ${spec.gates
          .map(
            (g) => `
          <article class="spec-card">
            <h3>${esc(g.title)}</h3>
            <ul>${g.items.map((i) => `<li>${esc(i)}</li>`).join('')}</ul>
          </article>`
          )
          .join('')}
      </div>
    </div>

    <div class="section-card">
      <h2>טבלת אמת — אפיון מול מציאות</h2>
      <table class="mix-table truth-table">
        <thead><tr><th>שאלה</th><th>האפיון המקורי</th><th>מה רץ ב-API</th><th>מה במסד החי</th></tr></thead>
        <tbody>
          ${spec.truth
            .map(
              (row) => `<tr>
                <td>${esc(row.question)}</td>
                <td>${esc(row.designed)}</td>
                <td>${esc(row.running)}</td>
                <td>${esc(row.live)}</td>
              </tr>`
            )
            .join('')}
        </tbody>
      </table>
    </div>

    <div class="section-card">
      <h2>טבלאות שקובעות את ההתנהגות</h2>
      <table class="mix-table">
        <thead><tr><th>טבלה</th><th>מה נשמר</th></tr></thead>
        <tbody>
          ${spec.tables
            .map((t) => `<tr><td class="mono">${esc(t.name)}</td><td>${esc(t.use)}</td></tr>`)
            .join('')}
        </tbody>
      </table>
      <p class="notes" style="margin-top:14px">
        user_type: 1 ציבורי · 2 עסקי.
        business_type: 1 סטודיו · 2 אמן.
        device_type במנוי: 1 אנדרואיד · 2 אייפון · 3 חינם.
        purchase_token=admin_comp פירושו מתנה מנהלתית, לא תשלום.
      </p>
    </div>
  `;
}

function renderOverview() {
  eyebrow.textContent = state.source === 'live' ? 'Railway חי' : 'ארכיון SQL';
  title.textContent = 'סקירת טבלאות';
  topActions.innerHTML = '';
  const changed = (compare?.changed || []).filter((t) => t.delta);
  const dump = overview.meta.imported_at
    ? new Date(overview.meta.imported_at).toLocaleString('he-IL')
    : overview.meta.label || '—';
  view.innerHTML = `
    <section class="stats">
      <div class="stat"><b>${overview.tableCount}</b><span>טבלאות ב${state.source === 'live' ? 'חי' : 'ארכיון'}</span></div>
      <div class="stat"><b>${fmt(overview.totalRows)}</b><span>שורות</span></div>
      <div class="stat"><b>${changed.length}</b><span>טבלאות עם הפרש בין חי לארכיון</span></div>
    </section>
    ${
      changed.length
        ? `<section class="stat" style="margin-bottom:22px">
            <span>ארכיון מול חי</span>
            <p>${changed
              .map((t) => `${esc(t.label)}: ארכיון ${fmt(t.museum)} → חי ${fmt(t.live)} (${t.delta > 0 ? '+' : ''}${t.delta})`)
              .join(' · ')}</p>
          </section>`
        : `<section class="stat" style="margin-bottom:22px">
            <span>${dump}</span>
            <p>ספירות השורות תואמות בין המקורות, מלבד סשנים אם הם מופיעים למעלה.</p>
          </section>`
    }
    <div class="groups">
      ${overview.groups
        .map(
          (g) => `
        <section>
          <p class="eyebrow">${esc(g.label)}</p>
          <div class="cards">
            ${g.tables
              .map((t) => {
                const delta = deltaOf(t.name);
                const cmp = compare?.tables?.find((x) => x.name === t.name);
                return `
              <a class="card${delta ? ' diff' : ''}" href="${hashFor({ table: t.name })}">
                <h3>${esc(t.label)}</h3>
                <p>${esc(t.name)}</p>
                <div class="meta">
                  <span>${t.columns} עמודות</span>
                  <span>${fmt(t.rows)} שורות${
                    cmp && cmp.museum != null && cmp.live != null
                      ? ` · <span class="delta${delta ? '' : ' zero'}">${delta ? (delta > 0 ? '+' : '') + delta : 'זהה'}</span>`
                      : ''
                  }</span>
                </div>
              </a>`;
              })
              .join('')}
          </div>
        </section>`
        )
        .join('')}
    </div>
  `;
}

async function loadTable() {
  const info = overview.tables.find((t) => t.name === state.table);
  eyebrow.textContent = `${state.table} · ${state.source === 'live' ? 'חי' : 'ארכיון'}`;
  title.textContent = info ? info.label : state.table;
  view.innerHTML = `<p class="empty">טוען…</p>`;
  const qs = new URLSearchParams({
    source: state.source,
    page: String(state.page),
    limit: String(state.limit),
    q: state.q,
    sort: state.sort,
    dir: state.dir,
  });
  const res = await fetch(`/api/tables/${encodeURIComponent(state.table)}?${qs}`);
  const data = await res.json();
  if (!res.ok) {
    view.innerHTML = `<p class="empty">${esc(data.error || 'לא ניתן לטעון טבלה')}</p>`;
    return;
  }
  renderTable(data);
}

function renderTable(data) {
  const delta = deltaOf(data.name);
  topActions.innerHTML = `<span class="mono">${fmt(data.total)} שורות${
    delta ? ` · חי מול ארכיון ${delta > 0 ? '+' : ''}${delta}` : ''
  }</span>`;
  const from = data.total === 0 ? 0 : (data.page - 1) * data.limit + 1;
  const to = Math.min(data.total, data.page * data.limit);
  view.innerHTML = `
    <div class="schema">
      ${data.columns.map((c) => `<span class="pill">${esc(c.name)} · ${esc(c.type || 'TEXT')}</span>`).join('')}
    </div>
    <div class="toolbar">
      <input id="q" type="search" placeholder="חיפוש בטבלה" value="${escAttr(state.q)}" />
      <select id="limit">
        ${[25, 50, 100, 200]
          .map((n) => `<option ${n === state.limit ? 'selected' : ''}>${n}</option>`)
          .join('')}
      </select>
    </div>
    <div class="table-wrap">
      ${
        data.rows.length === 0
          ? `<div class="empty">אין שורות תואמות.</div>`
          : `<table>
              <thead>
                <tr>
                  ${data.columns
                    .map((c) => {
                      const cls =
                        state.sort === c.name
                          ? state.dir === 'desc'
                            ? 'sort-desc'
                            : 'sort-asc'
                          : '';
                      return `<th data-col="${escAttr(c.name)}" class="${cls}">${esc(c.name)}</th>`;
                    })
                    .join('')}
                </tr>
              </thead>
              <tbody>
                ${data.rows
                  .map(
                    (row, idx) => `
                  <tr data-idx="${idx}">
                    ${data.columns.map((c) => `<td>${cellHtml(row[c.name])}</td>`).join('')}
                  </tr>`
                  )
                  .join('')}
              </tbody>
            </table>`
      }
    </div>
    <div class="pager">
      <span>${fmt(from)}–${fmt(to)} מתוך ${fmt(data.total)}</span>
      <div class="pager-btns">
        <button type="button" id="prev" ${data.page <= 1 ? 'disabled' : ''}>הקודם</button>
        <button type="button" id="next" ${data.page >= data.pages ? 'disabled' : ''}>הבא</button>
      </div>
    </div>
  `;

  view.querySelector('#q').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') go({ q: e.target.value, page: 1 });
  });
  view.querySelector('#limit').addEventListener('change', (e) => {
    go({ limit: Number(e.target.value), page: 1 });
  });
  view.querySelector('#prev')?.addEventListener('click', () => go({ page: state.page - 1 }));
  view.querySelector('#next')?.addEventListener('click', () => go({ page: state.page + 1 }));
  view.querySelectorAll('th[data-col]').forEach((th) => {
    th.addEventListener('click', () => {
      const col = th.dataset.col;
      const dir = state.sort === col && state.dir === 'asc' ? 'desc' : 'asc';
      go({ sort: col, dir, page: 1 });
    });
  });
  view.querySelectorAll('tbody tr').forEach((tr) => {
    tr.addEventListener('click', () => openDrawer(data.rows[Number(tr.dataset.idx)], data.columns));
  });
}

function go(patch) {
  location.hash = hashFor(patch);
}

function openDrawer(row, columns) {
  drawer.hidden = false;
  drawerBody.innerHTML = columns
    .map((c) => {
      const v = row[c.name];
      return `<div class="kv"><dt>${esc(c.name)}</dt><dd>${detailHtml(v)}</dd></div>`;
    })
    .join('');
}

function closeDrawer() {
  drawer.hidden = true;
}

function cellHtml(value) {
  if (value === null || value === undefined || value === '') return `<span class="mono">—</span>`;
  const str = String(value);
  const img = imageUrl(str);
  if (img) {
    return `<img class="cell-img" src="${escAttr(img)}" alt="" onerror="this.remove()" /><span>${esc(clip(str, 48))}</span>`;
  }
  return esc(clip(str, 80));
}

function detailHtml(value) {
  if (value === null || value === undefined || value === '') return `<span class="mono">—</span>`;
  const str = String(value);
  const img = imageUrl(str);
  let html = '';
  if (img) html += `<p><img src="${escAttr(img)}" alt="" onerror="this.remove()" /></p>`;
  const pretty = tryPrettyJson(str);
  html += pretty ? `<pre class="mono">${esc(pretty)}</pre>` : esc(str);
  return html;
}

function imageUrl(str) {
  if (/^https?:\/\//i.test(str) && /\.(png|jpe?g|gif|webp)(\?|$)/i.test(str)) return str;
  if (/^https?:\/\/firebasestorage\.googleapis\.com/i.test(str)) return str;
  return null;
}

function tryPrettyJson(str) {
  const t = str.trim();
  if (!(t.startsWith('{') || t.startsWith('['))) return null;
  try {
    return JSON.stringify(JSON.parse(t), null, 2);
  } catch {
    return null;
  }
}

function clip(s, n) {
  return s.length > n ? s.slice(0, n) + '…' : s;
}

function fmt(n) {
  return Number(n).toLocaleString('he-IL');
}

function ils(n) {
  return `${fmt(Number(n) || 0)} ₪`;
}

function esc(s) {
  return String(s)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

function escAttr(s) {
  return esc(s).replaceAll('"', '&quot;');
}
