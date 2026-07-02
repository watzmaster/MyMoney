const state = {
  token: localStorage.getItem('finance_token') || '',
  user: null,
  accounts: [],
  categories: [],
  transactions: [],
  budgets: [],
  recurring: [],
  reports: {
    summary: null,
    categoryBreakdown: [],
    cashflow: [],
    budgetUsage: []
  }
};

const titles = {
  dashboard: 'ภาพรวม',
  transactions: 'รายการเงิน',
  accounts: 'บัญชี',
  categories: 'หมวดหมู่',
  budgets: 'งบประมาณ',
  recurring: 'รายการประจำ',
  reports: 'รายงาน',
  settings: 'ตั้งค่า'
};

const icons = {
  dashboard: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 13h8V3H3v10Zm0 8h8v-6H3v6Zm10 0h8V11h-8v10Zm0-18v6h8V3h-8Z"/></svg>',
  receipt: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 2h12a1 1 0 0 1 1 1v19l-3-2-3 2-3-2-3 2-3-2V3a1 1 0 0 1 1-1Zm3 6h6V6H9v2Zm0 5h6v-2H9v2Zm0 4h4v-2H9v2Z"/></svg>',
  wallet: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h14a2 2 0 0 1 2 2v1h-4a5 5 0 0 0 0 10h4v1a2 2 0 0 1-2 2H4a3 3 0 0 1-3-3V8a3 3 0 0 1 3-3Zm12 5h5a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1h-5a3 3 0 0 1 0-6Zm1 4h2v-2h-2v2Z"/></svg>',
  tags: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10 3H4a1 1 0 0 0-1 1v6l10 10 7-7L10 3Zm-3 6a2 2 0 1 1 0-4 2 2 0 0 1 0 4Zm6-6 8 8-2 2-8-8 2-2Z"/></svg>',
  target: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2a10 10 0 1 0 10 10h-2a8 8 0 1 1-8-8V2Zm0 4a6 6 0 1 0 6 6h-2a4 4 0 1 1-4-4V6Zm0 4a2 2 0 1 0 2 2h-2v-2Zm5.6-7.6V6H14v2h3.6L12 13.6 13.4 15 19 9.4V13h2V7.4h1.6l-5-5Z"/></svg>',
  repeat: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 7h10l-2-2 1.4-1.4L21 8l-4.6 4.4L15 11l2-2H7a3 3 0 0 0-3 3H2a5 5 0 0 1 5-5Zm10 10H7l2 2-1.4 1.4L3 16l4.6-4.4L9 13l-2 2h10a3 3 0 0 0 3-3h2a5 5 0 0 1-5 5Z"/></svg>',
  chart: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 19h17v2H3a1 1 0 0 1-1-1V4h2v15Zm3-2V9h3v8H7Zm5 0V5h3v12h-3Zm5 0v-6h3v6h-3Z"/></svg>',
  logout: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 3h9v2H6v14h7v2H4V3Zm12.6 5.4L15.2 9.8 17.4 12H10v2h7.4l-2.2 2.2 1.4 1.4L21.2 13l-4.6-4.6Z"/></svg>',
  refresh: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M17.7 6.3A8 8 0 1 0 20 12h-2a6 6 0 1 1-1.8-4.3L13 11h8V3l-3.3 3.3Z"/></svg>',
  bell: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 22a2.5 2.5 0 0 0 2.4-2h-4.8A2.5 2.5 0 0 0 12 22Zm8-5-2-2V9a6 6 0 0 0-5-5.9V1h-2v2.1A6 6 0 0 0 6 9v6l-2 2v1h16v-1Z"/></svg>',
  menu: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 6h16v2H4V6Zm0 5h16v2H4v-2Zm0 5h16v2H4v-2Z"/></svg>',
  settings: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m19.4 13.5 1.6 1.2-2 3.5-1.9-.8a7.4 7.4 0 0 1-1.6.9L15.2 20h-4l-.3-1.7a7.4 7.4 0 0 1-1.6-.9l-1.9.8-2-3.5 1.6-1.2a6.7 6.7 0 0 1 0-1.8l-1.6-1.2 2-3.5 1.9.8a7.4 7.4 0 0 1 1.6-.9L11.2 5h4l.3 1.7a7.4 7.4 0 0 1 1.6.9L19 6.8l2 3.5-1.6 1.2a6.7 6.7 0 0 1 0 2ZM13.2 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/></svg>',
  check: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9.2 16.6-4.1-4.1L3.7 14l5.5 5.5L21 7.7l-1.4-1.4L9.2 16.6Z"/></svg>',
  eraser: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14.5 3.5a3 3 0 0 1 4.2 0l1.8 1.8a3 3 0 0 1 0 4.2L10 20H4l-2.5-2.5a3 3 0 0 1 0-4.2l13-13.8ZM8.6 18l4.4-4.4-4.6-4.6-5.5 5.5a1 1 0 0 0 0 1.4L5 18h3.6Z"/></svg>',
  save: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h12l2 2v16H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Zm2 2v6h9V5H7Zm1 14h8v-5H8v5Z"/></svg>',
  edit: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 17.2V21h3.8L18.9 9.9l-3.8-3.8L4 17.2ZM21 7.8a1.2 1.2 0 0 0 0-1.7L18.9 4a1.2 1.2 0 0 0-1.7 0l-1 1 3.8 3.8 1-1Z"/></svg>',
  trash: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 4V2h8v2h5v2H3V4h5Zm-2 4h12l-1 13H7L6 8Zm4 3v7h2v-7h-2Zm4 0v7h2v-7h-2Z"/></svg>',
  utensils: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 2h2v8a3 3 0 0 1-2 2.8V22H5v-9.2A3 3 0 0 1 3 10V2h2v8h1V2h1Zm8 0h2v20h-2v-8h-2V6a4 4 0 0 1 2-4Z"/></svg>',
  car: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6h12l2 6h2v6h-2a3 3 0 0 1-6 0h-4a3 3 0 0 1-6 0H2v-6h2l2-6Zm1.4 2-1.3 4h11.8l-1.3-4H7.4ZM7 19a1 1 0 1 0 0-2 1 1 0 0 0 0 2Zm10 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z"/></svg>',
  'shopping-bag': '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 7a5 5 0 0 1 10 0h3l1 15H3L4 7h3Zm2 0h6a3 3 0 0 0-6 0Zm0 4H7v2a5 5 0 0 0 10 0v-2h-2v2a3 3 0 0 1-6 0v-2Z"/></svg>',
  'heart-pulse': '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 21S3 15.8 3 8.8A5 5 0 0 1 12 5a5 5 0 0 1 9 3.8c0 7-9 12.2-9 12.2Zm-5-9h3l1-3 2 6 1.2-3H17v-2h-4.2l-.7 1.8-2-6L8.6 10H7v2Z"/></svg>',
  'book-open': '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 4.5A8 8 0 0 1 11 6v14a8 8 0 0 0-8-1.5v-14Zm10 1.5a8 8 0 0 1 8-1.5v14A8 8 0 0 0 13 20V6Z"/></svg>',
  sparkles: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2 1.8 5.2L19 9l-5.2 1.8L12 16l-1.8-5.2L5 9l5.2-1.8L12 2Zm6 12 1 3 3 1-3 1-1 3-1-3-3-1 3-1 1-3ZM5 13l.8 2.2L8 16l-2.2.8L5 19l-.8-2.2L2 16l2.2-.8L5 13Z"/></svg>',
  home: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 3 9 8h-3v10h-5v-6h-2v6H6V11H3l9-8Z"/></svg>',
  gift: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 7h-2.2A3 3 0 0 0 12 5.8 3 3 0 0 0 6.2 7H4v5h1v9h14v-9h1V7ZM9 5a1 1 0 0 1 1 1v1H8a1 1 0 0 1 1-2Zm6 0a1 1 0 0 1 1 2h-2V6a1 1 0 0 1 1-1ZM7 12h4v7H7v-7Zm6 7v-7h4v7h-4Z"/></svg>'
};

