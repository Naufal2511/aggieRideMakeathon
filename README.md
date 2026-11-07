# 🚗 Aggie Ride — Good Journeys Are Better Shared

> **Community-Powered Student Mobility for Texas A&M University**  
> *Built for Texas A&M Makeathon 2026 • College Station, Texas*

[![Live Demo](https://img.shields.io/badge/Live_Demo-aggies--ride.netlify.app-500000?style=for-the-badge&logo=netlify)](https://aggies-ride.netlify.app/#explore-app)
[![TAMU Makeathon](https://img.shields.io/badge/TAMU_Makeathon-2026_Project-D4AF37?style=for-the-badge&logo=target)](https://aggies-ride.netlify.app)
[![License: MIT](https://img.shields.io/badge/License-MIT-black?style=for-the-badge)](LICENSE)

---

## 🌐 Live Deployment Links

| Experience | URL | Description |
| :--- | :--- | :--- |
| **🚀 Main Landing Page & Interactive Showcase** | **[https://aggies-ride.netlify.app/#explore-app](https://aggies-ride.netlify.app/#explore-app)** | Editorial landing page with interactive Texas corridor map, intent playground, and embedded smartphone app. |
| **📱 Full Judge & Evaluator App View** | **[https://aggies-ride.netlify.app/app](https://aggies-ride.netlify.app/app)** | 2-column showcase with top evaluator toolbar, 5 student personas, and 7 guided evaluation flows. |

---

## 💡 1. The Core Vision: Ride Intent, Not Ride Booking

Traditional ride-hailing services (Uber, Lyft) are built around **expensive, transactional driver-dispatch**:
- Surge pricing ($20–$30 for a 3-mile grocery trip).
- Unpredictable suburban door-to-door stops.
- Riding with unverified strangers.

**Aggie Ride flips the model: Travel Intent.**

Every weekend, thousands of Aggies head to the exact same places:
- **Groceries & Essentials:** Walmart Supercenter, H-E-B (Texas Ave / Jones Crossing), Target, Costco.
- **Cross-City Drives:** Houston (IAH / Hobby / Katy), Dallas / Fort Worth (DFW), Austin (Hwy 21), San Antonio.
- **Campus & Traditions:** Zachry Engineering Complex, Kyle Field Game Day, Reed Arena, MSC, Century Square.

Instead of hunting for drivers, students simply communicate what they intend to do:
```
1. Express Travel Intent ──► 2. Form Destination Group ──► 3. Driver Offers Open Seats
                                                                      │
6. Safe Boarding (OTP) ◄── 5. Coordinate Hub Pickup ◄── 4. Accept Passenger Requests
```

---

## ✨ 2. Key Product Features

### A. Demand-First Intention Engine
* **"Where are you heading?"**: Predefined destination shortcuts for Walmart, H-E-B, Target, Campus, and Texas metro corridors.
* **Flexible Departure Windows**: Select Exact, ±30 mins, ±1 hour, or Anytime.
* **Destination Clusters**: Automatically aggregates compatible student intentions with real-time indicators for *gathering interest*, *drivers available*, and *seats remaining*.

### B. 7 Predefined Shared Pickup Zones (Bryan / College Station)
To eliminate driver detours through apartment labyrinths, Aggie Ride designates 7 shared pickup hubs:
1. **MSC / Rudder Plaza Vicinity** — Central campus hub.
2. **Park West Apartments** — Tower 1 Porte-Cochère.
3. **Century Square** — Social plaza & green space.
4. **Northgate / College Main** — Northside campus district.
5. **White Creek Apartments** — West campus living-learning community.
6. **The Gardens Apartments** — South College Station loop.
7. **University Apartments** — East campus housing.

### C. Driver Role Isolation
* **Passenger-only students** see an intuitive intent-sharing and group discovery interface.
* **Verified Drivers** undergo vehicle/license verification in Profile and gain access to:
  * Incoming passenger seat requests (*Accept* / *Decline* controls).
  * Prompts highlighting unmet student demand (*"6 Aggies need rides to Walmart Saturday. Offer seats?"*).
  * Trip capacity and seat counter management.

### D. Single-Use OTP Boarding Pass
* When a ride is confirmed, passengers receive a tamper-proof single-use OTP (e.g., `AG-7193`).
* Passengers present their OTP to the driver at the pickup hub to verify identity before entering the vehicle.

### E. Privacy-Preserving Coordination Messaging
* WhatsApp/Airbnb-style coordination chat.
* Displays contextual trip pills (*Walmart • Sat 11:00 AM • Park West Tower 1*).
* Personal phone numbers remain private while verifying `@tamu.edu` student credentials.

---

## 👥 3. Multi-Persona Testing System

Evaluators and judges can switch between 5 authentic Texas A&M student personas in real-time:

| Persona | Role | Context & Vehicle | Testing Focus |
| :--- | :--- | :--- | :--- |
| **Carlos Hernandez '26** | Sophomore • Passenger | Park West Apartments | Posts Walmart intent, joins group, holds boarding pass `AG-7193`. |
| **Maya Reed '25** | Senior • Verified Driver | 2022 White Honda Civic | Views unmet demand, offers 3 seats, accepts Carlos's seat request. |
| **David Miller '24** | Graduate Driver | Silver Toyota RAV4 | Carpools students to Zachry Complex for TAMU Makeathon. |
| **Priya Patel '25** | Junior Driver | Maroon Hyundai Elantra | Offers rides for Kyle Field Game Day and Century Square. |
| **Sarah Chen '27** | Freshman • New User | Hullabaloo Hall | Tests student directory verification and onboarding flow. |

---

## 🧪 4. Evaluator Quick Demonstration Flows

In the Evaluator View (`/app`), click the toolbar chips to run automated walkthroughs:

* **Flow 1: Express Intent & Form Group** — Carlos posts a travel plan for Walmart and gets matched with an active cluster.
* **Flow 2: Driver Offers Seats** — Maya logs in, reviews unmet student demand, and offers 3 open seats.
* **Flow 3: Request & Accept Seat** — Carlos requests a seat; Maya reviews and accepts it from her driver dashboard.
* **Flow 4: Shared Pickup Zones** — Inspects the 7 College Station pickup hubs with walking distance radii.
* **Flow 5: Private Messaging** — Tests driver-passenger chat with trip metadata pill attached.
* **Flow 6: Event Carpooling** — Discovers the TAMU Makeathon event and coordinates a carpool to Zachry.
* **Flow 7: Safety OTP Pass** — Inspects Carlos's boarding pass with single-use verification code.

---

## 📂 5. Repository Structure

```
makeathon/
├── index.html              # Award-winning editorial landing page (Netlify /)
├── app.html                # Full evaluator application & 7 user journeys (/app)
├── vercel.json             # Vercel clean URL & route rewrite configuration
├── netlify.toml            # Netlify build & redirect rules
├── _redirects              # Netlify SPA route redirect (/app -> /app.html)
├── css/
│   ├── landing.css         # Editorial landing page styling & responsive layout
│   └── style.css           # Mobile app design system & component styles
├── js/
│   ├── landing.js          # Interactive intent switcher, Texas route map, & phone frame
│   ├── app.js              # Application core logic, state management, & flows
│   └── seedData.js         # Comprehensive mock data (TAMU groups, events, users)
└── aggie_ride/             # Cross-platform Flutter client codebase
    ├── lib/                # Flutter source code (models, screens, state, theme)
    ├── pubspec.yaml        # Flutter dependencies
    └── web/                # Flutter web compilation target
```

---

## 🛠️ 6. Local Development & Deployment

### Run Locally (Zero Setup Required)
Because the web app uses self-contained LocalStorage fallback, you can run it with any static server:

```bash
# Clone the repository
git clone https://github.com/Naufal2511/aggieRideMakeathon.git
cd aggieRideMakeathon

# Start local server (Python 3)
python3 -m http.server 8000
```
Then visit:
* Landing Page: `http://localhost:8000`
* App / Evaluator View: `http://localhost:8000/app.html`

### Deploy to Netlify
```bash
npx netlify-cli deploy --prod --dir=.
```

### Deploy to Vercel
```bash
vercel --prod
```

---

## 🏆 7. Hackathon Information

* **Event:** Texas A&M Makeathon 2026
* **Location:** Zachry Engineering Education Complex • College Station, TX
* **Track / Category:** Student Life, Mobility & Community Innovation
* **Status:** Complete & Deployed

---

*“Because nobody should have to make the Texas drive alone.”*  
**Built with pride by Aggies for Aggies.**
