# 🧾 QuickBill – Smart Mobile Invoicing App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)

**QuickBill** is a comprehensive Android mobile application designed to streamline invoicing workflows for small businesses. It bridges the gap between complex accounting software and manual paperwork by providing a secure, responsive, and easy-to-use mobile interface for generating GST-compliant invoices on the go.

---

## 🚀 Key Features

* **📄 GST-Compliant Invoicing:** Generate professional invoices adhering to tax regulations.
* **⬇️ Instant PDF Downloads:** Create and download invoices instantly for sharing with clients.
* **👥 Client Management:** Add, edit, and manage client records and business details.
* **💰 Payment Tracking:** Monitor payment statuses (Paid/Unpaid/Partial) to keep cash flow organized.
* **🔒 Secure Data Handling:** All data is stored securely in MongoDB and accessed via a custom RESTful API.
* **✨ Modern UI/UX:** Built with Flutter, featuring smooth animations and a responsive design optimized for mobile devices.

---

## 🎯 Target Audience

QuickBill is a personalized solution tailored for:
* **Business Owners:** To maintain oversight of daily transactions.
* **Business Managers:** To execute billing operations efficiently.
* **Authorized Personnel:** Staff members with specific access to generate bills and manage client data.

---

## 🛠️ Tech Stack

### Client-Side (Mobile App)
* **Framework:** Flutter (Android)
* **Language:** Dart
* **State Management:** GetX
* **PDF Generation:** `pdf` & `printing` packages

### Server-Side (Backend)
* **Runtime:** Node.js
* **Framework:** Express.js (REST API)
* **Database:** MongoDB (NoSQL)

---

## 📱 Screenshots

| Dashboard | Create Invoice | PDF Preview | Client List |
|:---:|:---:|:---:|:---:|
| <img src="assets/dashboard.png" width="200"> | <img src="assets/create_invoice.png" width="200"> | <img src="assets/pdf_preview.png" width="200"> | <img src="assets/clients.png" width="200"> |


---

## ⚙️ Installation & Setup

Follow these steps to run the project locally.

### Prerequisites
* Flutter SDK installed
* Node.js & npm installed
* MongoDB installed locally or a MongoDB Atlas connection string