const categoryIconOptions = [
  'receipt',
  'utensils',
  'car',
  'shopping-bag',
  'wallet',
  'heart-pulse',
  'book-open',
  'home',
  'gift',
  'sparkles',
  'target',
  'tags'
];

const categoryColorOptions = [
  '#f97316',
  '#ef4444',
  '#ec4899',
  '#8b5cf6',
  '#3b82f6',
  '#06b6d4',
  '#0f766e',
  '#22c55e',
  '#eab308',
  '#64748b'
];

const money = new Intl.NumberFormat('th-TH', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2
});

const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => Array.from(root.querySelectorAll(selector));
let lastBudgetNotificationKey = '';
let budgetNotificationsEnabled = localStorage.getItem('budget_notifications_enabled') !== 'false';
let pendingAdView = null;
let adTimer = null;

document.addEventListener('DOMContentLoaded', () => {
  hydrateIcons();
  buildCategoryPickers();
  setDefaultDates();
  bindAuth();
  bindNavigation();
  bindForms();
  bindFilters();

  if (state.token) {
    showApp();
    loadAll();
  } else {
    showAuth();
  }
});

function hydrateIcons(root = document) {
  $$('[data-icon]', root).forEach(element => {
    element.innerHTML = icons[element.dataset.icon] || '';
  });
}

function icon(name) {
  return `<span class="icon">${icons[name] || ''}</span>`;
}

function setDefaultDates() {
  const now = new Date();
  const first = new Date(now.getFullYear(), now.getMonth(), 1);
  const last = new Date(now.getFullYear(), now.getMonth() + 1, 0);
  $('#global-from').value = formatDate(first);
  $('#global-to').value = formatDate(last);
  $('#budget-month').value = formatMonth(now);
  $('[name="transaction_date"]').value = formatDate(now);
  $('[name="next_run_date"]').value = formatDate(now);
  $('[name="month"]').value = formatMonth(now);
}

function bindAuth() {
  $$('[data-auth-tab]').forEach(button => {
    button.addEventListener('click', () => {
      $$('[data-auth-tab]').forEach(item => item.classList.remove('active'));
      button.classList.add('active');
      $('#login-form').classList.toggle('hidden', button.dataset.authTab !== 'login');
      $('#register-form').classList.toggle('hidden', button.dataset.authTab !== 'register');
      $('#auth-message').textContent = '';
    });
  });

  $('#login-form').addEventListener('submit', async event => {
    event.preventDefault();
    await authenticate('/auth/login', formData(event.currentTarget));
  });

  $('#register-form').addEventListener('submit', async event => {
    event.preventDefault();
    await authenticate('/auth/register', formData(event.currentTarget));
  });

  $('#logout-button').addEventListener('click', () => {
    localStorage.removeItem('finance_token');
    state.token = '';
    showAuth();
  });
}

