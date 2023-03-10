# authonia

2FA-TOTP Generation Cloud Platform

## Table of Contents

- [authonia](#authonia)
  - [Table of Contents](#table-of-contents)
  - [What is this?](#what-is-this)
  - [Techstack used](#techstack-used)
  - [How to use](#how-to-use)
    - [Deployment in use](#deployment-in-use)
      - [Application Download](#application-download)
    - [Using your own deployment](#using-your-own-deployment)
  - [License \& Copyright](#license--copyright)

---

## What is this?

This is a cloud platform for generating 2FA-TOTP tokens. It is a web application that allows you to generate 2FA-TOTP tokens for your accounts. It is a cloud platform, which means that you can use it from anywhere, as long as you have an internet connection.

This app can also be installed as a Progressive Web App (PWA) to work offline.

---

## Techstack used

- Frontend : Flutter
- Backend
  - Database : MongoDB
  - Framework : FastAPI

---

## How to use

### Deployment in use

- Navigate to [authonia.vercel.app](https://authonia.vercel.app) and register yourself.

#### Application Download

Navigate to [/frontend/README.md](./frontend/README.md#download) for more information.

### Using your own deployment

- Create a MongoDB Database `authonia` and add two collections `users` and `auth`.
- Deploy the [backend](./backend/) folder with an environment variable `MONGO_URI` with the value `mongodb://<username>:<password>@<host>:<port>/authonia`.
- Now, deploy the [frontend](./frontend/) folder with an environment variable `API_URL` with the value of your backend server deployment URL.
- Your deployment is now ready to use!

---

## License & Copyright

- This Project is [Apache-2.0](./LICENSE) Licensed
- Copyright 2023 [Vishal Das](https://github.com/dvishal485)

---
