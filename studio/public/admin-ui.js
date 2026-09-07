const InkAdmin = (() => {
  const TITLES = {
    home: ['ניהול האפליקציה', 'סקירה'],
    users: ['משתמשים מהקהל', 'ניהול'],
    business: ['משתמשים עסקיים', 'ניהול'],
    'report-users': ['דיווחים על משתמשים', 'פיקוח'],
    'report-posts': ['דיווחים על פוסטים', 'פיקוח'],
    requests: ['בקשות קעקוע', 'ניהול'],
    settings: ['הגדרות מערכת', 'ניהול'],
    legacy: ['ממשק PHP ישן', 'גיבוי'],
  };

  function userStatus(status) {
    if (status === '0') return '<span class="badge warn">לא מאושר</span>';
    if (status === '1') return '<span class="badge good">פעיל</span>';
    if (status === '2') return '<span class="badge bad">חסום</span>';
    if (status === '3') return '<span class="badge bad">ארכיון</span>';
    return `<span class="badge">${esc(status)}</span>`;
  }

  function reportStatus(status, kind) {
    if (status === '0') return '<span class="badge warn">ממתין</span>';
    if (status === '1') return `<span class="badge bad">${kind === 'posts' ? 'פוסט נחסם' : 'משתמש נחסם'}</span>`;
    if (status === '2') return '<span class="badge good">נשמר</span>';
    return `<span class="badge">${esc(status)}</span>`;
  }

  function registerType(value) {
    if (value === '1') return 'טלפון';
    if (value === '2') return 'Apple';
    if (value === '3') return 'Gmail';
    return value || '—';
  }

  function businessKind(row) {
    if (row.user_type !== '2') return 'קהל';
    return row.business_type === '2' ? 'אמן' : 'סטודיו';
  }

  function pager(data, hashBase, q) {
    const from = data.total === 0 ? 0 : (data.page - 1) * data.limit + 1;
    const to = Math.min(data.total, data.page * data.limit);
    const qs = (page) => `${hashBase}?page=${page}${q ? `&q=${encodeURIComponent(q)}` : ''}`;
    return `
      <div class="pager">
        <span>${fmt(from)}–${fmt(to)} מתוך ${fmt(data.total)}</span>
        <div class="pager-btns">
          <a class="btn ghost" href="${qs(Math.max(1, data.page - 1))}" ${data.page <= 1 ? 'aria-disabled="true"' : ''}>הקודם</a>
          <a class="btn ghost" href="${qs(Math.min(data.pages, data.page + 1))}" ${data.page >= data.pages ? 'aria-disabled="true"' : ''}>הבא</a>
        </div>
      </div>`;
  }

  function searchBar(placeholder, q, hashBase) {
    return `
      <form class="toolbar" data-search="${escAttr(hashBase)}">
        <input name="q" type="search" placeholder="${escAttr(placeholder)}" value="${escAttr(q)}" />
        <button class="btn" type="submit">חיפוש</button>
      </form>`;
  }

  async function api(path, options) {
    const res = await fetch(path, {
      headers: { 'Content-Type': 'application/json' },
      ...options,
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || 'הפעולה נכשלה');
    return data;
  }

  async function renderHome(ctx) {
    ctx.view.innerHTML = `<p class="empty">טוען סקירה…</p>`;
    const data = await api('/api/admin/dashboard');
    ctx.view.innerHTML = `
      <section class="stats">
        <a class="stat" href="#/admin/users"><b>${fmt(data.regular)}</b><span>משתמשי קהל</span></a>
        <a class="stat" href="#/admin/users/business"><b>${fmt(data.business)}</b><span>עסקיים</span></a>
        <a class="stat" href="#/admin/requests"><b>${fmt(data.requests)}</b><span>בקשות</span></a>
      </section>
      <section class="stats">
        <div class="stat"><b>${fmt(data.posts)}</b><span>פוסטים פעילים</span></div>
        <a class="stat" href="#/admin/reports/users"><b>${fmt(data.pendingUserReports)}</b><span>דיווחי משתמשים ממתינים</span></a>
        <a class="stat" href="#/admin/reports/posts"><b>${fmt(data.pendingPostReports)}</b><span>דיווחי פוסטים ממתינים</span></a>
      </section>
      <p class="notes">המסכים האלה כותבים ישירות ל-MySQL החי. פוש, העלאת תמונת startup ותבנית Metronic לא הועברו.</p>
    `;
  }

  async function renderUsers(ctx, type) {
    const q = ctx.q || '';
    const hashBase = type === 'business' ? '#/admin/users/business' : '#/admin/users';
    ctx.view.innerHTML = `${searchBar('חיפוש לפי שם, טלפון או אימייל', q, hashBase)}<p class="empty">טוען…</p>`;
    const data = await api(`/api/admin/users?type=${type}&page=${ctx.page}&q=${encodeURIComponent(q)}`);
    ctx.view.innerHTML = `
      ${searchBar('חיפוש לפי שם, טלפון או אימייל', q, hashBase)}
      <div class="table-wrap">
        ${
          data.rows.length === 0
            ? `<div class="empty">אין משתמשים תואמים.</div>`
            : `<table>
                <thead>
                  <tr>
                    <th>שם</th><th>טלפון</th><th>אימייל</th><th>סוג</th>
                    <th>סטטוס</th><th>תוכנית</th><th>פוסטים</th><th>פעולות</th>
                  </tr>
                </thead>
                <tbody>
                  ${data.rows
                    .map(
                      (row) => `
                    <tr class="no-row-click" data-id="${row.id}">
                      <td>${esc(row.name || '—')}</td>
                      <td>${esc(row.phone || '—')}</td>
                      <td>${esc(row.email || '—')}</td>
                      <td>${esc(businessKind(row))} · ${esc(registerType(row.register_type))}</td>
                      <td>${userStatus(row.status)}</td>
                      <td>${esc(row.plan_label || '—')}</td>
                      <td>
                        <input class="limit-input" data-limit="${row.id}" type="number" min="0" value="${escAttr(row.post_limit ?? 0)}" />
                      </td>
                      <td class="row-actions">
                        ${
                          row.status === '2'
                            ? `<button class="btn ghost" data-user-action="activate" data-id="${row.id}">הפעל</button>`
                            : `<button class="btn ghost" data-user-action="block" data-id="${row.id}">חסום</button>`
                        }
                        <button class="btn danger" data-user-action="delete" data-id="${row.id}">מחק</button>
                      </td>
                    </tr>`
                    )
                    .join('')}
                </tbody>
              </table>`
        }
      </div>
      ${pager(data, hashBase, q)}
    `;
    bindSearch(ctx);
    ctx.view.querySelectorAll('[data-user-action]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const action = btn.dataset.userAction;
        const labels = { block: 'לחסום', activate: 'להפעיל', delete: 'למחוק' };
        if (!confirm(`ל${labels[action]} את המשתמש?`)) return;
        try {
          await api(`/api/admin/users/${btn.dataset.id}/status`, {
            method: 'POST',
            body: JSON.stringify({ action }),
          });
          render(ctx);
        } catch (err) {
          alert(err.message);
        }
      });
    });
    ctx.view.querySelectorAll('[data-limit]').forEach((input) => {
      input.addEventListener('change', async () => {
        try {
          await api(`/api/admin/users/${input.dataset.limit}/post-limit`, {
            method: 'POST',
            body: JSON.stringify({ post_limit: Number(input.value) }),
          });
        } catch (err) {
          alert(err.message);
        }
      });
    });
  }

  async function renderReports(ctx, kind) {
    const q = ctx.q || '';
    const hashBase = kind === 'posts' ? '#/admin/reports/posts' : '#/admin/reports/users';
    ctx.view.innerHTML = `${searchBar('חיפוש בדיווחים', q, hashBase)}<p class="empty">טוען…</p>`;
    const data = await api(`/api/admin/reports/${kind}?page=${ctx.page}&q=${encodeURIComponent(q)}`);
    const head =
      kind === 'posts'
        ? '<th>בעלים</th><th>מדווח</th><th>תמונה</th><th>סיבה</th><th>סטטוס</th><th>פעולות</th>'
        : '<th>משתמש</th><th>מדווח</th><th>סיבה</th><th>סטטוס</th><th>פעולות</th>';
    ctx.view.innerHTML = `
      ${searchBar('חיפוש בדיווחים', q, hashBase)}
      <div class="table-wrap">
        ${
          data.rows.length === 0
            ? `<div class="empty">אין דיווחים.</div>`
            : `<table>
                <thead><tr>${head}</tr></thead>
                <tbody>
                  ${data.rows
                    .map((row) => {
                      const img = row.post_image
                        ? `<img class="cell-img" src="${escAttr(row.post_image)}" alt="" onerror="this.remove()" />`
                        : '—';
                      return `
                      <tr class="no-row-click">
                        <td>${esc(row.user_name || row.owner_name || '—')}</td>
                        <td>${esc(row.reported_by || '—')}</td>
                        ${kind === 'posts' ? `<td>${img}</td>` : ''}
                        <td>${esc(row.comment || '—')}</td>
                        <td>${reportStatus(row.status, kind)}</td>
                        <td class="row-actions">
                          <button class="btn ghost" data-report="keep" data-id="${row.id}">השאר</button>
                          <button class="btn danger" data-report="block" data-id="${row.id}">חסום</button>
                        </td>
                      </tr>`;
                    })
                    .join('')}
                </tbody>
              </table>`
        }
      </div>
      ${pager(data, hashBase, q)}
    `;
    bindSearch(ctx);
    ctx.view.querySelectorAll('[data-report]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const action = btn.dataset.report;
        if (!confirm(action === 'block' ? 'לחסום לפי הדיווח?' : 'להשאיר ולסגור את הדיווח?')) return;
        try {
          await api(`/api/admin/reports/${kind}/${btn.dataset.id}`, {
            method: 'POST',
            body: JSON.stringify({ action }),
          });
          render(ctx);
        } catch (err) {
          alert(err.message);
        }
      });
    });
  }

  async function renderRequests(ctx) {
    const q = ctx.q || '';
    ctx.view.innerHTML = `${searchBar('חיפוש בבקשות', q, '#/admin/requests')}<p class="empty">טוען…</p>`;
    const data = await api(`/api/admin/requests?page=${ctx.page}&q=${encodeURIComponent(q)}`);
    ctx.view.innerHTML = `
      ${searchBar('חיפוש בבקשות', q, '#/admin/requests')}
      <div class="table-wrap">
        ${
          data.rows.length === 0
            ? `<div class="empty">אין בקשות.</div>`
            : `<table>
                <thead>
                  <tr>
                    <th>שם</th><th>לקוח</th><th>עסק</th><th>גודל</th>
                    <th>סגנונות</th><th>תיאור</th><th>תאריך</th>
                  </tr>
                </thead>
                <tbody>
                  ${data.rows
                    .map(
                      (row) => `
                    <tr class="no-row-click">
                      <td>${esc(row.name || '—')}</td>
                      <td>${esc(row.customer_name || '—')}</td>
                      <td>${esc(row.business_name || '—')}</td>
                      <td>${esc(row.tattoo_size || '—')}</td>
                      <td>${esc(row.styles || '—')}</td>
                      <td>${esc(clip(row.description || '—', 80))}</td>
                      <td>${esc(row.date_added || '—')}</td>
                    </tr>`
                    )
                    .join('')}
                </tbody>
              </table>`
        }
      </div>
      ${pager(data, '#/admin/requests', q)}
    `;
    bindSearch(ctx);
  }

  async function renderSettings(ctx) {
    ctx.view.innerHTML = `<p class="empty">טוען הגדרות…</p>`;
    const data = await api('/api/admin/settings');
    const s = data.settings || {};
    ctx.view.innerHTML = `
      <form class="admin-form" id="settingsForm">
        <label>אימייל מנהל
          <input name="admin_email" type="email" value="${escAttr(s.admin_email || '')}" />
        </label>
        <label>טלפון מנהל
          <input name="admin_phone" type="text" value="${escAttr(s.admin_phone || '')}" />
        </label>
        <label>שם חבילה
          <input name="package_name" type="text" value="${escAttr(s.package_name || '')}" />
        </label>
        <label>מגבלת פוסטים ברירת מחדל
          <input name="post_limit" type="number" min="0" value="${escAttr(s.post_limit || '')}" />
        </label>
        <div>
          <button class="btn" type="submit">שמירה</button>
        </div>
      </form>
    `;
    ctx.view.querySelector('#settingsForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const form = new FormData(e.target);
      try {
        await api('/api/admin/settings', {
          method: 'PUT',
          body: JSON.stringify(Object.fromEntries(form.entries())),
        });
        ctx.view.insertAdjacentHTML('afterbegin', `<p class="flash ok">ההגדרות נשמרו.</p>`);
      } catch (err) {
        alert(err.message);
      }
    });
  }

  function renderLegacy(ctx) {
    const url = ctx.studio?.adminUrl || 'http://127.0.0.1:8080/admin/';
    ctx.view.innerHTML = `<iframe class="admin-frame" title="ממשק ניהול PHP" src="${escAttr(url)}"></iframe>`;
  }

  function bindSearch(ctx) {
    const form = ctx.view.querySelector('form[data-search]');
    if (!form) return;
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const q = form.q.value.trim();
      const base = form.dataset.search;
      location.hash = q ? `${base}?q=${encodeURIComponent(q)}` : base;
    });
  }

  function highlight(section) {
    document.querySelectorAll('#adminNav a').forEach((a) => {
      a.classList.toggle('active', a.dataset.admin === section);
    });
  }

  async function render(ctx) {
    const section = ctx.section || 'home';
    const [title, eyebrow] = TITLES[section] || TITLES.home;
    ctx.title.textContent = title;
    ctx.eyebrow.textContent = eyebrow;
    ctx.topActions.innerHTML = '';
    document.body.classList.toggle('mode-legacy', section === 'legacy');
    highlight(section);
    try {
      if (section === 'home') await renderHome(ctx);
      else if (section === 'users') await renderUsers(ctx, 'regular');
      else if (section === 'business') await renderUsers(ctx, 'business');
      else if (section === 'report-users') await renderReports(ctx, 'users');
      else if (section === 'report-posts') await renderReports(ctx, 'posts');
      else if (section === 'requests') await renderRequests(ctx);
      else if (section === 'settings') await renderSettings(ctx);
      else if (section === 'legacy') renderLegacy(ctx);
    } catch (err) {
      ctx.view.innerHTML = `<p class="empty">${esc(err.message || 'לא ניתן לטעון את מסך הניהול')}</p>`;
    }
  }

  function clip(s, n) {
    return s.length > n ? s.slice(0, n) + '…' : s;
  }

  function fmt(n) {
    return Number(n).toLocaleString('he-IL');
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

  return { render };
})();