function bindNavigation() {
  $$('.nav').forEach(button => {
    button.addEventListener('click', () => {
      const view = button.dataset.view;
      if (shouldShowAdBeforeNavigation(view)) {
        showAdInterstitial(view);
        closeMenu();
        return;
      }
      navigateTo(view);
    });
  });

  $('#menu-button').addEventListener('click', toggleMenu);
  $('#menu-backdrop').addEventListener('click', closeMenu);
  window.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
      closeMenu();
    }
  });
  window.addEventListener('resize', () => {
    if (window.innerWidth > 1180) {
      closeMenu();
    }
  });
  $('#ad-continue-button').addEventListener('click', continueAfterAd);
  $('#premium-close-button').addEventListener('click', closePremiumModal);
  $('#premium-modal').addEventListener('click', event => {
    if (event.target.id === 'premium-modal') {
      closePremiumModal();
    }
  });
  $('#payment-button').addEventListener('click', () => {
    toast('หน้าชำระเงินจะเชื่อมต่อ payment gateway ในขั้นถัดไป');
  });
  $$('[data-open-premium]').forEach(button => {
    button.addEventListener('click', openPremiumModal);
  });
  $('#refresh-button').addEventListener('click', loadAll);
  $('#notification-button')?.addEventListener('click', requestNotificationPermission);
}

function navigateTo(view) {
  const button = $(`.nav[data-view="${view}"]`);
  if (!button) {
    return;
  }

  $$('.nav').forEach(item => item.classList.remove('active'));
  button.classList.add('active');
  $$('.view').forEach(item => item.classList.remove('active'));
  $(`#${view}`).classList.add('active');
  $('#view-title').textContent = titles[view] || view;
  closeMenu();
}

function toggleMenu() {
  document.body.classList.toggle('menu-open');
  const isOpen = document.body.classList.contains('menu-open');
  $('#menu-button').setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  $('#menu-button').classList.toggle('active', isOpen);
}

function closeMenu() {
  document.body.classList.remove('menu-open');
  const button = $('#menu-button');
  if (button) {
    button.setAttribute('aria-expanded', 'false');
    button.classList.remove('active');
  }
}

function shouldShowAdBeforeNavigation(view) {
  const activeView = $('.view.active')?.id;
  if (!state.user || view === activeView) {
    return false;
  }

  return state.user.access_tier === 'free_with_ads' && Math.random() < 0.35;
}

function showAdInterstitial(view) {
  pendingAdView = view;
  let seconds = 15;
  const modal = $('#ad-interstitial');
  const countdown = $('#ad-countdown');
  const button = $('#ad-continue-button');

  countdown.textContent = String(seconds);
  button.disabled = true;
  modal.classList.remove('hidden');

  window.clearInterval(adTimer);
  adTimer = window.setInterval(() => {
    seconds -= 1;
    countdown.textContent = String(Math.max(0, seconds));

    if (seconds <= 0) {
      window.clearInterval(adTimer);
      button.disabled = false;
      button.querySelector('span:last-child').textContent = 'ไปต่อ';
    }
  }, 1000);
}

function continueAfterAd() {
  if (!pendingAdView) {
    return;
  }

  $('#ad-interstitial').classList.add('hidden');
  const view = pendingAdView;
  pendingAdView = null;
  navigateTo(view);
}

function openPremiumModal() {
  $('#premium-modal').classList.remove('hidden');
  hydrateIcons($('#premium-modal'));
}

function closePremiumModal() {
  $('#premium-modal').classList.add('hidden');
}

function bindForms() {
  $('#account-form').addEventListener('submit', saveAccount);
  $('#category-form').addEventListener('submit', saveCategory);
  $('#transaction-form').addEventListener('submit', saveTransaction);
  $('#budget-form').addEventListener('submit', saveBudget);
  $('#recurring-form').addEventListener('submit', saveRecurring);
  $('#password-form').addEventListener('submit', changePassword);

  $$('[data-reset-form]').forEach(button => {
    button.addEventListener('click', () => resetNamedForm(button.dataset.resetForm));
  });
}

function buildCategoryPickers() {
  const iconPicker = $('#category-icon-picker');
  const colorPicker = $('#category-color-picker');

  iconPicker.innerHTML = categoryIconOptions.map(name => `
    <button class="picker-button" type="button" data-category-icon="${name}" title="${name}">
      ${icon(name)}
    </button>
  `).join('');

  colorPicker.innerHTML = categoryColorOptions.map(color => `
    <button class="color-button" type="button" data-category-color="${color}" title="${color}" style="--swatch:${color}"></button>
  `).join('');

  iconPicker.addEventListener('click', event => {
    const button = event.target.closest('[data-category-icon]');
    if (!button) return;
    setCategoryIcon(button.dataset.categoryIcon);
  });

  colorPicker.addEventListener('click', event => {
    const button = event.target.closest('[data-category-color]');
    if (!button) return;
    setCategoryColor(button.dataset.categoryColor);
  });

  setCategoryIcon($('#category-form input[name="icon"]').value || 'receipt');
  setCategoryColor($('#category-form input[name="color"]').value || '#f97316');
}

function bindFilters() {
  $('#tx-filter-type').addEventListener('change', renderTransactions);
  $('#transaction-form select[name="type"]').addEventListener('change', () => {
    fillTransactionCategorySelect();
  });
  $('#budget-month').addEventListener('change', async () => {
    await loadBudgets();
    await loadReports();
    renderBudgets();
    renderReports();
  });

  $('#global-from').addEventListener('change', reloadReportsOnly);
  $('#global-to').addEventListener('change', reloadReportsOnly);
  $('#global-account-filter').addEventListener('change', () => {
    syncTransactionAccountWithFilter();
    renderDashboard();
    renderTransactions();
  });
  $('#budget-notification-toggle').addEventListener('change', event => {
    budgetNotificationsEnabled = event.currentTarget.checked;
    localStorage.setItem('budget_notifications_enabled', budgetNotificationsEnabled ? 'true' : 'false');
    toast(budgetNotificationsEnabled ? 'เปิดแจ้งเตือนงบประมาณแล้ว' : 'ปิดแจ้งเตือนงบประมาณแล้ว');
    renderSettings();
  });
  $('#settings-notification-button').addEventListener('click', requestNotificationPermission);
}

