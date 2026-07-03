<?php

declare(strict_types=1);
?>
<!doctype html>
<html lang="th">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MY Money</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Prompt:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/assets/app.css">
</head>
<body>
  <div id="auth-view" class="auth-shell">
    <section class="auth-panel">
      <div>
        <p class="eyebrow">MY Money</p>
        <h1>จัดการเงินส่วนตัวครบในที่เดียว</h1>
        <p class="muted">บันทึกรายรับรายจ่าย บัญชี งบประมาณ รายการประจำ และรายงานสำหรับต่อยอดเป็นผลิตภัณฑ์จริง</p>
      </div>
      <div class="auth-card">
        <div class="auth-tabs">
          <button class="tab active" data-auth-tab="login">เข้าสู่ระบบ</button>
          <button class="tab" data-auth-tab="register">สมัครสมาชิก</button>
        </div>
        <form id="login-form" class="stack">
          <label>อีเมล<input name="email" type="email" value="demo@example.com" required></label>
          <label>รหัสผ่าน<input name="password" type="password" value="password123" required></label>
          <button class="primary" type="submit">เข้าสู่ระบบ</button>
        </form>
        <form id="register-form" class="stack hidden">
          <label>ชื่อ<input name="name" value="Demo User" required></label>
          <label>อีเมล<input name="email" type="email" value="demo@example.com" required></label>
          <label>รหัสผ่าน<input name="password" type="password" value="password123" minlength="8" required></label>
          <button class="primary" type="submit">สร้างบัญชี</button>
        </form>
        <p id="auth-message" class="message"></p>
      </div>
    </section>
  </div>

  <div id="app-view" class="app-shell hidden">
    <aside class="sidebar">
      <div class="brand">
        <span class="mark" aria-hidden="true">
          <svg viewBox="0 0 32 32" role="img">
            <path class="mark-wallet" d="M7 9.2h15.4c2.4 0 4.4 2 4.4 4.4v8.2c0 2.4-2 4.4-4.4 4.4H7.8A4.8 4.8 0 0 1 3 21.4V10.8C3 8.1 5.1 6 7.8 6h13.4c1.1 0 2 .9 2 2v1.2H7Z"/>
            <path class="mark-pocket" d="M20.5 14h7.2v7.4h-7.2a3.7 3.7 0 0 1 0-7.4Z"/>
            <circle class="mark-dot" cx="21.1" cy="17.7" r="1.25"/>
            <path class="mark-spark" d="M10.6 11.6 12 15l3.4 1.4L12 17.8l-1.4 3.4-1.4-3.4-3.4-1.4L9.2 15l1.4-3.4Z"/>
          </svg>
        </span>
        <div>
          <strong>MY Money</strong>
          <small id="user-email">พร้อมใช้งาน</small>
        </div>
      </div>
      <button id="menu-button" class="menu-button" type="button" aria-label="เปิดเมนู" aria-expanded="false">
        <span class="icon" data-icon="menu"></span>
      </button>
      <nav>
        <button class="nav active" data-view="dashboard"><span class="icon" data-icon="dashboard"></span><span>ภาพรวม</span></button>
        <button class="nav" data-view="transactions"><span class="icon" data-icon="receipt"></span><span>รายการเงิน</span></button>
        <button class="nav" data-view="accounts"><span class="icon" data-icon="wallet"></span><span>บัญชี</span></button>
        <button class="nav" data-view="categories"><span class="icon" data-icon="tags"></span><span>หมวดหมู่</span></button>
        <button class="nav" data-view="budgets"><span class="icon" data-icon="target"></span><span>งบประมาณ</span></button>
        <button class="nav" data-view="recurring"><span class="icon" data-icon="repeat"></span><span>รายการประจำ</span></button>
        <button class="nav" data-view="reports"><span class="icon" data-icon="chart"></span><span>รายงาน</span></button>
        <button class="nav" data-view="settings"><span class="icon" data-icon="settings"></span><span>ตั้งค่า</span></button>
      </nav>
      <button id="logout-button" class="ghost"><span class="icon" data-icon="logout"></span><span>ออกจากระบบ</span></button>
    </aside>
    <div id="menu-backdrop" class="menu-backdrop"></div>

    <section id="ad-interstitial" class="ad-interstitial hidden" aria-live="polite">
      <div class="ad-card">
        <p class="eyebrow">MY Money Free</p>
        <h2>สนับสนุนการใช้งานฟรี</h2>
        <p class="muted">บัญชีฟรีหลังครบ 7 วันจะมีโฆษณาคั่นก่อนเปิดเมนูถัดไป รุ่น Premium จะไม่มีโฆษณาคั่น</p>
        <div class="ad-placeholder">
          <span>พื้นที่โฆษณา</span>
          <strong id="ad-countdown">15</strong>
        </div>
        <button id="ad-continue-button" class="primary" type="button" disabled><span class="icon" data-icon="check"></span><span>ไปต่อ</span></button>
        <button class="secondary" data-open-premium type="button"><span class="icon" data-icon="sparkles"></span><span>สมัคร Premium เพื่อไม่มีโฆษณา</span></button>
      </div>
    </section>

    <section id="premium-modal" class="premium-modal hidden" aria-live="polite">
      <div class="premium-card">
        <button id="premium-close-button" class="premium-close" type="button" aria-label="ปิด">×</button>
        <p class="eyebrow">MY Money Premium</p>
        <h2>ใช้งานลื่น ไม่มีโฆษณาคั่น</h2>
        <p class="muted">เหมาะสำหรับคนที่บันทึกรายรับรายจ่ายจริงจังและอยากใช้แอปต่อเนื่องแบบไม่สะดุด</p>
        <div class="premium-price">
          <strong>฿399</strong>
          <span>/ ปี</span>
        </div>
        <div class="premium-benefits">
          <div><span class="icon" data-icon="check"></span> ไม่มีโฆษณาคั่นทุกเมนู</div>
          <div><span class="icon" data-icon="check"></span> ใช้งานรายงานและงบประมาณได้ต่อเนื่อง</div>
          <div><span class="icon" data-icon="check"></span> เหมาะสำหรับใช้งานระยะยาว</div>
        </div>
        <button id="payment-button" class="primary" type="button"><span class="icon" data-icon="wallet"></span><span>ไปหน้าชำระเงิน</span></button>
        <p class="premium-note">หน้าชำระเงินจริงจะเชื่อมต่อ payment gateway ในขั้นถัดไป</p>
      </div>
    </section>

    <main class="main">
      <header class="topbar">
        <div>
          <h2 id="view-title">Dashboard</h2>
        </div>
        <div class="top-actions">
          <select id="global-account-filter">
            <option value="">ทุกบัญชี</option>
          </select>
          <input id="global-from" type="date">
          <input id="global-to" type="date">
          <button id="refresh-button" class="secondary icon-only" title="รีเฟรชข้อมูล" aria-label="รีเฟรชข้อมูล"><span class="icon" data-icon="check"></span></button>
        </div>
      </header>

      <section id="dashboard" class="view active">
        <section id="premium-cta" class="premium-cta hidden">
          <div>
            <strong>ใช้งานฟรีพร้อมโฆษณา</strong>
            <span>อัปเกรด Premium เพื่อใช้งานทุกเมนูแบบไม่ต้องรอ 15 วินาที</span>
          </div>
          <button class="primary" data-open-premium type="button"><span class="icon" data-icon="sparkles"></span><span>ดูแพ็กเกจ</span></button>
        </section>
        <div class="metrics">
          <div class="metric"><span>รายรับ</span><strong id="metric-income">0.00</strong></div>
          <div class="metric"><span>รายจ่าย</span><strong id="metric-expense">0.00</strong></div>
          <div class="metric"><span>คงเหลือสุทธิ</span><strong id="metric-net">0.00</strong></div>
          <div class="metric"><span>จำนวนบัญชี</span><strong id="metric-accounts">0</strong></div>
        </div>
        <div class="grid two">
          <section class="panel">
            <div class="panel-head"><h3>ยอดเงินตามบัญชี</h3></div>
            <div id="account-balances" class="bars"></div>
          </section>
          <section class="panel">
            <div class="panel-head"><h3>รายจ่ายตามหมวดหมู่</h3></div>
            <div id="category-breakdown" class="bars"></div>
          </section>
        </div>
        <section class="panel">
          <div class="panel-head"><h3>แจ้งเตือนงบประมาณ</h3></div>
          <div id="budget-alerts" class="alert-list"></div>
        </section>
      </section>

      <section id="transactions" class="view">
        <section class="panel">
          <div class="panel-head">
            <h3>รายการเงิน</h3>
            <div class="filters">
              <select id="tx-filter-type"><option value="">ทุกประเภท</option><option value="income">รายรับ</option><option value="expense">รายจ่าย</option></select>
              <button class="secondary" data-reset-form="transaction-form" type="button"><span class="icon" data-icon="eraser"></span><span>ล้างฟอร์ม</span></button>
            </div>
          </div>
          <form id="transaction-form" class="form-grid">
            <input type="hidden" name="id">
            <label>ประเภท<select name="type" required><option value="expense">รายจ่าย</option><option value="income">รายรับ</option></select></label>
            <label>บัญชี<select name="account_id" required></select></label>
            <label>หมวดหมู่<select name="category_id" required></select></label>
            <label>วันที่<input name="transaction_date" type="date" required></label>
            <label>จำนวนเงิน<input name="amount" type="number" step="0.01" min="0.01" required></label>
            <label class="wide">บันทึกเพิ่มเติม<textarea name="notes" rows="3" placeholder="เช่น กินข้าวกลางวันกับทีม"></textarea></label>
            <button class="primary" type="submit"><span class="icon" data-icon="save"></span><span>บันทึกรายการ</span></button>
          </form>
          <div class="table-wrap"><table><thead><tr><th>วันที่</th><th>ประเภท</th><th>หมวดหมู่</th><th>บันทึกเพิ่มเติม</th><th class="num">จำนวน</th><th></th></tr></thead><tbody id="transactions-table"></tbody></table></div>
        </section>
      </section>

      <section id="accounts" class="view">
        <section class="panel">
          <div class="panel-head"><h3>บัญชีการเงิน</h3><button class="secondary" data-reset-form="account-form" type="button"><span class="icon" data-icon="eraser"></span><span>ล้างฟอร์ม</span></button></div>
          <form id="account-form" class="form-grid">
            <input type="hidden" name="id">
            <label>ชื่อบัญชี<input name="name" required></label>
            <label>สกุลเงิน<input name="currency" value="THB" maxlength="3"></label>
            <button class="primary" type="submit"><span class="icon" data-icon="save"></span><span>บันทึกบัญชี</span></button>
          </form>
          <div class="table-wrap"><table><thead><tr><th>ชื่อ</th><th>สกุลเงิน</th><th class="num">ยอดปัจจุบัน</th><th></th></tr></thead><tbody id="accounts-table"></tbody></table></div>
        </section>
      </section>

      <section id="categories" class="view">
        <section class="panel">
          <div class="panel-head"><h3>หมวดหมู่</h3><button class="secondary" data-reset-form="category-form" type="button"><span class="icon" data-icon="eraser"></span><span>ล้างฟอร์ม</span></button></div>
          <form id="category-form" class="form-grid">
            <input type="hidden" name="id">
            <label>ชื่อหมวดหมู่<input name="name" required></label>
            <label>ประเภท<select name="type"><option value="expense">รายจ่าย</option><option value="income">รายรับ</option></select></label>
            <input type="hidden" name="icon" value="receipt">
            <input type="hidden" name="color" value="#f97316">
            <div class="picker-field wide">
              <span>เลือกไอคอน</span>
              <div id="category-icon-picker" class="icon-picker"></div>
            </div>
            <div class="picker-field wide">
              <span>เลือกสี</span>
              <div id="category-color-picker" class="color-picker"></div>
            </div>
            <button class="primary" type="submit"><span class="icon" data-icon="save"></span><span>บันทึกหมวดหมู่</span></button>
          </form>
          <div class="table-wrap"><table><thead><tr><th>ชื่อ</th><th>ประเภท</th><th>ไอคอน</th><th>สี</th><th></th></tr></thead><tbody id="categories-table"></tbody></table></div>
        </section>
      </section>

      <section id="budgets" class="view">
        <section class="panel">
          <div class="panel-head"><h3>งบประมาณ</h3><input id="budget-month" type="month"></div>
          <form id="budget-form" class="form-grid">
            <input type="hidden" name="id">
            <label>หมวดหมู่รายจ่าย<select name="category_id" required></select></label>
            <label>เดือน<input name="month" type="month" required></label>
            <label>งบประมาณ<input name="amount" type="number" step="0.01" min="0.01" required></label>
            <label>แจ้งเตือนที่ %<input name="alert_percent" type="number" min="1" max="100" value="80"></label>
            <button class="primary" type="submit"><span class="icon" data-icon="save"></span><span>บันทึกงบ</span></button>
          </form>
          <div class="table-wrap"><table><thead><tr><th>เดือน</th><th>หมวดหมู่</th><th class="num">งบ</th><th class="num">ใช้แล้ว</th><th class="num">คงเหลือ</th><th>สถานะ</th><th></th></tr></thead><tbody id="budgets-table"></tbody></table></div>
        </section>
      </section>

      <section id="recurring" class="view">
        <section class="panel">
          <div class="panel-head"><h3>รายการประจำ</h3><button class="secondary" data-reset-form="recurring-form" type="button"><span class="icon" data-icon="eraser"></span><span>ล้างฟอร์ม</span></button></div>
          <form id="recurring-form" class="form-grid">
            <input type="hidden" name="id">
            <label>ประเภท<select name="type"><option value="income">รายรับ</option><option value="expense">รายจ่าย</option></select></label>
            <label>บัญชี<select name="account_id" required></select></label>
            <label>หมวดหมู่<select name="category_id"></select></label>
            <label>จำนวนเงิน<input name="amount" type="number" step="0.01" min="0.01" required></label>
            <label>ความถี่<select name="frequency"><option value="daily">รายวัน</option><option value="weekly">รายสัปดาห์</option><option value="monthly">รายเดือน</option><option value="yearly">รายปี</option></select></label>
            <label>รอบถัดไป<input name="next_run_date" type="date" required></label>
            <label class="wide">คำอธิบาย<input name="description" required></label>
            <label class="check"><input name="is_active" type="checkbox" checked> เปิดใช้งาน</label>
            <button class="primary" type="submit"><span class="icon" data-icon="save"></span><span>บันทึกรายการประจำ</span></button>
          </form>
          <div class="table-wrap"><table><thead><tr><th>รอบถัดไป</th><th>ประเภท</th><th>บัญชี</th><th>คำอธิบาย</th><th>ความถี่</th><th class="num">จำนวน</th><th>สถานะ</th><th></th></tr></thead><tbody id="recurring-table"></tbody></table></div>
        </section>
      </section>

      <section id="reports" class="view">
        <div class="grid two">
          <section class="panel"><div class="panel-head"><h3>กระแสเงินสด</h3></div><div id="cashflow-report" class="bars"></div></section>
          <section class="panel"><div class="panel-head"><h3>การใช้งบประมาณ</h3></div><div id="budget-report" class="bars"></div></section>
        </div>
      </section>

      <section id="settings" class="view">
        <div class="settings-grid">
          <section class="panel">
            <div class="panel-head"><h3>โปรไฟล์</h3></div>
            <div class="settings-list">
              <div class="setting-row">
                <span>ชื่อ</span>
                <strong id="settings-name">-</strong>
              </div>
              <div class="setting-row">
                <span>อีเมล</span>
                <strong id="settings-email">-</strong>
              </div>
              <div class="setting-row">
                <span>แพ็กเกจ</span>
                <strong id="settings-plan">-</strong>
              </div>
              <div class="setting-row">
                <span>ช่วงทดลอง</span>
                <strong id="settings-trial">-</strong>
              </div>
              <button class="primary" data-open-premium type="button"><span class="icon" data-icon="sparkles"></span><span>สมัคร Premium</span></button>
            </div>
          </section>

          <section class="panel">
            <div class="panel-head"><h3>แจ้งเตือน</h3></div>
            <div class="settings-list">
              <label class="setting-toggle">
                <input id="budget-notification-toggle" type="checkbox">
                <span>
                  <strong>แจ้งเตือนงบประมาณ</strong>
                  <small>แสดง toast และ browser notification เมื่อใกล้ถึงหรือเกินงบ</small>
                </span>
              </label>
              <div class="setting-row">
                <span>สถานะ Browser Notification</span>
                <strong id="notification-status">-</strong>
              </div>
              <button id="settings-notification-button" class="secondary" type="button"><span class="icon" data-icon="bell"></span><span>ขอสิทธิ์แจ้งเตือน</span></button>
            </div>
          </section>

          <section class="panel">
            <div class="panel-head"><h3>เปลี่ยนรหัสผ่าน</h3></div>
            <form id="password-form" class="settings-form">
              <label>รหัสผ่านปัจจุบัน<input name="current_password" type="password" required></label>
              <label>รหัสผ่านใหม่<input name="new_password" type="password" minlength="8" required></label>
              <label>ยืนยันรหัสผ่านใหม่<input name="confirm_password" type="password" minlength="8" required></label>
              <button class="primary" type="submit"><span class="icon" data-icon="save"></span><span>เปลี่ยนรหัสผ่าน</span></button>
            </form>
          </section>
        </div>
      </section>

      <p id="toast" class="toast hidden"></p>
    </main>
  </div>

  <script src="/assets/app.js"></script>
</body>
</html>
