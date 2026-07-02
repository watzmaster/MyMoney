# MyMoney API

ระบบ API สำหรับบันทึกรายรับรายจ่าย รันด้วย Docker, PHP 8.3 และ MySQL 8.4

## Features

- สมัครสมาชิก / เข้าสู่ระบบด้วย Bearer token
- บัญชีการเงินหลายประเภท เช่น เงินสด ธนาคาร บัตรเครดิต e-wallet
- หมวดหมู่รายรับรายจ่าย พร้อม icon และสี
- ธุรกรรมรายรับ รายจ่าย และโอนเงินระหว่างบัญชี
- งบประมาณรายเดือนต่อหมวดหมู่ พร้อมเปอร์เซ็นต์แจ้งเตือน
- รายการประจำ เช่น เงินเดือน ค่าเช่า ค่าสมาชิก
- รายงานสรุปรายรับรายจ่าย กระแสเงินสด หมวดหมู่ และการใช้งบ
- แยกข้อมูลตามผู้ใช้ เหมาะสำหรับต่อยอดเป็น SaaS หรือ mobile app backend

## Run

```bash
docker compose up --build
```

API จะอยู่ที่:

```text
http://localhost:8080
```

เว็บแอปจะอยู่ที่:

```text
http://localhost:8080
```

phpMyAdmin จะอยู่ที่:

```text
http://localhost:8081
```

ตรวจสุขภาพระบบ:

```bash
curl http://localhost:8080/health
```

## Quick Start

สมัครสมาชิก:

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Demo User\",\"email\":\"demo@example.com\",\"password\":\"password123\"}"
```

เข้าสู่ระบบ:

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"demo@example.com\",\"password\":\"password123\"}"
```

นำ token ที่ได้ไปใช้:

```bash
TOKEN=your-token-here
```

ดูบัญชี:

```bash
curl http://localhost:8080/accounts \
  -H "Authorization: Bearer $TOKEN"
```

เพิ่มรายจ่าย:

```bash
curl -X POST http://localhost:8080/transactions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"account_id\":1,\"category_id\":3,\"type\":\"expense\",\"amount\":120,\"transaction_date\":\"2026-06-26\",\"description\":\"Lunch\"}"
```

ดูรายงานสรุปรายเดือน:

```bash
curl "http://localhost:8080/reports/summary?from=2026-06-01&to=2026-06-30" \
  -H "Authorization: Bearer $TOKEN"
```

## Endpoints

### Auth

- `POST /auth/register`
- `POST /auth/login`
- `GET /me`

### Accounts

- `GET /accounts`
- `POST /accounts`
- `PUT /accounts/{id}`
- `DELETE /accounts/{id}`

### Categories

- `GET /categories`
- `GET /categories?type=expense`
- `POST /categories`
- `PUT /categories/{id}`
- `DELETE /categories/{id}`

### Transactions

- `GET /transactions`
- `GET /transactions?type=expense&from=2026-06-01&to=2026-06-30`
- `POST /transactions`
- `GET /transactions/{id}`
- `PUT /transactions/{id}`
- `DELETE /transactions/{id}`

### Budgets

- `GET /budgets?month=2026-06`
- `POST /budgets`
- `PUT /budgets/{id}`
- `DELETE /budgets/{id}`

### Recurring Transactions

- `GET /recurring-transactions`
- `POST /recurring-transactions`
- `PUT /recurring-transactions/{id}`
- `DELETE /recurring-transactions/{id}`

### Reports

- `GET /reports/summary?from=2026-06-01&to=2026-06-30`
- `GET /reports/cashflow?from=2026-06-01&to=2026-06-30`
- `GET /reports/category-breakdown?type=expense&from=2026-06-01&to=2026-06-30`
- `GET /reports/budget-usage?month=2026-06`

## Production Checklist

- เปลี่ยน `APP_SECRET`
- ใช้ HTTPS
- จำกัด CORS ให้ตรง domain จริง
- เพิ่ม rate limit
- เพิ่ม refresh token หรือ session revocation
- เพิ่ม test suite และ CI
- เพิ่ม migration tool เมื่อระบบเริ่มมีหลายเวอร์ชัน