async function authenticate(path, payload) {
  try {
    const result = await api(path, { method: 'POST', body: payload, auth: false });
    state.token = result.token;
    localStorage.setItem('finance_token', result.token);
    showApp();
    await loadAll();
  } catch (error) {
    $('#auth-message').textContent = error.message;
  }
}

async function loadAll() {
  try {
    state.user = (await api('/me')).data;
    $('#user-email').textContent = state.user.email;
    await Promise.all([loadAccounts(), loadCategories(), loadTransactions(), loadBudgets(), loadRecurring(), loadReports()]);
    renderAll();
  } catch (error) {
    if (error.status === 401) {
      localStorage.removeItem('finance_token');
      showAuth();
      return;
    }
    toast(error.message);
  }
}

async function loadAccounts() {
  state.accounts = (await api('/accounts')).data;
}

async function loadCategories() {
  state.categories = (await api('/categories')).data;
}

async function loadTransactions() {
  const params = new URLSearchParams({
    from: $('#global-from').value,
    to: $('#global-to').value,
    limit: '200',
    offset: '0'
  });
  state.transactions = (await api(`/transactions?${params}`)).data;
}

async function loadBudgets() {
  state.budgets = (await api(`/budgets?month=${encodeURIComponent($('#budget-month').value)}`)).data;
}

async function loadRecurring() {
  state.recurring = (await api('/recurring-transactions')).data;
}

async function loadReports() {
  const range = `from=${encodeURIComponent($('#global-from').value)}&to=${encodeURIComponent($('#global-to').value)}`;
  const month = encodeURIComponent($('#budget-month').value);
  const [summary, breakdown, cashflow, budgetUsage] = await Promise.all([
    api(`/reports/summary?${range}`),
    api(`/reports/category-breakdown?type=expense&${range}`),
    api(`/reports/cashflow?${range}`),
    api(`/reports/budget-usage?month=${month}`)
  ]);
  state.reports.summary = summary.data;
  state.reports.categoryBreakdown = breakdown.data;
  state.reports.cashflow = cashflow.data;
  state.reports.budgetUsage = budgetUsage.data;
}

async function reloadReportsOnly() {
  try {
    await Promise.all([loadTransactions(), loadReports()]);
    renderDashboard();
    renderTransactions();
    renderReports();
  } catch (error) {
    toast(error.message);
  }
}

function renderAll() {
  fillSelects();
  renderDashboard();
  renderAccounts();
  renderCategories();
  renderTransactions();
  renderBudgets();
  renderRecurring();
  renderReports();
  renderSettings();
}

function renderDashboard() {
  const accountId = selectedAccountId();
  const filteredTransactions = accountId
    ? state.transactions.filter(item => Number(item.account_id) === Number(accountId) || Number(item.to_account_id) === Number(accountId))
    : state.transactions;
  const summary = accountId ? summarizeTransactions(filteredTransactions, accountId) : (state.reports.summary || { income: 0, expense: 0, net: 0 });
  $('#metric-income').textContent = money.format(Number(summary.income || 0));
  $('#metric-expense').textContent = money.format(Number(summary.expense || 0));
  $('#metric-net').textContent = money.format(Number(summary.net || 0));
  $('#metric-accounts').textContent = accountId ? accountName(accountId) : String(state.accounts.length);

  const visibleAccounts = accountId ? state.accounts.filter(account => Number(account.id) === Number(accountId)) : state.accounts;
  const maxBalance = Math.max(...visibleAccounts.map(account => Math.abs(Number(account.current_balance || 0))), 1);
  $('#account-balances').innerHTML = visibleAccounts.map(account => barRow(
    account.name,
    `${money.format(Number(account.current_balance || 0))} ${account.currency}`,
    Math.min(100, Math.abs(Number(account.current_balance || 0)) / maxBalance * 100)
  )).join('') || emptyText('ยังไม่มีบัญชี');

  const categoryBreakdown = accountId ? categoryBreakdownFromTransactions(filteredTransactions) : state.reports.categoryBreakdown;
  const maxCategory = Math.max(...categoryBreakdown.map(item => Number(item.total || 0)), 1);
  $('#category-breakdown').innerHTML = categoryBreakdown.map(item => barRow(
    item.name,
    money.format(Number(item.total || 0)),
    Math.min(100, Number(item.total || 0) / maxCategory * 100),
    item.color || '#0f766e'
  )).join('') || emptyText('ยังไม่มีรายจ่ายในช่วงวันที่นี้');

  renderBudgetAlerts();
  renderPremiumCta();
}

function renderPremiumCta() {
  const cta = $('#premium-cta');
  if (!cta || !state.user) {
    return;
  }

  cta.classList.toggle('hidden', state.user.access_tier !== 'free_with_ads');
}

