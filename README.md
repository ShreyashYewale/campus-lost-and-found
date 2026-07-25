Campus Lost & Found

A single platform for reporting and reclaiming lost items on campus, replacing the scattered WhatsApp groups where most posts never reach the owner. Users post a lost or found item with a photo, category, and location. The app automatically checks for matches between lost and found posts in the same category and area, notifies both parties, and supports a claim-and-approval workflow until the item is marked resolved.

Built as a CPAD course project.

Team: Shreyash Yewale (2025CA93029), Priyanka Salunke (2025CA93019) License: MIT

Features
Post a lost or found item with photo, category, and location
Browse and search all items; filter by category and location
Automatic matching between lost and found items
Claim an item, with approval from the person who posted it
Notifications on a possible match or a new claim
Mark items as resolved
Google login for authentication
Tech Stack
Layer	Technology	Notes
Frontend	Flutter (Web + one mobile platform)	UI only — talks to the backend over GraphQL
Backend	KeystoneJS (Node.js, GraphQL)	Schema, auth, matching logic, image storage
Database	PostgreSQL	Run locally via Docker
Version control	GitHub (CPAD org)	Feature branches + PR review

Important: Flutter is the frontend only. It has no server or database of its own. It sends GraphQL queries over HTTP to Keystone, which reads and writes Postgres and returns JSON that Flutter renders.

Repository Structure
campus-lost-and-found/
├── backend/          # KeystoneJS + Postgres
│   ├── schema.ts     # The four lists: User, Item, Claim, Notification
│   ├── keystone.ts   # Config: db connection, image storage, CORS
│   ├── auth.ts       # Authentication setup (from the Keystone starter)
│   ├── .env          # Local secrets — NOT committed
│   ├── .env.example  # Template with blank values — committed
│   └── ...
├── frontend/         # Flutter app (added in a later phase)
├── docs/             # Design notes, schema diagrams
└── README.md
Data Model

Four lists, all related:

User — name, email, googleId; owns items, claims, and notifications.
Item — title, description, type (lost/found), category, location, photo, status (open/claimed/resolved). category and location are select fields, not free text — this is deliberate, because reliable automatic matching needs fixed values rather than arbitrary strings.
Claim — links a User to an Item they want to claim, with a status (pending/approved/rejected).
Notification — a message to a User about a match or claim event, with a read flag.
Prerequisites

Before you start, make sure you have:

Node.js (LTS) and npm
Docker Desktop — used to run Postgres (see the note below about the office laptop)
Git with SSH set up for your GitHub account
Flutter SDK (only needed once we start the frontend phase)
Getting Started
1. Clone the repo
bash
git clone <repo-ssh-url>
cd campus-lost-and-found

Right after cloning, set your commit identity locally for this repo (we don't use a global git identity — see the SSH note at the end):

bash
git config user.name "Your Name"
git config user.email "your@email.com"
2. Start Postgres with Docker

We run Postgres in a Docker container so it's isolated and identical for both of us.

Port note — read this. The default Postgres port 5432 may already be taken on your machine by another local Postgres service. To avoid a conflict we map the container to host port 5433 instead. If you ever see P1000: Authentication failed, a port clash is the most likely cause — check with netstat -ano | findstr :5432 and confirm nothing else is squatting on the port you expect.

Create and start the container:

bash
docker run --name lostfound-db -e POSTGRES_PASSWORD=lostfound123 -p 5433:5432 -d postgres

What this does:

--name lostfound-db — names the container
-e POSTGRES_PASSWORD=lostfound123 — sets the postgres user password
-p 5433:5432 — maps host port 5433 to the container's internal 5432
-d postgres — runs the official Postgres image in the background

Create the database inside the container:

bash
docker exec -it lostfound-db psql -U postgres -c "CREATE DATABASE lostfound;"

Everyday Docker commands:

bash
docker stop lostfound-db     # pause when done for the day
docker start lostfound-db    # resume
docker rm -f lostfound-db    # delete entirely and start fresh

Note: By default, deleting the container also deletes its data. That's fine for this assignment. If we want data to survive deletion later, we'll add a Docker volume.

3. Configure environment variables

In backend/, create a .env file (copy from .env.example):

DATABASE_URL=postgres://postgres:lostfound123@localhost:5433/lostfound
SESSION_SECRET=replace-with-a-long-random-string-at-least-32-chars

Make sure the port matches what you used in the Docker command (5433).

Never commit .env. It holds the DB password and session secret. It's already in .gitignore. Only .env.example (with blank values) is committed.

4. Install dependencies and run the backend
bash
cd backend
npm install
npm run dev

On first run, Keystone will synchronize the schema with the database. When you see:

✅ GraphQL API ready
✅ Admin UI ready

...the backend is up.

5. Open the admin UI

Go to http://localhost:3000. On first load it asks you to create an initial user. After that you'll see the dashboard with User, Item, Claim, and Notification.

Quick test that everything works:

Create an Item — type lost, category electronics, location library
Create another Item — type found, category electronics, location library
Confirm both save correctly
The GraphQL playground is at http://localhost:3000/api/graphql.