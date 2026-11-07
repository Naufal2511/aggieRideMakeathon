/**
 * ===================================================================
 * AGGIE RIDE — CREATIVE LANDING PAGE INTERACTIVE CONTROLLER
 * "Good journeys are better shared."
 * Texas A&M University • Student Mobility Network
 * ===================================================================
 */

// ===================================================================
// 1. SUBMISSION & REPOSITORY PLACEHOLDER CONSTANTS
// Update these URLs for your hackathon submission & GitHub repo!
// ===================================================================
const GITHUB_REPO_URL = "https://github.com/Naufal2511/aggieRideMakeathon";
const SUBMISSION_VIDEO_URL = "https://youtu.be/nnAs4oOZSmg";

// Attach URLs to showcase panels on DOM ready
document.addEventListener("DOMContentLoaded", () => {
  const githubLink = document.getElementById("githubPanelLink");
  const videoLink = document.getElementById("videoPanelLink");
  const githubNav = document.getElementById("navGithubLink");
  const heroDemoBtn = document.getElementById("heroDemoBtn");
  const finalDemoBtn = document.getElementById("finalDemoBtn");

  if (githubLink) githubLink.href = GITHUB_REPO_URL;
  if (githubNav) githubNav.href = GITHUB_REPO_URL;
  if (videoLink) videoLink.href = SUBMISSION_VIDEO_URL;
  if (heroDemoBtn) heroDemoBtn.href = SUBMISSION_VIDEO_URL;
  if (finalDemoBtn) finalDemoBtn.href = SUBMISSION_VIDEO_URL;

  // Initialize all interactive modules
  initNavbarScroll();
  initIntentSwitcher();
  initTexasRoutes();
  initPhoneControls();
  initScrollAnimations();
});

// ===================================================================
// 2. NAVBAR SCROLL EFFECT
// ===================================================================
function initNavbarScroll() {
  const navbarWrapper = document.getElementById("navbarWrapper");
  if (!navbarWrapper) return;

  window.addEventListener("scroll", () => {
    if (window.scrollY > 40) {
      navbarWrapper.classList.add("scrolled");
    } else {
      navbarWrapper.classList.remove("scrolled");
    }
  }, { passive: true });
}