function renderBudgetAlerts() {
  const alerts = state.reports.budgetUsage
    .filter(item => Number(item.used_percent || 0) >= Number(item.alert_percent || 80))
    .sort((a, b) => Number(b.used_percent || 0) - Number(a.used_percent || 0));

  $('#budget-alerts').innerHTML = alerts.map(item => {
    const used = Number(item.used_percent || 0);
    const isOver = used >= 100;
    return `
      <div class="alert-item ${isOver ? 'danger' : ''}">
        <span class="alert-icon">${icon(isOver ? 'target' : 'receipt')}</span>
        <div>
          <strong>${escapeHtml(item.category_name)}</strong>
          <small>${isOver ? 'เกินงบแล้ว' : 'ใกล้ถึงงบที่ตั้งไว้'} ใช้ไป ${money.format(Number(item.spent || 0))} จาก ${money.format(Number(item.budget_amount || 0))}</small>
        </div>
        <span class="alert-percent">${money.format(used)}%</span>
      </div>
    `;
  }).join('') || emptyText('ยังไม่มีงบประมาณที่ต้องเตือนในเดือนนี้');

  notifyBudgetAlerts(alerts);
}

async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    toast('เบราว์เซอร์นี้ยังไม่รองรับ Notification');
    return;
  }

  if (Notification.permission === 'granted') {
    toast('เปิดแจ้งเตือนอยู่แล้ว');
    notifyBudgetAlerts(currentBudgetAlerts(), true);
    renderSettings();
    return;
  }

  const permission = await Notification.requestPermission();

  if (permission === 'granted') {
    toast('เปิดแจ้งเตือนแล้ว');
    notifyBudgetAlerts(currentBudgetAlerts(), true);
  } else {
    toast('ยังไม่ได้อนุญาต Notification');
  }
  renderSettings();
}

function currentBudgetAlerts() {
  return state.reports.budgetUsage
    .filter(item => Number(item.used_percent || 0) >= Number(item.alert_percent || 80))
    .sort((a, b) => Number(b.used_percent || 0) - Number(a.used_percent || 0));
}

function notifyBudgetAlerts(alerts, force = false) {
  updateNotificationButton();
  if (!budgetNotificationsEnabled) {
    return;
  }

  if (!alerts.length) {
    return;
  }

  const key = alerts.map(item => `${item.id}:${item.used_percent}:${item.spent}`).join('|');
  if (!force && key === lastBudgetNotificationKey) {
    updateNotificationButton();
    return;
  }

  lastBudgetNotificationKey = key;
  const overCount = alerts.filter(item => Number(item.used_percent || 0) >= 100).length;
  const title = overCount ? `มี ${overCount} งบที่เกินแล้ว` : `มี ${alerts.length} งบที่ใกล้ถึงกำหนด`;
  const body = alerts
    .slice(0, 3)
    .map(item => `${item.category_name}: ${money.format(Number(item.used_percent || 0))}%`)
    .join(', ');

  toast(`${title}: ${body}`);

  if ('Notification' in window && Notification.permission === 'granted') {
    new Notification(`MyMoney - ${title}`, {
      body,
      tag: `budget-alert-${key}`,
      renotify: false
    });
  }

  updateNotificationButton();
}

function updateNotificationButton() {
  const button = $('#notification-button');
  if (!button || !('Notification' in window)) {
    return;
  }

  const label = button.querySelector('span:last-child');
  if (Notification.permission === 'granted') {
    label.textContent = 'แจ้งเตือนเปิดอยู่';
    button.classList.add('active');
  } else {
    label.textContent = 'เปิดแจ้งเตือน';
    button.classList.remove('active');
  }
}

function renderAccounts() {
  $('#accounts-table').innerHTML = state.accounts.map(account => `
    <tr>
      <td>${escapeHtml(account.name)}</td>
      <td>${escapeHtml(account.currency)}</td>
      <td class="num">${money.format(Number(account.current_balance || 0))}</td>
      <td><div class="row-actions">
        <button class="icon-button" title="แก้ไขบัญชี" onclick="editAccount(${account.id})">${icon('edit')}<span>แก้ไข</span></button>
        <button class="icon-button danger" title="ลบบัญชี" onclick="deleteResource('/accounts/${account.id}', loadAll)">${icon('trash')}<span>ลบ</span></button>
      </div></td>
    </tr>
  `).join('') || tableEmpty(4);
}

function renderCategories() {
  $('#categories-table').innerHTML = state.categories.map(category => `
    <tr>
      <td>${escapeHtml(category.name)}</td>
      <td><span class="pill ${category.type}">${category.type}</span></td>
      <td><span class="category-icon-preview" style="color:${escapeAttr(category.color || '#f97316')}">${icon(category.icon || 'receipt')}</span></td>
      <td><span class="color-chip" style="--swatch:${escapeAttr(category.color || '#f97316')}"></span></td>
      <td><div class="row-actions">
        <button class="icon-button" title="แก้ไขหมวดหมู่" onclick="editCategory(${category.id})">${icon('edit')}<span>แก้ไข</span></button>
        <button class="icon-button danger" title="ลบหมวดหมู่" onclick="deleteResource('/categories/${category.id}', loadAll)">${icon('trash')}<span>ลบ</span></button>
      </div></td>
    </tr>
  `).join('') || tableEmpty(5);
}

function renderTransactions() {
  const type = $('#tx-filter-type').value;
  const accountId = selectedAccountId();
  const rows = state.transactions.filter(item =>
    item.type !== 'transfer'
    && (!type || item.type === type)
    && (!accountId || Number(item.account_id) === Number(accountId))
  );
  $('#transactions-table').innerHTML = rows.map(tx => `
    <tr>
      <td>${escapeHtml(tx.transaction_date)}</td>
      <td><span class="pill ${tx.type}">${tx.type}</span></td>
      <td>${escapeHtml(tx.category_name || '-')}</td>
      <td>${escapeHtml(tx.notes || tx.description || '-')}</td>
      <td class="num">${money.format(Number(tx.amount || 0))}</td>
      <td><div class="row-actions">
        <button class="icon-button" title="แก้ไขรายการ" onclick="editTransaction(${tx.id})">${icon('edit')}<span>แก้ไข</span></button>
        <button class="icon-button danger" title="ลบรายการ" onclick="deleteResource('/transactions/${tx.id}', loadAll)">${icon('trash')}<span>ลบ</span></button>
      </div></td>
    </tr>
  `).join('') || tableEmpty(6);
}

