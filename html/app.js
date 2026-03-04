const wrap = document.getElementById('wrap');
const toast = document.getElementById('toast');

const pageHome = document.getElementById('pageHome');
const pageSettings = document.getElementById('pageSettings');

const navHome = document.getElementById('navHome');
const navSettings = document.getElementById('navSettings');

const timeText = document.getElementById('timeText');

const el = (id) => document.getElementById(id);

function setPage(which) {
  const home = which === 'home';
  pageHome.classList.toggle('hidden', !home);
  pageSettings.classList.toggle('hidden', home);

  navHome.classList.toggle('active', home);
  navSettings.classList.toggle('active', !home);
}

function showToast(text) {
  toast.textContent = text;
  toast.classList.remove('hidden');
  setTimeout(() => toast.classList.add('hidden'), 2500);
}

function clamp(n, min, max, def) {
  n = parseInt(n, 10);
  if (Number.isNaN(n)) n = def;
  if (n < min) n = min;
  if (n > max) n = max;
  return n;
}

function loadSettings(s) {
  s = s || {
    enabled: true,
    health: { enabled: true, threshold: 35, step: 5 },
    hunger: { enabled: true, threshold: 35, step: 5 },
    thirst: { enabled: true, threshold: 35, step: 5 },
  };

  el('enabled').checked = !!s.enabled;

  el('healthEnabled').checked = !!s.health?.enabled;
  el('healthThreshold').value = s.health?.threshold ?? 35;
  el('healthStep').value = s.health?.step ?? 5;

  el('hungerEnabled').checked = !!s.hunger?.enabled;
  el('hungerThreshold').value = s.hunger?.threshold ?? 35;
  el('hungerStep').value = s.hunger?.step ?? 5;

  el('thirstEnabled').checked = !!s.thirst?.enabled;
  el('thirstThreshold').value = s.thirst?.threshold ?? 35;
  el('thirstStep').value = s.thirst?.step ?? 5;

  syncUITexts();
}

function collectSettings() {
  return {
    enabled: el('enabled').checked,
    health: {
      enabled: el('healthEnabled').checked,
      threshold: clamp(el('healthThreshold').value, 1, 100, 35),
      step: clamp(el('healthStep').value, 1, 25, 5),
    },
    hunger: {
      enabled: el('hungerEnabled').checked,
      threshold: clamp(el('hungerThreshold').value, 1, 100, 35),
      step: clamp(el('hungerStep').value, 1, 25, 5),
    },
    thirst: {
      enabled: el('thirstEnabled').checked,
      threshold: clamp(el('thirstThreshold').value, 1, 100, 35),
      step: clamp(el('thirstStep').value, 1, 25, 5),
    },
  };
}

function syncUITexts() {
  const ht = clamp(el('healthThreshold').value, 1, 100, 35);
  const hs = clamp(el('healthStep').value, 1, 25, 5);

  const hut = clamp(el('hungerThreshold').value, 1, 100, 35);
  const hus = clamp(el('hungerStep').value, 1, 25, 5);

  const tt = clamp(el('thirstThreshold').value, 1, 100, 35);
  const ts = clamp(el('thirstStep').value, 1, 25, 5);

  el('healthThresholdText').textContent = ht;
  el('healthStepText').textContent = hs;

  el('hungerThresholdText').textContent = hut;
  el('hungerStepText').textContent = hus;

  el('thirstThresholdText').textContent = tt;
  el('thirstStepText').textContent = ts;

  // previews on home
  el('healthPreview').textContent = ht;
  el('hungerPreview').textContent = hut;
  el('thirstPreview').textContent = tt;
}

// Listen for slider changes
['healthThreshold','healthStep','hungerThreshold','hungerStep','thirstThreshold','thirstStep'].forEach(id => {
  el(id).addEventListener('input', syncUITexts);
});

window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === "status") {
  // Big numbers = CURRENT values
  const h = Math.max(0, Math.min(100, parseInt(data.health ?? 100, 10)));
  const hu = Math.max(0, Math.min(100, parseInt(data.hunger ?? 100, 10)));
  const t = Math.max(0, Math.min(100, parseInt(data.thirst ?? 100, 10)));

  // These IDs currently show the big numbers in your tiles
  document.getElementById('healthPreview').textContent = h;
  document.getElementById('hungerPreview').textContent = hu;
  document.getElementById('thirstPreview').textContent = t;
}

  if (data.action === "open") {
    wrap.classList.remove('hidden');
    setPage('home');
    loadSettings(data.settings);
  }

  if (data.action === "close") {
    wrap.classList.add('hidden');
    toast.classList.add('hidden');
  }

  if (data.action === "toast") {
    showToast(`${data.label}: ${data.value}%`);
  }
});

// Nav buttons
navHome.addEventListener('click', () => setPage('home'));
navSettings.addEventListener('click', () => setPage('settings'));

document.getElementById('btnClose').addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
});

document.getElementById('btnSave').addEventListener('click', () => {
  const settings = collectSettings();
  fetch(`https://${GetParentResourceName()}/save`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(settings)
  });
  showToast("Saved ✓");
});

// Clock
function pad(n){ return String(n).padStart(2, '0'); }
setInterval(() => {
  const d = new Date();
  timeText.textContent = `${pad(d.getHours())}:${pad(d.getMinutes())}`;
}, 500);