// ===================================================================
// 3. RIDE INTENT INTERACTIVE PLAYGROUND
// Demonstrates that AggieRide is about travel intentions, not booking
// ===================================================================
const INTENT_PRESETS = {
  need_ride: {
    title: "Looking for a ride",
    subtitle: "Share where you need to go and your preferred time window. Fellow Aggies heading that way can offer seats without costly commercial fares.",
    bullets: [
      "Select flexible departure windows (e.g. ±30 mins or anytime)",
      "Choose from 7 shared campus meeting hubs (Park West, MSC, etc.)",
      "Get automatically added to an active destination cluster",
      "Ride with verified students with @tamu.edu authentication"
    ],
    badgeText: "Passenger Intent Active",
    badgeColor: "#F5F3FF",
    badgeBorder: "#DDD6FE",
    badgeTextColor: "#6D28D9",
    destTitle: "Walmart Supercenter & Groceries",
    destSub: "Saturday • Departing between 11:00 AM – 11:30 AM",
    hubTitle: "Pickup Hub",
    hubVal: "Park West (Tower 1 Porte-Cochère)",
    statusTitle: "Community Demand",
    statusVal: "4 Aggies also interested",
    userName: "Carlos Hernandez '26",
    userRole: "Sophomore • Passenger",
    userAvatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=120&auto=format&fit=crop&q=80",
    actionBtn: "Join Intent Group"
  },
  have_seats: {
    title: "Offering a ride",
    subtitle: "Already driving to Houston, Dallas, or H-E-B? Post your available seats to existing student groups and offset your Texas gas costs.",
    bullets: [
      "Drivers see unmet student demand before even turning their key",
      "Accept or decline passenger requests with 1-click approvals",
      "No awkward door-to-door suburban stops — meet at central campus hubs",
      "Boarding pass with OTP verification ensures passenger safety"
    ],
    badgeText: "Driver Seats Available",
    badgeColor: "#ECFDF5",
    badgeBorder: "#A7F3D0",
    badgeTextColor: "#047857",
    destTitle: "Houston Intercontinental (IAH)",
    destSub: "Friday • Departing at 4:30 PM",
    hubTitle: "Pickup Hub",
    hubVal: "MSC Rudder Plaza",
    statusTitle: "Available Seats",
    statusVal: "3 of 4 Seats Open ($15 split)",
    userName: "Maya Reed '25",
    userRole: "Senior • 2022 Honda Civic",
    userAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&auto=format&fit=crop&q=80",
    actionBtn: "Offer Seats to Group"
  },
  interested: {
    title: "Interested in a trip",
    subtitle: "Not 100% committed yet? Signal interest in an upcoming journey or weekend getaway so a group can form organically.",
    bullets: [
      "Gather critical mass before confirming departure times",
      "Chat with other interested students to finalize schedules",
      "Convert interest into a confirmed trip once a driver joins",
      "Receive real-time notifications when a driver offers seats"
    ],
    badgeText: "Gathering Interest",
    badgeColor: "#FFFBEB",
    badgeBorder: "#FDE68A",
    badgeTextColor: "#B45309",
    destTitle: "Austin Weekend & South Congress",
    destSub: "Next Friday • Leaving after afternoon classes",
    hubTitle: "Preferred Hub",
    hubVal: "Century Square Plaza",
    statusTitle: "Group Interest",
    statusVal: "7 Aggies signaled intent",
    userName: "David Miller '24",
    userRole: "Graduate Student • Intent Creator",
    userAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80",
    actionBtn: "I'm Interested Too"
  },
  destinations: {
    title: "Exploring shared destinations",
    subtitle: "See where the Aggie community is traveling right now — from grocery runs on Texas Ave to Kyle Field Game Day and the TAMU Makeathon.",
    bullets: [
      "Live destination clusters aggregate student travel demand",
      "Campus events integration (Zachry Complex, Reed Arena, Kyle Field)",
      "Zero solo drives: travel together, build community, reduce carbon footprint",
      "Transparent trip coordination in a secure student-only environment"
    ],
    badgeText: "Community Destination Hub",
    badgeColor: "#FEF2F2",
    badgeBorder: "#FECACA",
    badgeTextColor: "#500000",
    destTitle: "TAMU Makeathon 2026 @ Zachry",
    destSub: "Saturday All-Day • Recurring campus shuttle carpool",
    hubTitle: "Meeting Hub",
    hubVal: "White Creek & Park West Loop",
    statusTitle: "Total Community",
    statusVal: "14 Students • 3 Drivers Carpooling",
    userName: "Priya Patel '25",
    userRole: "Junior • Carpool Coordinator",
    userAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80",
    actionBtn: "Explore Event Carpool"
  }
};

function initIntentSwitcher() {
  const chipButtons = document.querySelectorAll(".intent-chip-btn");
  const titleEl = document.getElementById("intentStageTitle");
  const subEl = document.getElementById("intentStageSub");
  const bulletsEl = document.getElementById("intentStageBullets");

  const badgeEl = document.getElementById("previewBadge");
  const destTitleEl = document.getElementById("previewDestTitle");
  const destSubEl = document.getElementById("previewDestSub");
  const hubTitleEl = document.getElementById("previewHubTitle");
  const hubValEl = document.getElementById("previewHubVal");
  const statusTitleEl = document.getElementById("previewStatusTitle");
  const statusValEl = document.getElementById("previewStatusVal");
  const userAvatarEl = document.getElementById("previewUserAvatar");
  const userNameEl = document.getElementById("previewUserName");
  const userRoleEl = document.getElementById("previewUserRole");
  const actionBtnEl = document.getElementById("previewActionBtn");

  if (!chipButtons.length || !titleEl) return;

  chipButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const intentKey = btn.dataset.intent;
      const data = INTENT_PRESETS[intentKey];
      if (!data) return;

      chipButtons.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");

      // Update text with smooth transition
      titleEl.textContent = data.title;
      subEl.textContent = data.subtitle;

      bulletsEl.innerHTML = data.bullets
        .map(
          (b) => `
        <li>
          <span class="bullet-icon">✓</span>
          <span>${b}</span>
        </li>
      `
        )
        .join("");

      badgeEl.textContent = data.badgeText;
      badgeEl.style.backgroundColor = data.badgeColor;
      badgeEl.style.borderColor = data.badgeBorder;
      badgeEl.style.color = data.badgeTextColor;

      destTitleEl.textContent = data.destTitle;
      destSubEl.textContent = data.destSub;
      hubTitleEl.textContent = data.hubTitle;
      hubValEl.textContent = data.hubVal;
      statusTitleEl.textContent = data.statusTitle;
      statusValEl.textContent = data.statusVal;

      userAvatarEl.src = data.userAvatar;
      userNameEl.textContent = data.userName;
      userRoleEl.textContent = data.userRole;
      actionBtnEl.textContent = data.actionBtn;
    });
  });
}