function renderBudgets() {
  $('#budgets-table').innerHTML = state.budgets.map(budget => {
    const spent = Number(budget.spent || 0);
    const amount = Number(budget.amount || 0);
    const remaining = amount - spent;
    const used = Number(budget.used_percent || 0);
    return `
      <tr>
        <td>${escapeHtml(budget.month)}</td>
        <td>${escapeHtml(budget.category_name)}</td>
        <td class="num">${money.format(amount)}</td>
        <td class="num">${money.format(spent)}</td>
        <td class="num">${money.format(remaining)}</td>
        <td><span class="pill ${used >= Number(budget.alert_percent) ? 'warn' : 'income'}">${money.format(used)}%</span></td>
        <td><div class="row-actions">
          <button class="icon-button" title="แก้ไขงบ" onclick="editBudget(${budget.id})">${icon('edit')}<span>แก้ไข</span></button>
          <button class="icon-button danger" title="ลบงบ" onclick="deleteResource('/budgets/${budget.id}', loadAll)">${icon('trash')}<span>ลบ</span></button>
        </div></td>
      </tr>
    `;
  }).join('') || tableEmpty(7);
}

function renderRecurring() {
  $('#recurring-table').innerHTML = state.recurring.map(item => `
    <tr>
      <td>${escapeHtml(item.next_run_date)}</td>
      <td><span class="pill ${item.type}">${item.type}</span></td>
      <td>${escapeHtml(item.account_name || accountName(item.account_id))}</td>
      <td>${escapeHtml(item.description)}</td>
      <td>${escapeHtml(item.frequency)}</td>
      <td class="num">${money.format(Number(item.amount || 0))}</td>
      <td>${Number(item.is_active) ? '<span class="pill income">Active</span>' : '<span class="pill warn">Paused</span>'}</td>
      <td><div class="row-actions">
        <button class="icon-button" title="แก้ไขรายการประจำ" onclick="editRecurring(${item.id})">${icon('edit')}<span>แก้ไข</span></button>
        <button class="icon-button danger" title="ลบรายการประจำ" onclick="deleteResource('/recurring-transactions/${item.id}', loadAll)">${icon('trash')}<span>ลบ</span></button>
      </div></td>
    </tr>
  `).join('') || tableEmpty(8);
}

function renderReports() {
  const maxCash = Math.max(...state.reports.cashflow.map(item => Math.max(Number(item.income || 0), Number(item.expense || 0))), 1);
  $('#cashflow-report').innerHTML = state.reports.cashflow.map(item => `
    ${barRow(`${item.transaction_date} รายรับ`, money.format(Number(item.income || 0)), Math.min(100, Number(item.income || 0) / maxCash * 100), '#15803d')}
    ${barRow(`${item.transaction_date} รายจ่าย`, money.format(Number(item.expense || 0)), Math.min(100, Number(item.expense || 0) / maxCash * 100), '#b91c1c')}
  `).join('') || emptyText('ยังไม่มีข้อมูลกระแสเงินสด');

  $('#budget-report').innerHTML = state.reports.budgetUsage.map(item => barRow(
    item.category_name,
    `${money.format(Number(item.spent || 0))} / ${money.format(Number(item.budget_amount || 0))}`,
    Math.min(100, Number(item.used_percent || 0)),
    Number(item.should_alert) ? '#d97706' : '#0f766e'
  )).join('') || emptyText('ยังไม่มีงบประมาณเดือนนี้');
}

async function saveAccount(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const data = formData(form);
  data.type = 'cash';
  data.opening_balance = 0;
  await saveResource(data.id ? `/accounts/${data.id}` : '/accounts', data.id ? 'PUT' : 'POST', data);
  resetNamedForm('account-form');
  await loadAll();
}

async function saveCategory(event) {
  event.preventDefault();
  const data = formData(event.currentTarget);
  await saveResource(data.id ? `/categories/${data.id}` : '/categories', data.id ? 'PUT' : 'POST', data);
  resetNamedForm('category-form');
  await loadAll();
}

async function saveTransaction(event) {
  event.preventDefault();
  const data = formData(event.currentTarget);
  data.account_id = data.account_id || state.accounts[0]?.id || null;
  data.to_account_id = null;
  data.description = data.notes || '';

  if (!data.account_id) {
    toast('กรุณาสร้างบัญชีก่อนบันทึกรายการเงิน');
    return;
  }

  await saveResource(data.id ? `/transactions/${data.id}` : '/transactions', data.id ? 'PUT' : 'POST', data);
  resetNamedForm('transaction-form');
  await loadAll();
}

async function saveBudget(event) {
  event.preventDefault();
  const data = formData(event.currentTarget);
  await saveResource(data.id ? `/budgets/${data.id}` : '/budgets', data.id ? 'PUT' : 'POST', data);
  resetNamedForm('budget-form');
  await loadAll();
}

async function saveRecurring(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const data = formData(form);
  data.is_active = Boolean(form.elements.is_active.checked);
  await saveResource(data.id ? `/recurring-transactions/${data.id}` : '/recurring-transactions', data.id ? 'PUT' : 'POST', data);
  resetNamedForm('recurring-form');
  await loadAll();
}

