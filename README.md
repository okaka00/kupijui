# Roast & Ritual — Coffee Shop Loyalty MVP

A responsive, GitHub-ready **React + Vite + Tailwind CSS** membership demo for one coffee shop. Netlify-ready. Supabase Google sign-in and private member read access are optional.

## What works immediately (local demo)

- Customer dashboard and unique demo QR membership card
- Three switchable demo users
- Cashier point-awarding flow: **RM1 = 1 point**, rounded down
- Receipt-reference duplicate prevention (demo only)
- Cashier reward redemption and insufficient-balance validation
- Transaction history, member list and simple admin overview
- Browser `localStorage` persistence and **Reset demo** control
- Mobile-friendly layout and navigation

**Demo mode is a UI prototype, NOT a secure point of sale or production loyalty ledger.** A visitor can impersonate any demo role; anyone can edit localStorage; point operations are not server-validated. Do not use it to process real purchases or rewards.

## Run on your laptop

Requirements: Node.js 20+ and npm (or pnpm).

```bash
npm install
npm run dev
```

Open the address printed by Vite (usually `http://localhost:5173`). No `.env` required for demo mode.

Build production files:

```bash
npm run build
npm run preview
```

If you use pnpm, use `pnpm install`, `pnpm dev`, and `pnpm build`.

## Upload to GitHub

Create a **new empty repo** at github.com, then run inside the extracted folder:

```bash
git init
git add .
git commit -m "Initial coffee loyalty MVP demo"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/coffee-loyalty-mvp.git
git push -u origin main
```

GitHub hosts your **code**, not a live React app automatically. To preview publicly, use Netlify connected to the GitHub repository, or a GitHub Pages workflow with a correct Vite base path.

## Deploy frontend on Netlify

1. Add the GitHub repository in Netlify > Add new project > Import from Git.
2. Build command: `npm run build`; publish directory: `dist`.
3. The included `netlify.toml` handles single-page app routes.
4. Deploy, then add your custom domain in Netlify's **Domain management**.
5. Demo mode needs no environment variables and will run on Netlify; each browser has its own independent local data.

## Optional: Connect Google sign-in and live customer membership reads

**This is intentionally a staged integration**. It enables Google sign-in and reading one's own membership and transaction rows but **does not** enable real cashier/admin writes. When Supabase credentials are present, the app runs in read-only connected mode; the staff simulator displays a safety message and disables award/redeem.

1. Create a Supabase project.
2. Run `supabase/migrations/001_membership_readonly.sql` in Supabase SQL Editor on a **new project**. Review it first; it creates auth-user signup triggers and RLS policies.
3. Supabase > Authentication > Providers > Google: configure a Google OAuth Client ID and secret. Set the callback URI required by Supabase in Google Cloud Console.
4. Supabase > Authentication > URL Configuration: set **Site URL** to your Netlify/custom-domain URL. Allow `https://YOUR_DOMAIN/member` (and `http://localhost:5173/member` for development) under additional redirect URLs.
5. Create `.env.local` from `.env.example` and set:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

6. In Netlify, add the same variables in **Site configuration > Environment variables**, and redeploy.
7. Sign in with Google. The signup trigger provisions a profile and membership. Signed-in customers can read their own record through RLS.

**Never put service-role/secret keys, Google OAuth secrets, or administrative tokens in `VITE_` variables or Git.** Do not publish `.env.local`.

## Important next steps before real shop use

1. Enforce `staff` and `admin` permissions **server-side** from database roles; front-end role switches are for demo only.
2. Implement server-side `award_points` / `redeem_reward` functions: staff JWT authentication, membership lookup, purchase validation, database transaction, row locking, idempotent receipt keys, audit logs, rollback safety and optional refund reversal.
3. Build real staff-facing QR scanner and secure opaque-token member lookup; demo membership IDs are not authorization credentials.
4. Add `staff_roles`, `rewards`, `reward_redemptions`, `loyalty_settings`, and audit log tables and appropriate RLS/grants. The reward catalogue is local demo data today.
5. Add tests (RLS isolation, duplicate receipts, concurrent awards, insufficient balance, forbidden roles), backups, monitoring, privacy policy and customer data retention.
6. If Google-only sign-in is used, provide a support process for members who lose Google-account access.

## Tech stack

- React 19, React Router, Vite, TypeScript, Tailwind CSS v4
- Lucide icons, qrcode.react
- Optional Supabase Auth / PostgreSQL (customer read-only live mode)
- Netlify SPA hosting

## Folder map

- `src/App.tsx` — Customer / cashier / admin UI and demo actions
- `src/store.ts` — Demo data, local storage and types
- `src/supabase.ts` — Optional Supabase client configuration
- `src/style.css` — Tailwind / base styles
- `supabase/migrations/` — Optional read-only live member schema
- `netlify.toml` — Netlify build + SPA routes

## License

Demo code provided for your own coffee-shop website project. Replace branding and sample users with your own content.
