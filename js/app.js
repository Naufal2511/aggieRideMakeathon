// ===================================================================
// AGGIERIDE CORE APPLICATION LOGIC
// Texas A&M Student-Powered Mobility Network
// "Where Aggies go, Aggies ride."
// ===================================================================

(function () {
  'use strict';

  // LocalStorage state keys
  const STORAGE_KEYS = {
    USERS: 'aggieride_users_v3',
    DESTINATION_GROUPS: 'aggieride_groups_v3',
    INTENTIONS: 'aggieride_intentions_v3',
    RIDES: 'aggieride_rides_v3',
    REQUESTS: 'aggieride_requests_v3',
    EVENTS: 'aggieride_events_v3',
    CONVERSATIONS: 'aggieride_convs_v3',
    CURRENT_USER_ID: 'aggieride_active_user_v3',
    ACTIVE_TAB: 'aggieride_active_tab_v3'
  };

  // Live Application State
  let users = [];
  let destinationGroups = [];
  let intentions = [];
  let rides = [];
  let requests = [];
  let events = [];
  let conversations = [];
  let pickupZones = [];
  let tamuFacts = [];

  let currentUser = null;
  let activeTab = 'home';
  let activeSubtabJourneys = 'intentions';
  let activeConversationId = null;
  let currentFactIndex = 0;
  let factTimer = null;
  let selectedDiscoverFilter = 'All';

  // Initialize Application
  function init() {
    loadOrSeedData();
    setupEventListeners();
    startFactsRotation();
    renderAllViews();

    // Auto-prompt persona choice on first visit
    setTimeout(() => {
      if (!sessionStorage.getItem('aggieride_persona_selected_session')) {
        openPersonaSelectModal();
      }
    }, 450);
  }

  // Load state from localStorage or initialize from seedData.js
  function loadOrSeedData(forceReset = false) {
    if (forceReset || !localStorage.getItem(STORAGE_KEYS.USERS)) {
      users = JSON.parse(JSON.stringify(window.INITIAL_USERS || []));
      destinationGroups = JSON.parse(JSON.stringify(window.INITIAL_DESTINATION_GROUPS || []));
      intentions = JSON.parse(JSON.stringify(window.INITIAL_INTENTIONS || []));
      rides = JSON.parse(JSON.stringify(window.INITIAL_RIDES || []));
      requests = JSON.parse(JSON.stringify(window.INITIAL_REQUESTS || []));
      events = JSON.parse(JSON.stringify(window.INITIAL_EVENTS || []));
      conversations = JSON.parse(JSON.stringify(window.INITIAL_CONVERSATIONS || []));
      pickupZones = JSON.parse(JSON.stringify(window.INITIAL_PICKUP_ZONES || []));
      tamuFacts = JSON.parse(JSON.stringify(window.INITIAL_TAMU_FACTS || []));

      // Default active persona: Carlos Hernandez (Passenger) for primary travel intention flow
      currentUser = users[0];
      activeTab = 'home';
      saveData();
    } else {
      try {
        users = JSON.parse(localStorage.getItem(STORAGE_KEYS.USERS)) || window.INITIAL_USERS;
        destinationGroups = JSON.parse(localStorage.getItem(STORAGE_KEYS.DESTINATION_GROUPS)) || window.INITIAL_DESTINATION_GROUPS;
        intentions = JSON.parse(localStorage.getItem(STORAGE_KEYS.INTENTIONS)) || window.INITIAL_INTENTIONS;
        rides = JSON.parse(localStorage.getItem(STORAGE_KEYS.RIDES)) || window.INITIAL_RIDES;
        requests = JSON.parse(localStorage.getItem(STORAGE_KEYS.REQUESTS)) || window.INITIAL_REQUESTS;
        events = JSON.parse(localStorage.getItem(STORAGE_KEYS.EVENTS)) || window.INITIAL_EVENTS;
        conversations = JSON.parse(localStorage.getItem(STORAGE_KEYS.CONVERSATIONS)) || window.INITIAL_CONVERSATIONS;
        pickupZones = window.INITIAL_PICKUP_ZONES || [];
        tamuFacts = window.INITIAL_TAMU_FACTS || [];

        const savedUserId = localStorage.getItem(STORAGE_KEYS.CURRENT_USER_ID) || 'user-carlos';
        currentUser = users.find(u => u.userId === savedUserId) || users[0];
      } catch (err) {
        console.error('Error reading localStorage, resetting to defaults', err);
        loadOrSeedData(true);
      }
    }
  }

  // Persist State to LocalStorage
  function saveData() {
    localStorage.setItem(STORAGE_KEYS.USERS, JSON.stringify(users));
    localStorage.setItem(STORAGE_KEYS.DESTINATION_GROUPS, JSON.stringify(destinationGroups));
    localStorage.setItem(STORAGE_KEYS.INTENTIONS, JSON.stringify(intentions));
    localStorage.setItem(STORAGE_KEYS.RIDES, JSON.stringify(rides));
    localStorage.setItem(STORAGE_KEYS.REQUESTS, JSON.stringify(requests));
    localStorage.setItem(STORAGE_KEYS.EVENTS, JSON.stringify(events));
    localStorage.setItem(STORAGE_KEYS.CONVERSATIONS, JSON.stringify(conversations));
    if (currentUser) {
      localStorage.setItem(STORAGE_KEYS.CURRENT_USER_ID, currentUser.userId);
    }
  }

  // Show Toast Notification
  function showToast(message, icon = 'check_circle') {
    const toast = document.getElementById('appToast');
    const toastMsg = document.getElementById('toastMessage');
    const toastIco = document.getElementById('toastIcon');

    if (!toast || !toastMsg) return;
    toastMsg.textContent = message;
    if (toastIco) toastIco.textContent = icon;

    toast.classList.add('active');
    setTimeout(() => {
      toast.classList.remove('active');
    }, 3200);
  }

  // Rotate Aggie Fact of the Day
  function startFactsRotation() {
    if (factTimer) clearInterval(factTimer);
    updateFactDisplay();
    factTimer = setInterval(() => {
      cycleFact(1);
    }, 12000);
  }

  function cycleFact(direction = 1) {
    if (!tamuFacts.length) return;
    currentFactIndex = (currentFactIndex + direction + tamuFacts.length) % tamuFacts.length;
    updateFactDisplay();
  }

  function updateFactDisplay() {
    if (!tamuFacts.length) return;
    const fact = tamuFacts[currentFactIndex];
    const factIcon = document.getElementById('factIcon');
    const factTag = document.getElementById('factTag');
    const factTitle = document.getElementById('factTitle');
    const factText = document.getElementById('factText');

    if (factIcon) factIcon.textContent = fact.icon || 'school';
    if (factTag) factTag.textContent = fact.tag ? `Did you know, Aggie? • ${fact.tag}` : 'Did you know, Aggie?';
    if (factTitle) factTitle.textContent = fact.title;
    if (factText) factText.textContent = fact.text;
  }

  // Switch Active Student Persona
  function switchUser(userId) {
    const found = users.find(u => u.userId === userId);
    if (!found) return;
    currentUser = found;
    saveData();

    // Sync Evaluator Select Box
    const select = document.getElementById('evaluatorUserSelect');
    if (select && select.value !== userId) {
      select.value = userId;
    }

    showToast(`Switched active persona to ${currentUser.name}`, 'account_circle');
    renderAllViews();
  }

  // Navigation Tab Switching
  function navigateToTab(tabName) {
    activeTab = tabName;

    // Toggle Tab Views
    document.querySelectorAll('.page-tab-content').forEach(el => {
      el.classList.remove('active');
    });
    const targetSection = document.getElementById(`tab-${tabName}`);
    if (targetSection) {
      targetSection.classList.add('active');
    }

    // Toggle Nav Bar Active States
    document.querySelectorAll('.nav-tab-item').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-tab') === tabName);
    });

    // Reset scroll position to top
    const scroll = document.getElementById('mainAppScroll');
    if (scroll) scroll.scrollTop = 0;

    renderTabSpecificContent(tabName);
  }

  // Render specific content depending on current tab
  function renderTabSpecificContent(tabName) {
    switch (tabName) {
      case 'home':
        renderHomeScreen();
        break;
      case 'discover':
        renderDiscoverScreen();
        break;
      case 'journeys':
        renderJourneysScreen();
        break;
      case 'messages':
        renderMessagesScreen();
        break;
      case 'profile':
        renderProfileScreen();
        break;
    }
  }

  // Master Render Method
  function renderAllViews() {
    renderHeader();
    renderDriverVisibility();
    renderHomeScreen();
    renderDiscoverScreen();
    renderJourneysScreen();
    renderMessagesScreen();
    renderProfileScreen();
    updateUnreadBadges();
  }

  // Render Header Details
  function renderHeader() {
    const greeting = document.getElementById('headerGreeting');
    const avatar = document.getElementById('headerUserAvatar');

    if (greeting && currentUser) {
      const firstName = currentUser.name.split(' ')[0];
      greeting.textContent = `Hey, ${firstName}!`;
    }
    if (avatar && currentUser) {
      avatar.src = currentUser.avatar;
      avatar.alt = currentUser.name;
    }
  }

  // Driver UI Isolation (Crucial Requirement: Non-drivers NEVER see Offer Ride in bottom nav)
  function renderDriverVisibility() {
    const isDriver = currentUser && currentUser.isDriverVerified;

    // Floating Action Button
    const driverFab = document.getElementById('driverOfferFab');
    if (driverFab) {
      driverFab.style.display = isDriver ? 'flex' : 'none';
    }

    // Driver Demand Callout Banner on Home
    const driverBanner = document.getElementById('driverDemandBanner');
    if (driverBanner) {
      driverBanner.style.display = isDriver ? 'flex' : 'none';
    }

    // Offered Rides subtab button in My Journeys
    const offeredBtn = document.getElementById('subtabOfferedBtn');
    if (offeredBtn) {
      offeredBtn.style.display = isDriver ? 'block' : 'none';
    }
  }

  // Update Unread Badges
  function updateUnreadBadges() {
    const unreadMessagesCount = conversations.reduce((total, conv) => {
      const unreadInConv = conv.messages.filter(m => m.senderId !== currentUser.userId && !m.read).length;
      return total + unreadInConv;
    }, 0);

    const navBadge = document.getElementById('navMessagesBadge');
    if (navBadge) {
      if (unreadMessagesCount > 0) {
        navBadge.style.display = 'flex';
        navBadge.textContent = unreadMessagesCount;
      } else {
        navBadge.style.display = 'none';
      }
    }

    const notifDot = document.getElementById('headerNotificationDot');
    if (notifDot) {
      // Show dot if pending requests for driver or unread messages
      const hasDriverPending = currentUser.isDriverVerified && requests.some(r => r.driverId === currentUser.userId && r.status === 'PENDING');
      notifDot.style.display = (hasDriverPending || unreadMessagesCount > 0) ? 'block' : 'none';
    }
  }

  // ===================================================================
  // HOME SCREEN RENDERING
  // ===================================================================
  function renderHomeScreen() {
    renderPopularDestinations();
    renderHomeGroups();
    renderHomeEvents();
    renderHomeInterests();
  }

  // Section D: Popular Destinations Shortcuts
  function renderPopularDestinations() {
    const container = document.getElementById('popularDestinationsGrid');
    if (!container) return;

    const list = window.POPULAR_DESTINATIONS || [];
    container.innerHTML = list.map(item => `
      <div class="destination-chip" data-destination="${item.fullAddress}">
        <span class="material-symbols-outlined chip-icon">${item.icon}</span>
        <span>${item.name}</span>
      </div>
    `).join('');

    container.querySelectorAll('.destination-chip').forEach(chip => {
      chip.addEventListener('click', () => {
        const dest = chip.getAttribute('data-destination');
        const input = document.getElementById('intentDestinationInput');
        if (input) {
          input.value = dest;
          input.focus();
          showToast(`Prefilled ${dest}`, 'edit_location_alt');
        }
      });
    });
  }

  // Section E: Where Aggies Are Heading Today (Destination Groups)
  function renderHomeGroups() {
    const container = document.getElementById('homeGroupsContainer');
    if (!container) return;

    if (!destinationGroups.length) {
      container.innerHTML = `<p style="font-size:12px; color:var(--text-muted); text-align:center; padding:12px;">No active destination groups yet.</p>`;
      return;
    }

    // Display top groups
    container.innerHTML = destinationGroups.map(group => createGroupCardHTML(group)).join('');

    // Attach click events
    container.querySelectorAll('.group-destination-card').forEach(card => {
      card.addEventListener('click', () => {
        const groupId = card.getAttribute('data-group-id');
        openGroupDetailsModal(groupId);
      });
    });
  }

  // Generate HTML for a Destination Group Card with 4 Explicit Metrics
  function createGroupCardHTML(group) {
    const statusClasses = {
      'Ride available': 'status-available',
      'Ride filling up': 'status-filling',
      'Looking for a driver': 'status-looking',
      'Gathering interest': 'status-interest',
      'Confirmed': 'status-confirmed'
    };
    const statusClass = statusClasses[group.status] || 'status-interest';

    // Build participants avatar stack
    const participants = group.participants || [];
    const avatarsHTML = participants.slice(0, 4).map(p => `
      <img src="${p.avatar}" alt="${p.name}" class="stack-img" title="${p.name} (${p.role})">
    `).join('');

    const extraCount = participants.length > 4 ? `+${participants.length - 4}` : '';

    return `
      <div class="group-destination-card" data-group-id="${group.groupId}">
        <div class="group-card-top">
          <div>
            <div class="group-dest-title">${group.destination}</div>
            <div class="group-time-tag">
              <span class="material-symbols-outlined" style="font-size:14px; color:var(--aggie-maroon);">schedule</span>
              ${group.dateLabel} • ${group.timeWindow}
            </div>
          </div>
          <span class="group-status-badge ${statusClass}">
            <span class="material-symbols-outlined" style="font-size:12px;">circle</span>
            ${group.status}
          </span>
        </div>

        <!-- 4 Explicit Community Metrics -->
        <div class="group-metrics-row">
          <div class="group-metric-item">
            <span class="metric-num">${group.interestedCount}</span>
            <span class="metric-lbl">Aggies Interested</span>
          </div>
          <div class="group-metric-item">
            <span class="metric-num">${group.driversCount}</span>
            <span class="metric-lbl">Drivers Offering</span>
          </div>
          <div class="group-metric-item">
            <span class="metric-num">${group.confirmedSeatsAvailable}</span>
            <span class="metric-lbl">Open Seats</span>
          </div>
        </div>

        <div class="group-participants-row">
          <div class="avatar-stack">
            ${avatarsHTML}
            ${extraCount ? `<span class="stack-count">${extraCount} more</span>` : ''}
          </div>
          <div class="group-action-hint">
            <span>Details</span>
            <span class="material-symbols-outlined" style="font-size:15px;">chevron_right</span>
          </div>
        </div>
      </div>
    `;
  }

  // Section F: What's Happening Around Aggieland?
  function renderHomeEvents() {
    const container = document.getElementById('homeEventsCarousel');
    if (!container) return;

    container.innerHTML = events.map(evt => `
      <div class="event-card" data-event-id="${evt.eventId}">
        <div class="event-card-img">
          <img src="${evt.image}" alt="${evt.title}">
          <span class="event-category-badge">${evt.category}</span>
        </div>
        <div class="event-card-body">
          <div class="event-title">${evt.title}</div>
          <div class="event-detail">
            <span class="material-symbols-outlined" style="font-size:13px; color:var(--aggie-maroon);">event</span>
            ${evt.date} • ${evt.time}
          </div>
          <div class="event-detail">
            <span class="material-symbols-outlined" style="font-size:13px; color:var(--aggie-maroon);">location_on</span>
            ${evt.venue}
          </div>
          <div class="event-attendees-hint">${evt.interestedCount} Aggies planning to go</div>
          <button class="btn-event-carpool find-aggies-event-btn" data-event-id="${evt.eventId}">
            <span class="material-symbols-outlined" style="font-size:15px;">directions_car</span>
            Find Aggies going
          </button>
        </div>
      </div>
    `).join('');

    container.querySelectorAll('.find-aggies-event-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const eventId = btn.getAttribute('data-event-id');
        handleFindAggiesForEvent(eventId);
      });
    });
  }

  // Section G: Interests
  function renderHomeInterests() {
    const container = document.getElementById('homeInterestsCloud');
    if (!container) return;

    const list = window.INITIAL_INTERESTS || [];
    container.innerHTML = list.map(item => `
      <div class="interest-pill" data-interest-id="${item.id}">
        <span class="material-symbols-outlined" style="font-size:15px;">${item.icon}</span>
        <span>${item.label}</span>
      </div>
    `).join('');

    container.querySelectorAll('.interest-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        pill.classList.toggle('active');
        const text = pill.querySelector('span:last-child').textContent;
        showToast(`Filtered by ${text}`, 'filter_list');
        navigateToTab('discover');
      });
    });
  }

  // Handle "Find Aggies going" for Events (Generates travel intention to venue!)
  function handleFindAggiesForEvent(eventId) {
    const evt = events.find(e => e.eventId === eventId);
    if (!evt) return;

    // Check if intention already exists for this event
    const existing = intentions.find(i => i.userId === currentUser.userId && i.destination.includes(evt.venue));
    if (!existing) {
      const newIntention = {
        intentionId: `intent-${Date.now()}`,
        userId: currentUser.userId,
        destination: `${evt.title} (${evt.venue})`,
        startingArea: currentUser.startingArea || 'Park West Apartments',
        preferredPickupZone: 'Park West Apartments',
        preferredDate: evt.date,
        preferredTime: evt.time.split('–')[0].trim(),
        flexibility: '±30 mins',
        passengersCount: 1,
        note: `Attending ${evt.title}! Looking to carpool together with fellow Aggies.`,
        status: 'Gathering interest',
        matchedGroupId: null,
        createdAt: new Date().toISOString()
      };
      intentions.unshift(newIntention);
      evt.interestedCount += 1;
      saveData();
    }

    showToast(`Travel plan added for ${evt.title}! Finding Aggies going...`, 'groups');
    navigateToTab('journeys');
    openSubtabJourneys('intentions');
  }

  // ===================================================================
  // DISCOVER SCREEN RENDERING
  // ===================================================================
  function renderDiscoverScreen() {
    const container = document.getElementById('discoverGroupsContainer');
    if (!container) return;

    const searchQuery = (document.getElementById('discoverSearchInput')?.value || '').toLowerCase().trim();

    let filtered = destinationGroups.filter(g => {
      const matchesSearch = !searchQuery || 
        g.destination.toLowerCase().includes(searchQuery) || 
        g.description.toLowerCase().includes(searchQuery);

      if (!matchesSearch) return false;

      if (selectedDiscoverFilter === 'All') return true;
      if (selectedDiscoverFilter === 'Ride available') return g.status === 'Ride available';
      if (selectedDiscoverFilter === 'Looking for a driver') return g.status === 'Looking for a driver';
      if (selectedDiscoverFilter === 'Groceries') return g.destinationCategory.toLowerCase().includes('grocer');
      if (selectedDiscoverFilter === 'Campus') return g.destinationCategory.toLowerCase().includes('campus');
      return true;
    });

    if (!filtered.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:30px 10px;">
          <span class="material-symbols-outlined" style="font-size:36px; color:var(--text-muted);">search_off</span>
          <p style="font-size:13px; color:var(--text-secondary); margin-top:6px;">No groups match your current filter.</p>
          <button class="btn-secondary-sm" onclick="document.getElementById('discoverSearchInput').value=''; window.AggieApp.resetDiscoverFilter();" style="margin-top:10px;">Reset Filter</button>
        </div>
      `;
      return;
    }

    container.innerHTML = filtered.map(group => createGroupCardHTML(group)).join('');

    container.querySelectorAll('.group-destination-card').forEach(card => {
      card.addEventListener('click', () => {
        const groupId = card.getAttribute('data-group-id');
        openGroupDetailsModal(groupId);
      });
    });
  }

  // ===================================================================
  // MY JOURNEYS RENDERING (Intentions, Groups, Upcoming, Offered)
  // ===================================================================
  function renderJourneysScreen() {
    renderMyIntentions();
    renderMyJoinedGroups();
    renderMyUpcomingRides();
    renderMyOfferedRides();
  }

  function openSubtabJourneys(subtabName) {
    activeSubtabJourneys = subtabName;
    document.querySelectorAll('.journey-subtab-btn').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-subtab') === subtabName);
    });

    document.querySelectorAll('.journey-subtab-content').forEach(content => {
      content.style.display = 'none';
    });

    const activeContent = document.getElementById(`subtab-content-${subtabName}`);
    if (activeContent) activeContent.style.display = 'block';
  }

  // 1. My Intentions
  function renderMyIntentions() {
    const container = document.getElementById('myIntentionsList');
    if (!container) return;

    const myIntentions = intentions.filter(i => i.userId === currentUser.userId);

    if (!myIntentions.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:36px 14px; background:var(--bg-card); border-radius:var(--radius-lg); border:1px solid rgba(80,0,0,0.06);">
          <span class="material-symbols-outlined" style="font-size:42px; color:var(--aggie-maroon); opacity:0.6;">alt_route</span>
          <h4 style="font-size:15px; font-weight:800; margin-top:8px;">No travel intentions yet</h4>
          <p style="font-size:12.5px; color:var(--text-secondary); margin:6px 0 14px 0;">Where are you planning to go this week? Post where you want to go, and we'll find your people!</p>
          <button class="btn-primary-intent" onclick="window.AggieApp.navigateToTab('home')">
            <span class="material-symbols-outlined" style="font-size:16px;">add</span> Post a travel intention
          </button>
        </div>
      `;
      return;
    }

    container.innerHTML = myIntentions.map(intent => `
      <div class="journey-card">
        <div class="journey-card-header">
          <div>
            <div class="journey-dest-text">${intent.destination}</div>
            <div class="journey-time-sub">
              <span class="material-symbols-outlined" style="font-size:13px; vertical-align:middle; color:var(--aggie-maroon);">event</span>
              ${intent.preferredDate} • ${intent.preferredTime} (${intent.flexibility})
            </div>
            <div class="journey-time-sub">
              <span class="material-symbols-outlined" style="font-size:13px; vertical-align:middle; color:var(--aggie-maroon);">pin_drop</span>
              Pickup: ${intent.preferredPickupZone || intent.startingArea}
            </div>
          </div>
          <span class="group-status-badge status-interest">${intent.status}</span>
        </div>

        ${intent.note ? `<p style="font-size:12px; color:var(--text-secondary); margin:6px 0;">"${intent.note}"</p>` : ''}

        <div class="journey-action-row">
          ${intent.matchedGroupId ? `
            <button class="btn-secondary-sm view-matched-group-btn" data-group-id="${intent.matchedGroupId}">
              View Destination Group
            </button>
          ` : ''}
          <button class="btn-danger-sm withdraw-intent-btn" data-intent-id="${intent.intentionId}">
            Withdraw Intention
          </button>
        </div>
      </div>
    `).join('');

    container.querySelectorAll('.view-matched-group-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const gid = btn.getAttribute('data-group-id');
        openGroupDetailsModal(gid);
      });
    });

    container.querySelectorAll('.withdraw-intent-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const id = btn.getAttribute('data-intent-id');
        intentions = intentions.filter(i => i.intentionId !== id);
        saveData();
        showToast('Travel intention withdrawn.', 'delete');
        renderMyIntentions();
      });
    });
  }

  // 2. Joined Destination Groups
  function renderMyJoinedGroups() {
    const container = document.getElementById('myJoinedGroupsList');
    if (!container) return;

    const joinedGroups = destinationGroups.filter(g => 
      (g.participants || []).some(p => p.userId === currentUser.userId)
    );

    if (!joinedGroups.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:30px 14px; background:var(--bg-card); border-radius:var(--radius-lg); border:1px solid rgba(80,0,0,0.06);">
          <span class="material-symbols-outlined" style="font-size:36px; color:var(--text-muted);">group_off</span>
          <p style="font-size:13px; color:var(--text-secondary); margin:8px 0 12px 0;">You haven't joined any destination groups yet.</p>
          <button class="btn-secondary-sm" onclick="window.AggieApp.navigateToTab('discover')">Browse Groups</button>
        </div>
      `;
      return;
    }

    container.innerHTML = joinedGroups.map(group => `
      <div class="journey-card">
        <div class="journey-card-header">
          <div>
            <div class="journey-dest-text">${group.destination}</div>
            <div class="journey-time-sub">${group.dateLabel} • ${group.timeWindow}</div>
          </div>
          <span class="group-status-badge status-available">${group.status}</span>
        </div>

        <div style="font-size:11.5px; color:var(--text-secondary); margin:6px 0;">
          ${group.interestedCount} Aggies participating • ${group.driversCount} Drivers offering seats
        </div>

        <div class="journey-action-row">
          <button class="btn-secondary-sm view-group-btn" data-group-id="${group.groupId}">
            View Details
          </button>
          <button class="btn-danger-sm leave-group-btn" data-group-id="${group.groupId}">
            Leave Group
          </button>
        </div>
      </div>
    `).join('');

    container.querySelectorAll('.view-group-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        openGroupDetailsModal(btn.getAttribute('data-group-id'));
      });
    });

    container.querySelectorAll('.leave-group-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const gid = btn.getAttribute('data-group-id');
        leaveDestinationGroup(gid);
      });
    });
  }

  // 3. Upcoming Rides (Passenger Bookings)
  function renderMyUpcomingRides() {
    const container = document.getElementById('myUpcomingRidesList');
    if (!container) return;

    // Requests created by currentUser
    const myRequests = requests.filter(r => r.passengerId === currentUser.userId);

    if (!myRequests.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:30px 14px; background:var(--bg-card); border-radius:var(--radius-lg); border:1px solid rgba(80,0,0,0.06);">
          <span class="material-symbols-outlined" style="font-size:36px; color:var(--text-muted);">commute</span>
          <p style="font-size:13px; color:var(--text-secondary); margin:8px 0 12px 0;">No active ride requests or upcoming rides.</p>
          <button class="btn-secondary-sm" onclick="window.AggieApp.navigateToTab('discover')">Explore Rides Available</button>
        </div>
      `;
      return;
    }

    container.innerHTML = myRequests.map(req => {
      const ride = rides.find(r => r.rideId === req.rideId);
      const driver = users.find(u => u.userId === req.driverId);
      const isAccepted = req.status === 'ACCEPTED';

      return `
        <div class="journey-card">
          <div class="journey-card-header">
            <div>
              <div class="journey-dest-text">${ride ? ride.destination : 'Destination Ride'}</div>
              <div class="journey-time-sub">Driver: <strong>${driver ? driver.name : 'Aggie Driver'}</strong> • Departure: ${ride ? ride.departureTime : 'TBD'}</div>
            </div>
            <span class="group-status-badge ${isAccepted ? 'status-confirmed' : 'status-looking'}">
              ${isAccepted ? 'Confirmed Ride' : 'Request Pending'}
            </span>
          </div>

          <!-- Boarding Pass if Confirmed -->
          ${isAccepted ? `
            <div class="boarding-pass-badge">
              <div>
                <div style="font-size:10px; font-weight:700; color:#1E40AF; text-transform:uppercase;">Boarding OTP Code</div>
                <div class="otp-display">${req.otp || 'AG-7193'}</div>
                <div style="font-size:10.5px; color:#3B82F6;">Show this code to driver at pickup</div>
              </div>
              <div style="text-align:right;">
                <div style="font-size:10.5px; font-weight:700;">Meeting Zone</div>
                <div style="font-size:12px; font-weight:800; color:var(--aggie-maroon);">${req.pickupZone}</div>
              </div>
            </div>
          ` : `
            <p style="font-size:12px; color:var(--text-secondary); margin:6px 0;">
              Waiting for driver confirmation. Meeting point requested: <strong>${req.pickupZone}</strong>.
            </p>
          `}

          <div class="journey-action-row">
            <button class="btn-secondary-sm msg-driver-btn" data-driver-id="${req.driverId}">
              <span class="material-symbols-outlined" style="font-size:14px; vertical-align:middle;">chat</span>
              Message Driver
            </button>
            <button class="btn-danger-sm cancel-request-btn" data-req-id="${req.requestId}">
              Cancel Request
            </button>
          </div>
        </div>
      `;
    }).join('');

    container.querySelectorAll('.msg-driver-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const did = btn.getAttribute('data-driver-id');
        openOrCreateConversationWith(did);
      });
    });

    container.querySelectorAll('.cancel-request-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const rid = btn.getAttribute('data-req-id');
        cancelSeatRequest(rid);
      });
    });
  }

  // 4. Offered Rides (Drivers only)
  function renderMyOfferedRides() {
    const container = document.getElementById('myOfferedRidesList');
    if (!container) return;

    if (!currentUser.isDriverVerified) {
      container.innerHTML = `<p style="font-size:12px; color:var(--text-muted); text-align:center; padding:12px;">Only verified drivers can view offered rides.</p>`;
      return;
    }

    const myRides = rides.filter(r => r.driverId === currentUser.userId);

    if (!myRides.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:30px 14px; background:var(--bg-card); border-radius:var(--radius-lg); border:1px solid rgba(80,0,0,0.06);">
          <span class="material-symbols-outlined" style="font-size:36px; color:var(--aggie-maroon);">airline_seat_recline_extra</span>
          <p style="font-size:13px; color:var(--text-secondary); margin:8px 0 12px 0;">You have not offered any rides yet.</p>
          <button class="btn-primary-intent" id="openOfferModalEmptyBtn">
            <span class="material-symbols-outlined" style="font-size:16px;">add</span> Offer seats to a group
          </button>
        </div>
      `;
      const btn = document.getElementById('openOfferModalEmptyBtn');
      if (btn) btn.addEventListener('click', openOfferRideModal);
      return;
    }

    container.innerHTML = myRides.map(ride => {
      // Find passenger requests for this ride
      const incomingRequests = requests.filter(r => r.rideId === ride.rideId);
      const pendingReqs = incomingRequests.filter(r => r.status === 'PENDING');

      return `
        <div class="journey-card">
          <div class="journey-card-header">
            <div>
              <div class="journey-dest-text">${ride.destination}</div>
              <div class="journey-time-sub">
                <span class="material-symbols-outlined" style="font-size:13px; vertical-align:middle; color:var(--aggie-maroon);">schedule</span>
                ${ride.departureDate} at ${ride.departureTime}
              </div>
            </div>
            <span class="group-status-badge status-available">
              ${ride.availableSeats} of ${ride.totalSeats} seats left
            </span>
          </div>

          <div style="font-size:11.5px; color:var(--text-secondary); margin:6px 0;">
            Origin: ${ride.origin} • Pickup Zone: ${ride.selectedPickupZone || ride.pickupZones[0]}
          </div>

          <!-- Pending Requests Section -->
          ${pendingReqs.length ? `
            <div style="background:#FFFBEB; border:1px solid #FDE68A; border-radius:8px; padding:10px; margin:10px 0;">
              <div style="font-size:11.5px; font-weight:800; color:#B45309; margin-bottom:6px;">
                Incoming Passenger Requests (${pendingReqs.length})
              </div>
              ${pendingReqs.map(req => {
                const pass = users.find(u => u.userId === req.passengerId);
                return `
                  <div style="display:flex; justify-content:space-between; align-items:center; padding:6px 0; border-top:1px solid rgba(0,0,0,0.05);">
                    <div style="display:flex; align-items:center; gap:8px;">
                      <img src="${pass ? pass.avatar : ''}" style="width:28px; height:28px; border-radius:50%; object-fit:cover;">
                      <div>
                        <div style="font-size:12px; font-weight:700;">${pass ? pass.name : 'Passenger'}</div>
                        <div style="font-size:10.5px; color:var(--text-muted);">${req.pickupZone}</div>
                      </div>
                    </div>
                    <div style="display:flex; gap:6px;">
                      <button class="btn-primary-intent accept-req-btn" data-req-id="${req.requestId}" style="padding:4px 10px; font-size:11px;">Accept</button>
                      <button class="btn-danger-sm reject-req-btn" data-req-id="${req.requestId}" style="padding:4px 8px; font-size:11px;">Decline</button>
                    </div>
                  </div>
                `;
              }).join('')}
            </div>
          ` : `
            <div style="font-size:11px; color:var(--text-muted); margin:4px 0;">No pending passenger requests at this moment.</div>
          `}

          <div class="journey-action-row">
            <button class="btn-danger-sm cancel-offered-ride-btn" data-ride-id="${ride.rideId}">
              Cancel Ride
            </button>
          </div>
        </div>
      `;
    }).join('');

    container.querySelectorAll('.accept-req-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        acceptSeatRequest(btn.getAttribute('data-req-id'));
      });
    });

    container.querySelectorAll('.reject-req-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        rejectSeatRequest(btn.getAttribute('data-req-id'));
      });
    });

    container.querySelectorAll('.cancel-offered-ride-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        cancelOfferedRide(btn.getAttribute('data-ride-id'));
      });
    });
  }

  // ===================================================================
  // SEAT REQUEST & DRIVER ACCEPT/REJECT LOGIC
  // ===================================================================
  function acceptSeatRequest(requestId) {
    const req = requests.find(r => r.requestId === requestId);
    if (!req) return;

    const ride = rides.find(r => r.rideId === req.rideId);
    if (!ride) return;

    if (ride.availableSeats < req.seatsRequested) {
      showToast('No seats left on this ride!', 'error');
      return;
    }

    // Atomic state update
    req.status = 'ACCEPTED';
    req.otp = req.otp || `AG-${Math.floor(1000 + Math.random() * 9000)}`;
    ride.availableSeats = Math.max(0, ride.availableSeats - req.seatsRequested);

    // Update destination group
    const group = destinationGroups.find(g => g.groupId === ride.groupId);
    if (group) {
      group.confirmedSeatsAvailable = Math.max(0, group.confirmedSeatsAvailable - req.seatsRequested);
      if (group.confirmedSeatsAvailable === 0) {
        group.status = 'Ride filling up';
      }
      // Add or update participant role
      const part = (group.participants || []).find(p => p.userId === req.passengerId);
      if (part) {
        part.role = 'Confirmed Passenger';
      }
    }

    saveData();
    showToast(`Accepted seat request for ${req.pickupZone}!`, 'check_circle');
    renderAllViews();
  }

  function rejectSeatRequest(requestId) {
    const req = requests.find(r => r.requestId === requestId);
    if (!req) return;
    req.status = 'REJECTED';
    saveData();
    showToast('Seat request declined.', 'info');
    renderAllViews();
  }

  function cancelSeatRequest(requestId) {
    const req = requests.find(r => r.requestId === requestId);
    if (!req) return;

    // If was accepted, restore seat count
    if (req.status === 'ACCEPTED') {
      const ride = rides.find(r => r.rideId === req.rideId);
      if (ride) ride.availableSeats += req.seatsRequested;

      const group = destinationGroups.find(g => g.groupId === req.groupId);
      if (group) group.confirmedSeatsAvailable += req.seatsRequested;
    }

    requests = requests.filter(r => r.requestId !== requestId);
    saveData();
    showToast('Seat request cancelled.', 'cancel');
    renderAllViews();
  }

  function cancelOfferedRide(rideId) {
    rides = rides.filter(r => r.rideId !== rideId);
    // Remove related requests
    requests = requests.filter(r => r.rideId !== rideId);
    saveData();
    showToast('Offered ride cancelled.', 'delete');
    renderAllViews();
  }

  // ===================================================================
  // MESSAGING SYSTEM RENDERING (Clean, Private Airbnb/WhatsApp Style)
  // ===================================================================
  function renderMessagesScreen() {
    renderConversationsList();
  }

  function renderConversationsList() {
    const container = document.getElementById('conversationsListContainer');
    if (!container) return;

    // Filter conversations where currentUser is a participant
    const userConvs = conversations.filter(c => c.participants.includes(currentUser.userId));

    if (!userConvs.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:36px 14px; background:var(--bg-card); border-radius:var(--radius-lg); border:1px solid rgba(80,0,0,0.06);">
          <span class="material-symbols-outlined" style="font-size:38px; color:var(--text-muted);">chat</span>
          <p style="font-size:13px; color:var(--text-secondary); margin:8px 0;">No active chat threads yet.</p>
          <p style="font-size:11.5px; color:var(--text-muted);">When you express interest or request a seat, private ride coordination chats appear here.</p>
        </div>
      `;
      return;
    }

    container.innerHTML = userConvs.map(conv => {
      const partnerId = conv.participants.find(id => id !== currentUser.userId);
      const partner = users.find(u => u.userId === partnerId) || { name: 'Aggie Student', avatar: '' };
      const lastMsg = conv.messages[conv.messages.length - 1];
      const hasUnread = conv.messages.some(m => m.senderId !== currentUser.userId && !m.read);

      return `
        <div class="conversation-card" data-conv-id="${conv.conversationId}">
          <div class="conv-avatar-wrapper">
            <img src="${partner.avatar}" alt="${partner.name}">
            ${hasUnread ? `<span class="unread-dot"></span>` : ''}
          </div>
          <div class="conv-details">
            <div class="conv-top-row">
              <span class="conv-name">${partner.name}</span>
              <span class="conv-time">${lastMsg ? lastMsg.timestamp : ''}</span>
            </div>
            <div class="conv-last-msg">${lastMsg ? lastMsg.text : 'Start coordinating pickup...'}</div>
            ${conv.contextRide ? `
              <span class="conv-context-pill">
                ${conv.contextRide.destination} • ${conv.contextRide.dateTime}
              </span>
            ` : ''}
          </div>
        </div>
      `;
    }).join('');

    container.querySelectorAll('.conversation-card').forEach(card => {
      card.addEventListener('click', () => {
        const cid = card.getAttribute('data-conv-id');
        openChatRoom(cid);
      });
    });
  }

  function openChatRoom(conversationId) {
    activeConversationId = conversationId;
    const conv = conversations.find(c => c.conversationId === conversationId);
    if (!conv) return;

    // Mark messages as read
    conv.messages.forEach(m => {
      if (m.senderId !== currentUser.userId) m.read = true;
    });
    saveData();
    updateUnreadBadges();

    const partnerId = conv.participants.find(id => id !== currentUser.userId);
    const partner = users.find(u => u.userId === partnerId) || { name: 'Aggie Student' };

    // Update Header
    document.getElementById('chatPartnerName').textContent = partner.name;
    document.getElementById('chatPartnerAvatar').src = partner.avatar;
    document.getElementById('chatPartnerRole').textContent = partner.isDriverVerified ? 'Verified TAMU Driver' : 'Aggie Passenger';

    // Update Context Banner
    if (conv.contextRide) {
      document.getElementById('chatContextDestination').textContent = conv.contextRide.destination;
      document.getElementById('chatContextTime').textContent = `${conv.contextRide.dateTime} • ${conv.contextRide.pickupZone}`;
      document.getElementById('chatContextStatus').textContent = conv.contextRide.status || 'Active Journey';
    }

    // Render message bubbles
    renderChatMessages(conv);

    // Switch View
    document.getElementById('conversationsListView').style.display = 'none';
    document.getElementById('activeChatRoomView').style.display = 'flex';

    // Scroll to bottom
    const scroll = document.getElementById('chatMessagesScroll');
    if (scroll) scroll.scrollTop = scroll.scrollHeight;
  }

  function renderChatMessages(conv) {
    const scroll = document.getElementById('chatMessagesScroll');
    if (!scroll) return;

    scroll.innerHTML = conv.messages.map(msg => {
      const isSent = msg.senderId === currentUser.userId;
      return `
        <div class="chat-bubble ${isSent ? 'bubble-sent' : 'bubble-received'}">
          <div>${msg.text}</div>
          <div class="bubble-time">${msg.timestamp}</div>
        </div>
      `;
    }).join('');
  }

  function sendChatMessage() {
    const input = document.getElementById('chatTextInput');
    const text = input ? input.value.trim() : '';
    if (!text || !activeConversationId) return;

    const conv = conversations.find(c => c.conversationId === activeConversationId);
    if (!conv) return;

    const newMsg = {
      messageId: `msg-${Date.now()}`,
      senderId: currentUser.userId,
      text: text,
      timestamp: 'Just now',
      read: true
    };
    conv.messages.push(newMsg);
    input.value = '';
    saveData();

    renderChatMessages(conv);
    const scroll = document.getElementById('chatMessagesScroll');
    if (scroll) scroll.scrollTop = scroll.scrollHeight;
  }

  function openOrCreateConversationWith(targetUserId) {
    let conv = conversations.find(c => 
      c.participants.includes(currentUser.userId) && c.participants.includes(targetUserId)
    );

    if (!conv) {
      const targetUser = users.find(u => u.userId === targetUserId);
      conv = {
        conversationId: `conv-${Date.now()}`,
        participants: [currentUser.userId, targetUserId],
        contextRide: {
          destination: 'Shared Aggie Trip',
          dateTime: 'Upcoming',
          pickupZone: currentUser.startingArea || 'College Station',
          status: 'Direct Message'
        },
        messages: [
          {
            messageId: `msg-${Date.now()}`,
            senderId: currentUser.userId,
            text: `Howdy ${targetUser ? targetUser.name.split(' ')[0] : ''}! Would love to coordinate pickup.`,
            timestamp: 'Just now',
            read: true
          }
        ]
      };
      conversations.unshift(conv);
      saveData();
    }

    navigateToTab('messages');
    openChatRoom(conv.conversationId);
  }

  // ===================================================================
  // PROFILE SCREEN RENDERING (Driver Registration & Student Credentials)
  // ===================================================================
  function renderProfileScreen() {
    if (!currentUser) return;

    document.getElementById('profileAvatarImg').src = currentUser.avatar;
    document.getElementById('profileName').textContent = currentUser.name;
    document.getElementById('profileClassMajor').textContent = `${currentUser.classYear} • ${currentUser.major}`;
    document.getElementById('profileBio').textContent = currentUser.bio;
    document.getElementById('profileRidesJoined').textContent = currentUser.ridesJoinedCount || 0;
    document.getElementById('profileRidesOffered').textContent = currentUser.ridesOfferedCount || 0;
    document.getElementById('profileRating').textContent = `${currentUser.passengerRating || 4.9} ★`;

    // Verification Badge
    const verifyBox = document.getElementById('profileVerificationBadge');
    if (verifyBox) {
      if (currentUser.isTamuVerified) {
        verifyBox.innerHTML = `
          <span class="tamu-verified-badge">
            <span class="material-symbols-outlined" style="font-size:14px;">verified</span> TAMU Email Verified (@tamu.edu)
          </span>
        `;
      } else {
        verifyBox.innerHTML = `
          <span class="tamu-unverified-badge" id="triggerVerifyEmailBtn" title="Click to verify student email">
            <span class="material-symbols-outlined" style="font-size:14px;">mark_email_unread</span> Unverified • Tap to verify @tamu.edu
          </span>
        `;
        const btn = document.getElementById('triggerVerifyEmailBtn');
        if (btn) btn.addEventListener('click', openEmailVerifyModal);
      }
    }

    // Driver Section: Driver details if registered; or registration CTA if not
    const driverSec = document.getElementById('profileDriverSection');
    if (driverSec) {
      if (currentUser.isDriverVerified && currentUser.vehicle) {
        const v = currentUser.vehicle;
        driverSec.innerHTML = `
          <h5>
            <span class="material-symbols-outlined" style="font-size:16px;">verified_user</span>
            ${v.demoVerificationLabel || 'Demo Verified Driver'}
          </h5>
          <div class="driver-vehicle-card">
            <img src="${v.image || 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=200'}" alt="Vehicle">
            <div>
              <div style="font-size:13px; font-weight:800;">${v.year} ${v.make} ${v.model}</div>
              <div style="font-size:11px; color:var(--text-secondary);">${v.color} • ${v.seats} Passenger Seats</div>
              <div style="font-size:10.5px; color:var(--text-muted);">Plate: ${v.plate}</div>
            </div>
          </div>
          <div style="display:flex; justify-content:space-between; margin-top:8px; font-size:11px;">
            <span>Driver Rating: <strong>${currentUser.driverRating || 4.98} ★</strong></span>
            <span style="color:var(--status-available-color); font-weight:700;">Active Driving Status</span>
          </div>
        `;
      } else {
        driverSec.innerHTML = `
          <h5>
            <span class="material-symbols-outlined" style="font-size:16px;">directions_car</span>
            Driving to Campus or Groceries?
          </h5>
          <p style="font-size:11.5px; color:var(--text-secondary); margin:4px 0 10px 0;">
            Register as an Aggie driver to share empty seats, help fellow students, and build community trust.
          </p>
          <button class="btn-primary-intent" id="openDriverRegBtn" style="padding:8px 16px; font-size:12.5px; width:100%;">
            Register as Driver
          </button>
        `;
        const regBtn = document.getElementById('openDriverRegBtn');
        if (regBtn) regBtn.addEventListener('click', openDriverRegModal);
      }
    }

    // Interests
    const interestsList = document.getElementById('profileInterestsList');
    if (interestsList) {
      const userInterests = currentUser.interests || [];
      interestsList.innerHTML = userInterests.map(i => `
        <span class="interest-pill active" style="font-size:11px;">${i}</span>
      `).join('');
    }
  }

  // ===================================================================
  // MODALS & EVENT HANDLERS
  // ===================================================================
  function setupEventListeners() {
    // Brand click returns to Home
    const brand = document.getElementById('headerBrandClick');
    if (brand) brand.addEventListener('click', () => navigateToTab('home'));

    // Notification bell icon
    const notifBtn = document.getElementById('notificationBtn');
    if (notifBtn) notifBtn.addEventListener('click', () => {
      navigateToTab('messages');
    });

    // Profile avatar click
    const avatarBtn = document.getElementById('headerAvatarBtn');
    if (avatarBtn) avatarBtn.addEventListener('click', () => navigateToTab('profile'));

    // Bottom Navigation Tabs
    document.querySelectorAll('.nav-tab-item').forEach(btn => {
      btn.addEventListener('click', () => {
        const tab = btn.getAttribute('data-tab');
        navigateToTab(tab);
      });
    });

    // Evaluator Persona Switcher
    const select = document.getElementById('evaluatorUserSelect');
    if (select) {
      select.addEventListener('change', (e) => {
        switchUser(e.target.value);
      });
    }

    // View Mode Toggle (Mobile chassis vs Fullscreen)
    const viewBtn = document.getElementById('toggleViewModeBtn');
    if (viewBtn) {
      viewBtn.addEventListener('click', () => {
        document.body.classList.toggle('fullscreen-mode');
        showToast(
          document.body.classList.contains('fullscreen-mode') ? 'Expanded to full-width view' : 'Restored mobile phone frame',
          'aspect_ratio'
        );
      });
    }

    // Reset Demo Button
    const resetBtn = document.getElementById('resetDataBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', () => {
        if (confirm('Reset all demo state to pristine initial values?')) {
          localStorage.clear();
          loadOrSeedData(true);
          renderAllViews();
          showToast('Demo data reset to clean initial state.', 'restart_alt');
        }
      });
    }

    // Evaluator Quick Flow Buttons
    document.querySelectorAll('.flow-guide-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const flowId = btn.getAttribute('data-flow');
        executeEvaluatorFlow(flowId);
      });
    });

    // Aggie Fact Next Button
    const nextFact = document.getElementById('nextFactBtn');
    if (nextFact) nextFact.addEventListener('click', () => cycleFact(1));

    // Travel Intention Form Submit
    const intentForm = document.getElementById('travelIntentForm');
    if (intentForm) intentForm.addEventListener('submit', handleTravelIntentSubmit);

    // Subtle flexible intention link
    const flexLink = document.getElementById('flexibleIntentLink');
    if (flexLink) flexLink.addEventListener('click', () => {
      const flexSelect = document.getElementById('intentFlexibilitySelect');
      if (flexSelect) flexSelect.value = 'Anytime afternoon';
      showToast('Set time window to flexible anytime afternoon.', 'schedule');
    });

    // Driver Offer FAB
    const driverFab = document.getElementById('driverOfferFab');
    if (driverFab) driverFab.addEventListener('click', openOfferRideModal);

    // Driver Banner Offer Button
    const bannerBtn = document.getElementById('driverBannerOfferBtn');
    if (bannerBtn) bannerBtn.addEventListener('click', openOfferRideModal);

    // My Journeys Subtabs
    document.querySelectorAll('.journey-subtab-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const sub = btn.getAttribute('data-subtab');
        openSubtabJourneys(sub);
      });
    });

    // Back to conversations list from chat
    const backBtn = document.getElementById('backToConversationsBtn');
    if (backBtn) {
      backBtn.addEventListener('click', () => {
        document.getElementById('activeChatRoomView').style.display = 'none';
        document.getElementById('conversationsListView').style.display = 'block';
        activeConversationId = null;
        renderConversationsList();
      });
    }

    // Chat Message Form
    const chatForm = document.getElementById('chatMessageForm');
    if (chatForm) chatForm.addEventListener('submit', sendChatMessage);

    // Discover Search Input
    const discoverSearch = document.getElementById('discoverSearchInput');
    if (discoverSearch) {
      discoverSearch.addEventListener('input', renderDiscoverScreen);
    }

    // Discover Filter Chips
    document.querySelectorAll('#discoverFilterRow .flow-chip').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#discoverFilterRow .flow-chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        selectedDiscoverFilter = btn.getAttribute('data-filter');
        renderDiscoverScreen();
      });
    });

    // Close Modal Buttons
    setupModalCloseButtons();

    // Modals: Forms
    const offerForm = document.getElementById('offerRideForm');
    if (offerForm) offerForm.addEventListener('submit', handlePublishOfferedRide);

    const driverRegForm = document.getElementById('driverRegForm');
    if (driverRegForm) driverRegForm.addEventListener('submit', handleDriverRegistration);

    const verifyOtpBtn = document.getElementById('submitVerifyOtpBtn');
    if (verifyOtpBtn) verifyOtpBtn.addEventListener('click', handleVerifyOtp);

    // Top buttons: Pickup Zones & Tour
    const pickupBtn = document.getElementById('openPickupMapBtn');
    if (pickupBtn) pickupBtn.addEventListener('click', openPickupMapModal);

    const tourBtn = document.getElementById('openTourBtn');
    if (tourBtn) tourBtn.addEventListener('click', openTourFactsModal);

    // Persona Selection Modal Triggers
    const openPersonaBtn = document.getElementById('openPersonaModalBtn');
    if (openPersonaBtn) openPersonaBtn.addEventListener('click', openPersonaSelectModal);

    const storyChooseBtn = document.getElementById('storyChoosePersonaBtn');
    if (storyChooseBtn) storyChooseBtn.addEventListener('click', openPersonaSelectModal);

    const storyInspectBtn = document.getElementById('storyInspectHubsBtn');
    if (storyInspectBtn) storyInspectBtn.addEventListener('click', openPickupMapModal);

    // Persona items selection
    document.querySelectorAll('.persona-choice-item').forEach(el => {
      el.addEventListener('click', () => {
        const uid = el.getAttribute('data-user');
        if (uid) {
          switchUser(uid);
          closePersonaSelectModal();
          sessionStorage.setItem('aggieride_persona_selected_session', 'true');
        }
      });
    });

    // Sidebar persona cards
    document.querySelectorAll('.persona-quick-select').forEach(el => {
      el.addEventListener('click', () => {
        const uid = el.getAttribute('data-user');
        if (uid) {
          switchUser(uid);
          const phone = document.querySelector('.showcase-phone-column');
          if (window.innerWidth <= 1100 && phone) {
            phone.scrollIntoView({ behavior: 'smooth' });
          }
        }
      });
    });
  }

  function openPersonaSelectModal() {
    const modal = document.getElementById('personaSelectModal');
    if (!modal) return;
    document.querySelectorAll('.persona-choice-item').forEach(item => {
      item.classList.toggle('active', item.getAttribute('data-user') === currentUser.userId);
    });
    modal.classList.add('active');
  }

  function closePersonaSelectModal() {
    const modal = document.getElementById('personaSelectModal');
    if (modal) modal.classList.remove('active');
  }

  function setupModalCloseButtons() {
    const bindClose = (btnId, modalId) => {
      const btn = document.getElementById(btnId);
      if (btn) {
        btn.addEventListener('click', () => {
          const modal = document.getElementById(modalId);
          if (modal) modal.classList.remove('active');
        });
      }
    };

    bindClose('closeGroupModalBtn', 'groupDetailModal');
    bindClose('closeRequestModalBtn', 'requestSeatModal');
    bindClose('closeOfferModalBtn', 'offerRideModal');
    bindClose('closeDriverRegModalBtn', 'driverRegisterModal');
    bindClose('closePickupMapBtn', 'pickupMapModal');
    bindClose('closeTourFactsBtn', 'tourFactsModal');
    bindClose('closeEmailVerifyBtn', 'emailVerifyModal');
    bindClose('closePersonaSelectBtn', 'personaSelectModal');
    bindClose('delightDismissBtn', 'delightModal');

    const viewGroupDelightBtn = document.getElementById('delightViewGroupBtn');
    if (viewGroupDelightBtn) {
      viewGroupDelightBtn.addEventListener('click', () => {
        document.getElementById('delightModal').classList.remove('active');
        const gid = viewGroupDelightBtn.getAttribute('data-group-id') || 'group-walmart-sat';
        openGroupDetailsModal(gid);
      });
    }
  }

  // Handle Travel Intention Submission (Primary Core Feature)
  function handleTravelIntentSubmit() {
    const destInput = document.getElementById('intentDestinationInput');
    const pickupInput = document.getElementById('intentPickupZoneSelect');
    const dateInput = document.getElementById('intentDateSelect');
    const timeInput = document.getElementById('intentTimeInput');
    const flexInput = document.getElementById('intentFlexibilitySelect');
    const passInput = document.getElementById('intentPassengersSelect');

    const destination = destInput ? destInput.value.trim() : '';
    if (!destination) {
      showToast('Please enter where you want to go!', 'info');
      return;
    }

    const pickupZone = pickupInput ? pickupInput.value : 'Park West Apartments';
    const date = dateInput ? dateInput.value : 'Saturday, Nov 8';
    const time = timeInput ? timeInput.value : '11:00 AM';
    const flex = flexInput ? flexInput.value : '±1 hour';
    const passengers = passInput ? parseInt(passInput.value) : 1;

    // Check if an existing destination group matches this destination
    let matchedGroup = destinationGroups.find(g => 
      g.destination.toLowerCase().includes(destination.toLowerCase()) || 
      destination.toLowerCase().includes(g.destination.toLowerCase())
    );

    // If no existing group, create a community demand group
    if (!matchedGroup) {
      matchedGroup = {
        groupId: `group-${Date.now()}`,
        destination: destination,
        destinationCategory: 'Community Trip',
        dateLabel: date,
        timeWindow: `${time} (${flex})`,
        interestedCount: 1,
        driversCount: 0,
        confirmedSeatsAvailable: 0,
        status: 'Gathering interest',
        popularPickupZones: [pickupZone],
        description: `Community travel group heading to ${destination}. Open for fellow Aggies to join and drivers to offer rides!`,
        participants: [
          {
            userId: currentUser.userId,
            name: currentUser.name,
            role: 'Interested Passenger',
            avatar: currentUser.avatar,
            startingArea: pickupZone
          }
        ],
        primaryRideId: null
      };
      destinationGroups.unshift(matchedGroup);
    } else {
      // Add current user to group participants if not already
      const alreadyIn = (matchedGroup.participants || []).some(p => p.userId === currentUser.userId);
      if (!alreadyIn) {
        matchedGroup.participants.push({
          userId: currentUser.userId,
          name: currentUser.name,
          role: 'Interested Passenger',
          avatar: currentUser.avatar,
          startingArea: pickupZone
        });
        matchedGroup.interestedCount += 1;
      }
    }

    // Save intention
    const newIntention = {
      intentionId: `intent-${Date.now()}`,
      userId: currentUser.userId,
      destination: destination,
      startingArea: pickupZone,
      preferredPickupZone: pickupZone,
      preferredDate: date,
      preferredTime: time,
      flexibility: flex,
      passengersCount: passengers,
      note: 'Looking forward to riding together!',
      status: matchedGroup.driversCount > 0 ? 'Matched with Group' : 'Gathering interest',
      matchedGroupId: matchedGroup.groupId,
      createdAt: new Date().toISOString()
    };
    intentions.unshift(newIntention);
    saveData();

    // Trigger Delight Confirmation Modal
    const delightModal = document.getElementById('delightModal');
    const delightSubtitle = document.getElementById('delightSubtitle');
    const delightDestName = document.getElementById('delightDestinationName');
    const delightDetails = document.getElementById('delightGroupDetails');
    const viewBtn = document.getElementById('delightViewGroupBtn');

    if (delightSubtitle) {
      delightSubtitle.textContent = `${matchedGroup.interestedCount} Aggies are heading to ${destination}! We've connected you with their travel group.`;
    }
    if (delightDestName) delightDestName.textContent = matchedGroup.destination;
    if (delightDetails) {
      delightDetails.textContent = `${matchedGroup.dateLabel} • ${matchedGroup.driversCount} Drivers offering seats`;
    }
    if (viewBtn) {
      viewBtn.setAttribute('data-group-id', matchedGroup.groupId);
    }

    if (delightModal) delightModal.classList.add('active');
    renderAllViews();
  }

  // Open Destination Group Details Modal
  function openGroupDetailsModal(groupId) {
    const group = destinationGroups.find(g => g.groupId === groupId);
    if (!group) return;

    const modal = document.getElementById('groupDetailModal');
    if (!modal) return;

    document.getElementById('modalGroupStatus').textContent = group.status;
    document.getElementById('modalGroupStatus').className = `group-status-badge status-${group.status === 'Ride available' ? 'available' : group.status === 'Looking for a driver' ? 'looking' : 'filling'}`;
    document.getElementById('modalGroupDestination').textContent = group.destination;
    document.getElementById('modalGroupTime').textContent = `${group.dateLabel} • ${group.timeWindow}`;
    document.getElementById('modalGroupDescription').textContent = group.description;

    document.getElementById('modalInterestedCount').textContent = group.interestedCount;
    document.getElementById('modalDriversCount').textContent = group.driversCount;
    document.getElementById('modalSeatsCount').textContent = group.confirmedSeatsAvailable;

    // Pickup zones
    const zonesList = document.getElementById('modalPickupZonesList');
    if (zonesList) {
      const zones = group.popularPickupZones || ['MSC', 'Park West', 'Northgate'];
      zonesList.innerHTML = zones.map(z => `
        <span class="flow-chip" style="font-size:11px; background:#fff; color:var(--text-main); border-color:var(--aggie-maroon-border);">
          <span class="material-symbols-outlined" style="font-size:13px; color:var(--aggie-maroon); vertical-align:middle;">pin_drop</span>
          ${z}
        </span>
      `).join('');
    }

    // Participants list
    const partsList = document.getElementById('modalParticipantsList');
    if (partsList) {
      const parts = group.participants || [];
      partsList.innerHTML = parts.map(p => `
        <div style="display:flex; justify-content:space-between; align-items:center; padding:6px 8px; background:var(--bg-subtle); border-radius:8px;">
          <div style="display:flex; align-items:center; gap:8px;">
            <img src="${p.avatar}" style="width:30px; height:30px; border-radius:50%; object-fit:cover;">
            <div>
              <div style="font-size:12.5px; font-weight:700;">${p.name} ${p.userId === currentUser.userId ? '(You)' : ''}</div>
              <div style="font-size:11px; color:var(--text-secondary);">${p.startingArea || 'College Station'}</div>
            </div>
          </div>
          <span style="font-size:11px; font-weight:700; color:var(--aggie-maroon);">${p.role}</span>
        </div>
      `).join('');
    }

    // Dynamic Action Buttons
    const actionRow = document.getElementById('modalGroupActionButtons');
    if (actionRow) {
      const isParticipant = (group.participants || []).some(p => p.userId === currentUser.userId);
      const isDriver = currentUser.isDriverVerified;

      let buttonsHTML = '';

      // If user is a driver, allow offering a ride to this group
      if (isDriver) {
        buttonsHTML += `
          <button class="btn-primary-intent" id="modalOfferRideToGroupBtn" style="flex:1;">
            <span class="material-symbols-outlined" style="font-size:16px;">add_circle</span> Offer Seats to Group
          </button>
        `;
      }

      // If group has open driver seats and user is not a driver
      if (group.confirmedSeatsAvailable > 0 && !isDriver) {
        buttonsHTML += `
          <button class="btn-primary-intent" id="modalRequestSeatBtn" style="flex:1;">
            <span class="material-symbols-outlined" style="font-size:16px;">airline_seat_recline_normal</span> Request a Seat
          </button>
        `;
      }

      // Join / Leave Group button
      if (isParticipant) {
        buttonsHTML += `
          <button class="btn-danger-sm" id="modalLeaveGroupBtn" style="padding:10px 16px;">
            Leave Group
          </button>
        `;
      } else {
        buttonsHTML += `
          <button class="btn-secondary-sm" id="modalJoinGroupBtn" style="padding:10px 16px; flex:1;">
            <span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">person_add</span> Express Interest / Join
          </button>
        `;
      }

      actionRow.innerHTML = buttonsHTML;

      // Event bindings
      const reqBtn = document.getElementById('modalRequestSeatBtn');
      if (reqBtn) {
        reqBtn.addEventListener('click', () => {
          modal.classList.remove('active');
          openRequestSeatModal(group);
        });
      }

      const offerBtn = document.getElementById('modalOfferRideToGroupBtn');
      if (offerBtn) {
        offerBtn.addEventListener('click', () => {
          modal.classList.remove('active');
          openOfferRideModalWithDestination(group.destination, group.groupId);
        });
      }

      const joinBtn = document.getElementById('modalJoinGroupBtn');
      if (joinBtn) {
        joinBtn.addEventListener('click', () => {
          joinDestinationGroup(group.groupId);
          openGroupDetailsModal(group.groupId);
        });
      }

      const leaveBtn = document.getElementById('modalLeaveGroupBtn');
      if (leaveBtn) {
        leaveBtn.addEventListener('click', () => {
          leaveDestinationGroup(group.groupId);
          openGroupDetailsModal(group.groupId);
        });
      }
    }

    modal.classList.add('active');
  }

  function joinDestinationGroup(groupId) {
    const group = destinationGroups.find(g => g.groupId === groupId);
    if (!group) return;

    const alreadyIn = (group.participants || []).some(p => p.userId === currentUser.userId);
    if (!alreadyIn) {
      group.participants = group.participants || [];
      group.participants.push({
        userId: currentUser.userId,
        name: currentUser.name,
        role: 'Interested Passenger',
        avatar: currentUser.avatar,
        startingArea: currentUser.startingArea || 'Park West Apartments'
      });
      group.interestedCount += 1;
      saveData();
      showToast(`Joined ${group.destination} travel group!`, 'check_circle');
      renderAllViews();
    }
  }

  function leaveDestinationGroup(groupId) {
    const group = destinationGroups.find(g => g.groupId === groupId);
    if (!group) return;

    group.participants = (group.participants || []).filter(p => p.userId !== currentUser.userId);
    group.interestedCount = Math.max(0, group.interestedCount - 1);
    saveData();
    showToast('Left travel group.', 'info');
    renderAllViews();
  }

  // Open Request Seat Modal
  function openRequestSeatModal(group) {
    const modal = document.getElementById('requestSeatModal');
    if (!modal) return;

    document.getElementById('requestModalSubtitle').textContent = `Request a seat for ${group.destination}`;

    const select = document.getElementById('requestPickupZoneSelect');
    if (select) {
      const zones = group.popularPickupZones && group.popularPickupZones.length ? group.popularPickupZones : ['Park West Apartments', 'MSC / Rudder Plaza'];
      select.innerHTML = zones.map(z => `<option value="${z}">${z}</option>`).join('');
    }

    const form = document.getElementById('requestSeatForm');
    if (form) {
      form.onsubmit = () => {
        const selectedZone = select ? select.value : 'Park West Apartments';
        const msg = document.getElementById('requestMessageInput')?.value || 'Howdy! Would love to join!';

        // Find primary ride for group or first driver
        const ride = rides.find(r => r.groupId === group.groupId) || rides[0];

        const newReq = {
          requestId: `req-${Date.now()}`,
          rideId: ride.rideId,
          groupId: group.groupId,
          passengerId: currentUser.userId,
          driverId: ride.driverId,
          seatsRequested: 1,
          pickupZone: selectedZone,
          status: 'PENDING',
          message: msg,
          requestedAt: new Date().toISOString(),
          otp: `AG-${Math.floor(1000 + Math.random() * 9000)}`
        };

        requests.unshift(newReq);
        saveData();

        modal.classList.remove('active');
        showToast('Seat request sent to driver!', 'send');
        navigateToTab('journeys');
        openSubtabJourneys('upcoming');
        renderAllViews();
        return false;
      };
    }

    modal.classList.add('active');
  }

  // Open Offer Ride Modal (For Drivers Only)
  function openOfferRideModal() {
    if (!currentUser.isDriverVerified) {
      showToast('You must register as a driver first.', 'lock');
      navigateToTab('profile');
      return;
    }
    const modal = document.getElementById('offerRideModal');
    if (modal) modal.classList.add('active');
  }

  function openOfferRideModalWithDestination(destination, groupId) {
    openOfferRideModal();
    const destInput = document.getElementById('offerDestinationInput');
    if (destInput) destInput.value = destination;
  }

  function handlePublishOfferedRide() {
    const origin = document.getElementById('offerOriginInput')?.value || 'Northgate';
    const dest = document.getElementById('offerDestinationInput')?.value || 'Walmart';
    const date = document.getElementById('offerDateInput')?.value || 'Saturday, Nov 8';
    const time = document.getElementById('offerTimeInput')?.value || '11:00 AM';
    const seats = parseInt(document.getElementById('offerSeatsInput')?.value || '3');
    const contrib = parseInt(document.getElementById('offerContributionInput')?.value || '0');
    const notes = document.getElementById('offerNotesInput')?.value || 'Aggies ride free!';

    // Find or create matching group
    let group = destinationGroups.find(g => g.destination.toLowerCase().includes(dest.toLowerCase()));
    if (!group) {
      group = {
        groupId: `group-${Date.now()}`,
        destination: dest,
        destinationCategory: 'General Trip',
        dateLabel: date,
        timeWindow: time,
        interestedCount: 1,
        driversCount: 1,
        confirmedSeatsAvailable: seats,
        status: 'Ride available',
        popularPickupZones: [origin],
        description: `Ride offered by ${currentUser.name}. ${notes}`,
        participants: [
          {
            userId: currentUser.userId,
            name: currentUser.name,
            role: `Driver (${seats} seats left)`,
            avatar: currentUser.avatar,
            startingArea: origin
          }
        ],
        primaryRideId: null
      };
      destinationGroups.unshift(group);
    } else {
      group.driversCount += 1;
      group.confirmedSeatsAvailable += seats;
      group.status = 'Ride available';
      group.participants = group.participants || [];
      group.participants.push({
        userId: currentUser.userId,
        name: currentUser.name,
        role: `Driver (${seats} seats left)`,
        avatar: currentUser.avatar,
        startingArea: origin
      });
    }

    const newRide = {
      rideId: `ride-${Date.now()}`,
      driverId: currentUser.userId,
      groupId: group.groupId,
      origin: origin,
      destination: dest,
      departureDate: date,
      departureTime: time,
      availableSeats: seats,
      totalSeats: seats,
      pickupZones: [origin, 'Park West Apartments'],
      selectedPickupZone: origin,
      contribution: contrib,
      note: notes,
      status: 'ACTIVE',
      otpCode: `AG-${Math.floor(1000 + Math.random() * 9000)}`
    };

    rides.unshift(newRide);
    currentUser.ridesOfferedCount = (currentUser.ridesOfferedCount || 0) + 1;
    saveData();

    document.getElementById('offerRideModal').classList.remove('active');
    showToast(`Published ride to ${dest} with ${seats} seats!`, 'directions_car');
    navigateToTab('journeys');
    openSubtabJourneys('offered');
    renderAllViews();
  }

  // Handle Driver Registration (Through Profile)
  function handleDriverRegistration() {
    const make = document.getElementById('regVehicleMake')?.value || 'Toyota Corolla';
    const color = document.getElementById('regVehicleColor')?.value || 'Maroon (2023)';
    const seats = parseInt(document.getElementById('regSeatsSelect')?.value || '3');
    const plate = 'TX • ' + Math.floor(1000 + Math.random() * 9000);

    currentUser.isDriverVerified = true;
    currentUser.driverStatus = 'VERIFIED_DEMO';
    currentUser.driverRating = 5.0;
    currentUser.vehicle = {
      make: make.split(' ')[0],
      model: make.split(' ').slice(1).join(' ') || 'Corolla',
      year: 2023,
      color: color,
      plate: plate,
      seats: seats,
      licenceExpiry: '2028-10',
      image: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400',
      demoVerificationLabel: 'Demo Verified Driver'
    };

    saveData();
    document.getElementById('driverRegisterModal').classList.remove('active');
    showToast('Driver registration complete! You can now offer rides.', 'verified');
    renderAllViews();
  }

  function openDriverRegModal() {
    const modal = document.getElementById('driverRegisterModal');
    if (modal) modal.classList.add('active');
  }

  // Handle Sarah Chen Email Verification OTP
  function openEmailVerifyModal() {
    const modal = document.getElementById('emailVerifyModal');
    if (modal) modal.classList.add('active');
  }

  function handleVerifyOtp() {
    const input = document.getElementById('verifyOtpInput');
    const val = input ? input.value.trim() : '';

    if (val === '1876' || val.length >= 4) {
      currentUser.isTamuVerified = true;
      saveData();
      document.getElementById('emailVerifyModal').classList.remove('active');
      showToast('Student status verified via @tamu.edu email!', 'verified');
      renderProfileScreen();
    } else {
      showToast('Invalid demo OTP. Please enter 1876', 'error');
    }
  }

  // Open 7 Shared Pickup Zones Modal (Section 5)
  function openPickupMapModal() {
    const modal = document.getElementById('pickupMapModal');
    const list = document.getElementById('pickupZonesDetailsList');
    if (!modal || !list) return;

    list.innerHTML = (window.INITIAL_PICKUP_ZONES || []).map((zone, idx) => `
      <div style="background:var(--bg-subtle); border-radius:10px; padding:10px 12px; border:1px solid rgba(80,0,0,0.06);">
        <div style="display:flex; justify-content:space-between; align-items:baseline;">
          <strong style="font-size:13px; color:var(--text-main);">${idx + 1}. ${zone.name}</strong>
          <span style="font-size:11px; font-weight:700; color:var(--aggie-maroon);">${zone.walkingDistFromCampus}</span>
        </div>
        <div style="font-size:11.5px; color:var(--text-secondary); margin-top:2px;">${zone.address}</div>
        <div style="font-size:10.5px; color:#047857; font-weight:600; margin-top:3px;">
          <span class="material-symbols-outlined" style="font-size:12px; vertical-align:middle;">shield</span>
          ${zone.safetyRating}
        </div>
      </div>
    `).join('');

    modal.classList.add('active');
  }

  // Open Aggie Tour Facts Modal
  function openTourFactsModal() {
    const modal = document.getElementById('tourFactsModal');
    const list = document.getElementById('tourFactsFullList');
    if (!modal || !list) return;

    list.innerHTML = (window.INITIAL_TAMU_FACTS || []).map(f => `
      <div style="display:flex; gap:12px; background:var(--bg-subtle); padding:10px 12px; border-radius:10px; border:1px solid rgba(80,0,0,0.06);">
        <div class="fact-icon-wrapper" style="width:34px; height:34px;">
          <span class="material-symbols-outlined" style="font-size:18px;">${f.icon}</span>
        </div>
        <div>
          <strong style="font-size:13px;">${f.title}</strong>
          <p style="font-size:11.5px; color:var(--text-secondary); margin-top:2px;">${f.text}</p>
        </div>
      </div>
    `).join('');

    modal.classList.add('active');
  }

  // ===================================================================
  // 6 GUIDED DEMONSTRATION FLOWS FOR EVALUATORS & JUDGES
  // ===================================================================
  function executeEvaluatorFlow(flowId) {
    switch (flowId) {
      case 'flow1':
        // Flow 1: Express Travel Intent & Form Group (Carlos)
        switchUser('user-carlos');
        navigateToTab('home');
        document.getElementById('intentDestinationInput').value = 'Walmart Supercenter (Bryan / CS)';
        document.getElementById('intentPickupZoneSelect').value = 'Park West Apartments';
        document.getElementById('intentTimeInput').value = '11:00 AM';
        showToast('Step 1: Filled Carlos travel intention for Walmart Saturday 11 AM.', 'info');
        setTimeout(() => {
          handleTravelIntentSubmit();
        }, 600);
        break;

      case 'flow2':
        // Flow 2: Maya (Driver) offers seats to unmet demand group
        switchUser('user-maya');
        navigateToTab('home');
        showToast('Step 2: Maya logs in as verified driver with 2022 Honda Civic.', 'directions_car');
        setTimeout(() => {
          openOfferRideModal();
          document.getElementById('offerDestinationInput').value = 'Walmart Supercenter (Bryan / CS)';
          document.getElementById('offerOriginInput').value = 'Northgate / College Main';
        }, 500);
        break;

      case 'flow3':
        // Flow 3: Request & Accept Seat (Carlos & Maya)
        switchUser('user-maya');
        navigateToTab('journeys');
        openSubtabJourneys('offered');
        showToast('Step 3: Maya views Carlos pending seat request and accepts it!', 'handshake');
        setTimeout(() => {
          const firstReq = requests.find(r => r.driverId === 'user-maya' && r.status === 'PENDING');
          if (firstReq) {
            acceptSeatRequest(firstReq.requestId);
          } else {
            showToast('Request already accepted! Showing confirmed boarding OTP.', 'verified');
          }
        }, 600);
        break;

      case 'flow4':
        // Flow 4: Shared Pickup Zones & Walking Distances
        openPickupMapModal();
        showToast('Inspecting 7 predefined shared pickup zones in College Station.', 'pin_drop');
        break;

      case 'flow5':
        // Flow 5: Private Coordinated Messaging
        navigateToTab('messages');
        const firstConv = conversations[0];
        if (firstConv) {
          openChatRoom(firstConv.conversationId);
          showToast('Opened private pickup coordination chat between Carlos and Maya.', 'chat');
        }
        break;

      case 'flow6':
        // Flow 6: Event Carpooling (Makeathon at Zachry)
        switchUser('user-carlos');
        navigateToTab('home');
        showToast('Discovering TAMU Makeathon at Zachry Complex and forming carpool.', 'stars');
        setTimeout(() => {
          handleFindAggiesForEvent('event-makeathon');
        }, 600);
        break;

      case 'flow7':
        // Flow 7: Boarding Safety & OTP Verification (Carlos)
        switchUser('user-carlos');
        navigateToTab('journeys');
        openSubtabJourneys('upcoming');
        showToast('Safety Boarding Pass: Present OTP AG-7193 to Maya when boarding.', 'verified_user');
        break;
    }
  }

  // Public Interface
  window.AggieApp = {
    navigateToTab,
    switchUser,
    openGroupDetailsModal,
    openRequestSeatModal,
    openOfferRideModal,
    resetDiscoverFilter: () => {
      selectedDiscoverFilter = 'All';
      renderDiscoverScreen();
    }
  };

  // Launch application when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