async function changePassword(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const data = formData(form);

  if (data.new_password !== data.confirm_password) {
    toast('รหัสผ่านใหม่ไม่ตรงกัน');
    return;
  }

  try {
    await api('/me/password', {
      method: 'PUT',
      body: {
        current_password: data.current_password,
        new_password: data.new_password
      }
    });
    form.reset();
    toast('เปลี่ยนรหัสผ่านสำเร็จ');
  } catch (error) {
    toast(error.message);
  }
}

async function saveResource(path, method, data) {
  try {
    delete data.id;
    await api(path, { method, body: cleanPayload(data) });
    toast('บันทึกสำเร็จ');
  } catch (error) {
    toast(error.message);
    throw error;
  }
}

async function deleteResource(path, callback) {
  if (!confirm('ยืนยันการลบรายการนี้?')) {
    return;
  }

  try {
    await api(path, { method: 'DELETE' });
    toast('ลบสำเร็จ');
    await callback();
  } catch (error) {
    toast(error.message);
  }
}

function editAccount(id) {
  const item = state.accounts.find(account => Number(account.id) === Number(id));
  if (!item) return;
  fillForm('account-form', item);
  openView('accounts');
}

function editCategory(id) {
  const item = state.categories.find(category => Number(category.id) === Number(id));
  if (!item) return;
  fillForm('category-form', item);
  setCategoryIcon(item.icon || 'receipt');
  setCategoryColor(item.color || '#f97316');
  openView('categories');
}

function editTransaction(id) {
  const item = state.transactions.find(tx => Number(tx.id) === Number(id));
  if (!item) return;
  fillForm('transaction-form', item);
  fillTransactionCategorySelect(item.category_id);
  openView('transactions');
}

function editBudget(id) {
  const item = state.budgets.find(budget => Number(budget.id) === Number(id));
  if (!item) return;
  fillForm('budget-form', item);
  openView('budgets');
}

function editRecurring(id) {
  const item = state.recurring.find(recurring => Number(recurring.id) === Number(id));
  if (!item) return;
  fillForm('recurring-form', item);
  $('#recurring-form').elements.is_active.checked = Boolean(Number(item.is_active));
  openView('recurring');
}

function fillSelects() {
  const accountOptions = state.accounts.map(account => `<option value="${account.id}">${escapeHtml(account.name)}</option>`).join('');
  $$('select[name="account_id"], select[name="to_account_id"]').forEach(select => {
    const empty = select.name === 'to_account_id' ? '<option value="">เลือกเมื่อโอนเงิน</option>' : '';
    select.innerHTML = empty + accountOptions;
  });

  const accountFilter = $('#global-account-filter');
  const currentAccount = accountFilter.value;
  accountFilter.innerHTML = '<option value="">ทุกบัญชี</option>' + accountOptions;
  if (currentAccount && state.accounts.some(account => Number(account.id) === Number(currentAccount))) {
    accountFilter.value = currentAccount;
  }
  syncTransactionAccountWithFilter();

  const allCategoryOptions = '<option value="">ไม่ระบุ</option>' + state.categories.map(category => `<option value="${category.id}">${escapeHtml(category.name)} (${category.type})</option>`).join('');
  $$('select[name="category_id"]').forEach(select => {
    select.innerHTML = allCategoryOptions;
  });

  fillTransactionCategorySelect();

  const expenseOptions = state.categories
    .filter(category => category.type === 'expense')
    .map(category => `<option value="${category.id}">${escapeHtml(category.name)}</option>`)
    .join('');
  $('#budget-form select[name="category_id"]').innerHTML = expenseOptions;
}

function fillTransactionCategorySelect(selectedId = null) {
  const form = $('#transaction-form');
  const select = form.querySelector('select[name="category_id"]');
  const type = form.querySelector('select[name="type"]').value || 'expense';
  const options = state.categories
    .filter(category => category.type === type)
    .map(category => `<option value="${category.id}">${escapeHtml(category.name)}</option>`)
    .join('');

  select.innerHTML = options || '<option value="">ยังไม่มีหมวดหมู่</option>';

  if (selectedId && state.categories.some(category => Number(category.id) === Number(selectedId) && category.type === type)) {
    select.value = selectedId;
  }
}

async function api(path, options = {}) {
  const headers = { Accept: 'application/json' };
  const auth = options.auth !== false;

  if (options.body !== undefined) {
    headers['Content-Type'] = 'application/json';
  }

  if (auth && state.token) {
    headers.Authorization = `Bearer ${state.token}`;
  }

  const response = await fetch(path, {
    method: options.method || 'GET',
    headers,
    body: options.body !== undefined ? JSON.stringify(options.body) : undefined
  });

  const text = await response.text();
  const json = text ? JSON.parse(text) : {};

  if (!response.ok) {
    const error = new Error(json.message || 'Request failed');
    error.status = response.status;
    throw error;
  }

  return json;
}

function formData(form) {
  return Object.fromEntries(new FormData(form).entries());
}

function cleanPayload(payload) {
  return Object.fromEntries(Object.entries(payload).map(([key, value]) => {
    if (value === '') return [key, null];
    if (['amount', 'opening_balance'].includes(key) && value !== null) return [key, Number(value)];
    if (['account_id', 'to_account_id', 'category_id', 'alert_percent'].includes(key) && value !== null) return [key, Number(value)];
    return [key, value];
  }));
}

function fillForm(formId, data) {
  const form = $(`#${formId}`);
  Object.entries(data).forEach(([key, value]) => {
    const field = form.elements[key];
    if (!field || field.type === 'checkbox') return;
    field.value = value ?? '';
  });
}