// ===================================================================
// 4. TEXAS ROUTES EXPLORER
// ===================================================================
const ROUTE_DATA = {
  houston: {
    headline: "College Station ➔ Houston",
    distance: "95 miles • ~1 hr 45 min",
    feedTitle: "Active Travel Intent",
    feedText: "3 Aggies heading to Houston this Friday afternoon. 1 driver offering seats to George Bush Intercontinental (IAH).",
    pathId: "routePathHouston"
  },
  dallas: {
    headline: "College Station ➔ Dallas / Fort Worth",
    distance: "180 miles • ~2 hr 45 min",
    feedTitle: "Active Travel Intent",
    feedText: "4 Aggies looking for rides to Dallas after Friday exams. Connecting through I-45 North corridor.",
    pathId: "routePathDallas"
  },
  austin: {
    headline: "College Station ➔ Austin",
    distance: "105 miles • ~1 hr 50 min",
    feedTitle: "Active Travel Intent",
    feedText: "Weekend group trip gathering interest for ACL / Downtown Austin via Highway 21.",
    pathId: "routePathAustin"
  },
  san_antonio: {
    headline: "College Station ➔ San Antonio",
    distance: "165 miles • ~2 hr 35 min",
    feedTitle: "Active Travel Intent",
    feedText: "2 Aggies heading to San Antonio for family weekend. Pickup requested at Century Square.",
    pathId: "routePathSanAntonio"
  }
};

function initTexasRoutes() {
  const routeCards = document.querySelectorAll(".route-option-card");
  const feedTitle = document.getElementById("routeLiveTitle");
  const feedText = document.getElementById("routeLiveText");

  if (!routeCards.length) return;

  routeCards.forEach((card) => {
    card.addEventListener("click", () => {
      const cityKey = card.dataset.city;
      const data = ROUTE_DATA[cityKey];
      if (!data) return;

      routeCards.forEach((c) => c.classList.remove("active"));
      card.classList.add("active");

      if (feedTitle) feedTitle.textContent = `${data.headline} (${data.distance})`;
      if (feedText) feedText.textContent = data.feedText;

      // Highlight corresponding SVG map path
      document.querySelectorAll(".map-route-line").forEach((line) => {
        line.setAttribute("stroke-opacity", "0.25");
        line.setAttribute("stroke-width", "2.5");
      });

      const activePath = document.getElementById(data.pathId);
      if (activePath) {
        activePath.setAttribute("stroke-opacity", "1");
        activePath.setAttribute("stroke-width", "5");
      }
    });
  });
}

// ===================================================================
// 5. PHONE CONTROLS (PERSONA SWITCHER FOR EMBEDDED APP)
// ===================================================================
function initPhoneControls() {
  const iframe = document.getElementById("phoneAppIframe");
  const personaBtns = document.querySelectorAll(".persona-btn-chip");

  if (!personaBtns.length || !iframe) return;

  personaBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      personaBtns.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");

      const userId = btn.dataset.user;
      if (!userId) return;

      // Communicate to iframe app to switch user
      try {
        iframe.contentWindow.postMessage({ type: "SWITCH_USER", userId }, "*");
      } catch (e) {
        // Fallback: reload iframe with user parameter
        iframe.src = `app.html?embed=true&user=${userId}`;
      }
    });
  });
}

// ===================================================================
// 6. SCROLL-TRIGGERED REVEAL ANIMATIONS
// ===================================================================
function initScrollAnimations() {
  const revealElements = document.querySelectorAll(".reveal-on-scroll");
  if (!revealElements.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
        }
      });
    },
    { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
  );

  revealElements.forEach((el) => observer.observe(el));
}

