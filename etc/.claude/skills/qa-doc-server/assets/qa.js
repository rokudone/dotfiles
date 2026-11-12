// 文書ページ共通: 左にページ一覧、右に質問と回答、本文選択から質問を送る。
// ページ側の要件: 本文を <main id="main"> に置き、見出し (h1-h4) に id を付ける。
(function () {
  const main = document.getElementById('main');
  const PAGE = (location.pathname.match(/^\/((?:day)?\d+)/) || [, ''])[1];

  const wrap = document.createElement('div'); wrap.className = 'wrap';
  const nav = document.createElement('nav'); nav.className = 'days';
  const aside = document.createElement('aside'); aside.className = 'qa';
  aside.innerHTML = '<h2>質問と回答</h2><div id="qlist"></div>';
  main.parentNode.insertBefore(wrap, main);
  wrap.appendChild(nav); wrap.appendChild(main); wrap.appendChild(aside);

  const btn = document.createElement('button'); btn.id = 'askbtn'; btn.textContent = '質問';
  const modal = document.createElement('div'); modal.id = 'modal';
  modal.innerHTML = '<div class="box"><div class="sec" id="msec"></div><div class="quote" id="mquote"></div>'
    + '<textarea id="mtext" placeholder="ここがわからない、と書く"></textarea>'
    + '<div class="row"><button id="mcancel">やめる</button><button id="msend" class="primary">送る</button></div></div>';
  document.body.appendChild(btn); document.body.appendChild(modal);

  async function loadNav() {
    const res = await fetch('/api/pages');
    const pages = await res.json();
    nav.innerHTML = '';
    for (const p of pages) {
      const a = document.createElement('a');
      a.href = p.path; a.textContent = p.label;
      if (p.key === PAGE || (!PAGE && p === pages[0])) a.className = 'cur';
      nav.appendChild(a);
    }
  }

  function sectionOf(node) {
    let el = node.nodeType === 1 ? node : node.parentElement;
    while (el && el !== main) {
      let s = el.previousElementSibling;
      while (s) { if (/^H[1-4]$/.test(s.tagName)) return { id: s.id, title: s.textContent }; s = s.previousElementSibling; }
      el = el.parentElement;
    }
    return { id: '', title: '' };
  }

  let pending = null;
  document.addEventListener('selectionchange', () => {
    const sel = window.getSelection();
    if (!sel || sel.isCollapsed || !main.contains(sel.anchorNode)) { btn.style.display = 'none'; return; }
    const r = sel.getRangeAt(0).getBoundingClientRect();
    btn.style.display = 'block';
    btn.style.left = Math.max(8, r.left) + 'px';
    btn.style.top = (r.bottom + 8) + 'px';
  });

  btn.addEventListener('mousedown', e => {
    e.preventDefault();
    const sel = window.getSelection();
    const quote = sel.toString().trim();
    const sec = sectionOf(sel.anchorNode);
    pending = { page: PAGE, section: sec.id, section_title: sec.title, quote };
    document.getElementById('msec').textContent = (PAGE || '/') + ' / ' + sec.title;
    document.getElementById('mquote').textContent = quote;
    document.getElementById('mtext').value = '';
    modal.style.display = 'flex';
    btn.style.display = 'none';
    setTimeout(() => document.getElementById('mtext').focus(), 0);
  });

  document.getElementById('mcancel').onclick = () => { modal.style.display = 'none'; pending = null; };
  document.getElementById('msend').onclick = async () => {
    const text = document.getElementById('mtext').value.trim();
    if (!text || !pending) return;
    pending.question = text;
    await fetch('/api/questions', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(pending) });
    modal.style.display = 'none'; pending = null;
    load();
  };
  document.getElementById('mtext').addEventListener('keydown', e => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') document.getElementById('msend').click();
  });

  async function load() {
    const res = await fetch('/api/questions?page=' + encodeURIComponent(PAGE));
    const items = await res.json();
    const list = document.getElementById('qlist');
    list.innerHTML = '';
    if (!items.length) { list.innerHTML = '<div class="q" style="color:var(--muted)">本文を選択して「質問」を押す</div>'; return; }
    for (const q of items.slice().reverse()) {
      const d = document.createElement('div'); d.className = 'q';
      const sec = document.createElement('div'); sec.className = 'sec';
      const a = document.createElement('a'); a.href = '#' + q.section; a.textContent = q.section_title || q.section || '(本文)'; sec.appendChild(a);
      d.appendChild(sec);
      if (q.quote) { const qq = document.createElement('div'); qq.className = 'quote'; qq.textContent = q.quote; d.appendChild(qq); }
      const t = document.createElement('div'); t.className = 'text'; t.textContent = q.question; d.appendChild(t);
      if (q.answer) { const an = document.createElement('div'); an.className = 'ans'; an.textContent = q.answer; d.appendChild(an); }
      else { const p = document.createElement('div'); p.className = 'pending'; p.textContent = '回答待ち'; d.appendChild(p); }
      list.appendChild(d);
    }
  }

  loadNav();
  load();
  setInterval(load, 5000);
})();