function resetNamedForm(formId) {
  const form = $(`#${formId}`);
  form.reset();
  form.elements.id.value = '';
  setDefaultDates();
  fillSelects();

  if (formId === 'category-form') {
    setCategoryIcon('receipt');
    setCategoryColor('#f97316');
  }
}

function setCategoryIcon(value) {
  $('#category-form input[name="icon"]').value = value;
  $$('[data-category-icon]').forEach(button => {
    button.classList.toggle('active', button.dataset.categoryIcon === value);
  });
}

function setCategoryColor(value) {
  $('#category-form input[name="color"]').value = value;
  $$('[data-category-color]').forEach(button => {
    button.classList.toggle('active', button.dataset.categoryColor.toLowerCase() === value.toLowerCase());
  });
}

function showAuth() {
  $('#auth-view').classList.remove('hidden');
  $('#app-view').classList.add('hidden');
}

function showApp() {
  $('#auth-view').classList.add('hidden');
  $('#app-view').classList.remove('hidden');
}

function renderSettings() {
  if (!state.user) {
    return;
  }

  $('#settings-name').textContent = state.user.name || '-';
  $('#settings-email').textContent = state.user.email || '-';
  $('#settings-plan').textContent = planLabel(state.user.access_tier);
  $('#settings-trial').textContent = trialLabel();
  $('#budget-notification-toggle').checked = budgetNotificationsEnabled;
  $('#notification-status').textContent = notificationStatusText();
  updateNotificationButton();
}

function planLabel(tier) {
  if (tier === 'premium') {
    return 'Premium รายปี';
  }

  if (tier === 'trial') {
    return 'ทดลองใช้ฟรี';
  }

  return 'ฟรีพร้อมโฆษณา';
}

function trialLabel() {
  if (!state.user) {
    return '-';
  }

  if (state.user.access_tier === 'premium') {
    return 'ไม่จำกัดระหว่าง Premium';
  }

  const remaining = Number(state.user.trial_days_remaining || 0);
  return remaining > 0 ? `เหลือ ${remaining} วัน` : 'ครบ 7 วันแล้ว';
}

function notificationStatusText() {
  if (!('Notification' in window)) {
    return 'ไม่รองรับ';
  }

  if (Notification.permission === 'granted') {
    return 'อนุญาตแล้ว';
  }

  if (Notification.permission === 'denied') {
    return 'ถูกปิดไว้';
  }

  return 'ยังไม่ได้ตั้งค่า';
}

function openView(view) {
  navigateTo(view);
}

function accountName(id) {
  return state.accounts.find(account => Number(account.id) === Number(id))?.name || '-';
}

function selectedAccountId() {
  return $('#global-account-filter')?.value || '';
}

function syncTransactionAccountWithFilter() {
  const select = $('#transaction-form select[name="account_id"]');
  if (!select) {
    return;
  }

  const accountId = selectedAccountId();
  if (accountId) {
    select.value = accountId;
    return;
  }

  if (!select.value && state.accounts[0]) {
    select.value = state.accounts[0].id;
  }
}

function summarizeTransactions(transactions, accountId = '') {
  return transactions.reduce((summary, item) => {
    const amount = Number(item.amount || 0);

    if (item.type === 'income') {
      summary.income += amount;
      summary.net += amount;
    }

    if (item.type === 'expense') {
      summary.expense += amount;
      summary.net -= amount;
    }

    if (item.type === 'transfer' && accountId) {
      if (Number(item.account_id) === Number(accountId)) {
        summary.net -= amount;
      }
      if (Number(item.to_account_id) === Number(accountId)) {
        summary.net += amount;
      }
    }

    return summary;
  }, { income: 0, expense: 0, net: 0 });
}

function categoryBreakdownFromTransactions(transactions) {
  const totals = new Map();

  transactions
    .filter(item => item.type === 'expense')
    .forEach(item => {
      const key = item.category_id || 'none';
      const existing = totals.get(key) || {
        name: item.category_name || 'ไม่ระบุ',
        color: state.categories.find(category => Number(category.id) === Number(item.category_id))?.color || '#f97316',
        total: 0
      };
      existing.total += Number(item.amount || 0);
      totals.set(key, existing);
    });

  return Array.from(totals.values()).sort((a, b) => Number(b.total) - Number(a.total));
}

function barRow(label, value, percent, color = '#0f766e') {
  return `
    <div class="bar-row">
      <div class="bar-meta"><span>${escapeHtml(label)}</span><strong>${escapeHtml(value)}</strong></div>
      <div class="bar-track"><div class="bar-fill" style="--w:${Math.max(0, percent)}%;background:${escapeAttr(color)}"></div></div>
    </div>
  `;
}

function emptyText(text) {
  return `<p class="muted">${escapeHtml(text)}</p>`;
}

function tableEmpty(columns) {
  return `<tr><td colspan="${columns}" class="muted">ยังไม่มีข้อมูล</td></tr>`;
}

function toast(message) {
  const element = $('#toast');
  element.textContent = message;
  element.classList.remove('hidden');
  window.clearTimeout(toast.timer);
  toast.timer = window.setTimeout(() => element.classList.add('hidden'), 2600);
}

function formatDate(date) {
  return date.toISOString().slice(0, 10);
}

function formatMonth(date) {
  return date.toISOString().slice(0, 7);
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, char => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  })[char]);
}

function escapeAttr(value) {
  return String(value ?? '').replace(/[^#a-zA-Z0-9(),.% -]/g, '');
}

window.editAccount = editAccount;
window.editCategory = editCategory;
window.editTransaction = editTransaction;
window.editBudget = editBudget;
window.editRecurring = editRecurring;
window.deleteResource = deleteResource;
