// AggieRide Seed Data — Texas A&M Student-Powered Mobility Network
// "Where Aggies go, Aggies ride."

// 1. ROTATING TEXAS A&M FACTS ("Did you know, Aggie?")
const INITIAL_TAMU_FACTS = [
  {
    title: "Established 1876",
    text: "Texas A&M opened in 1876 as Texas's very first public institution of higher education.",
    icon: "history_edu",
    tag: "History"
  },
  {
    title: "The 12th Man Tradition",
    text: "Born in 1922 when student E. King Gill stood ready to play if his team needed him. Over 102,733 Aggies stand today.",
    icon: "stadium",
    tag: "Tradition"
  },
  {
    title: "The Aggie Ring",
    text: "One of the most revered symbols in collegiate culture, worn with pride worldwide to signify shared heritage.",
    icon: "military_tech",
    tag: "Tradition"
  },
  {
    title: "Silver Taps & Muster",
    text: "Held the first Tuesday of each month in Academic Plaza, Silver Taps pays tribute to Aggies who passed away.",
    icon: "local_fire_department",
    tag: "Heritage"
  },
  {
    title: "Century Tree",
    text: "A majestic live oak in Academic Plaza where Aggies believe walking under it with someone seals lifelong bonds.",
    icon: "park",
    tag: "Campus"
  },
  {
    title: "Reveille — First Lady of Aggieland",
    text: "Reveille, a purebred Rough Collie, holds the highest rank in the Texas A&M Corps of Cadets: Cadet General.",
    icon: "pets",
    tag: "Mascot"
  }
];

// 2. PREDEFINED SHARED PICKUP ZONES AROUND COLLEGE STATION
// Predefined meeting points to avoid making drivers visit every single individual apartment door
const INITIAL_PICKUP_ZONES = [
  {
    zoneId: 'zone-msc',
    name: 'MSC / Rudder Plaza Vicinity',
    area: 'Central Campus',
    address: 'Memorial Student Center Turnaround, Joe Routt Blvd',
    walkingDistFromCampus: '2 min walk',
    lat: 30.6125,
    lng: -96.3415,
    safetyRating: 'Verified Safe • High Lighting & Emergency Callboxes',
    landmarks: 'Rudder Tower, MSC Flagpole, Bus Hub',
    description: 'Central campus pickup hub accessible from all academic buildings and on-campus residence halls.'
  },
  {
    zoneId: 'zone-northgate',
    name: 'Northgate / College Main',
    area: 'Northside Campus',
    address: 'College Main Bus Turnaround & University Dr',
    walkingDistFromCampus: '4 min walk',
    lat: 30.6225,
    lng: -96.3458,
    safetyRating: 'High Visibility • Pedestrian Protected Zone',
    landmarks: 'Traditions Bar, Northgate Garage, Dixie Chicken',
    description: 'Convenient meeting spot for students living in Northgate apartments, Cherry St lofts, and north campus.'
  },
  {
    zoneId: 'zone-univ-apts',
    name: 'University Apartments',
    area: 'East Campus',
    address: 'University Oaks & Hensel Park Entrance',
    walkingDistFromCampus: '8 min walk',
    lat: 30.6180,
    lng: -96.3310,
    safetyRating: 'Residential Well-Lit Area',
    landmarks: 'Hensel Park, Family Housing Office',
    description: 'East campus meeting point serving University Apartments, Oakwood, and East University Dr residents.'
  },
  {
    zoneId: 'zone-parkwest',
    name: 'Park West Apartments',
    area: 'Westside / George Bush Dr',
    address: 'Park West Tower 1 Porte-Cochère & Main Circle',
    walkingDistFromCampus: '10 min walk (or Bus 35/40)',
    lat: 30.6035,
    lng: -96.3542,
    safetyRating: 'Gated Roundabout • Covered Waiting Pavilions',
    landmarks: 'Tower 1 Lobby, Flats Courtyard, Leasing Center',
    description: 'Primary shared pickup location for thousands of Aggies living across Park West Towers and Flats.'
  },
  {
    zoneId: 'zone-whitecreek',
    name: 'White Creek Apartments',
    area: 'West Campus',
    address: 'White Creek Community Center Bus Stop',
    walkingDistFromCampus: '6 min walk',
    lat: 30.6020,
    lng: -96.3620,
    safetyRating: 'TAMU University Police Patrolled',
    landmarks: 'White Creek Activity Center, West Campus Fields',
    description: 'Serving West Campus undergraduates, Vet Med students, and White Creek living-learning communities.'
  },
  {
    zoneId: 'zone-gardens',
    name: 'The Gardens Apartments',
    area: 'South College Station',
    address: 'The Gardens Main Clubhouse, 200 Gardens Ave',
    walkingDistFromCampus: '12 min walk',
    lat: 30.5980,
    lng: -96.3400,
    safetyRating: 'Quiet Residential Loop • Good Illumination',
    landmarks: 'Clubhouse Circle, Central Mail Kiosk',
    description: 'Key southern neighborhood hub for students commuting from South College Station apartments.'
  },
  {
    zoneId: 'zone-century',
    name: 'Century Square',
    area: 'Shopping & Social District',
    address: 'Century Square Promenade / The George Hotel Valet Circle',
    walkingDistFromCampus: '7 min walk',
    lat: 30.6250,
    lng: -96.3410,
    safetyRating: 'Commercial Pedestrian Plaza • 24/7 Security',
    landmarks: 'Hopdoddy, Lucchese, The Green Lawn',
    description: 'Ideal meeting area for dinner trips, evening events, and social weekend getaways.'
  }
];

// 3. STUDENT PERSONAS (Texas A&M Verified Accounts)
const INITIAL_USERS = [
  {
    userId: 'user-carlos',
    name: 'Carlos Hernandez',
    classYear: "'26 (Sophomore)",
    major: 'Industrial Engineering',
    email: 'carlos.h@tamu.edu',
    isTamuVerified: true,
    isDriverVerified: false, // REGULAR STUDENT — CANNOT OFFER RIDES
    driverStatus: 'NONE',
    avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
    bio: 'Sophomore at Park West. No car this semester. Always on time, respectful passenger, and happy to share shopping tips!',
    startingArea: 'Park West Apartments',
    interests: ['Technology', 'Food', 'Gaming', 'Student organizations'],
    ridesJoinedCount: 14,
    ridesOfferedCount: 0,
    passengerRating: 4.95,
    reviewsCount: 12,
    vehicle: null
  },
  {
    userId: 'user-maya',
    name: 'Maya Reed',
    classYear: "'25 (Senior)",
    major: 'Computer Science',
    email: 'm.reed25@tamu.edu',
    isTamuVerified: true,
    isDriverVerified: true, // REGISTERED DRIVER — CAN OFFER RIDES
    driverStatus: 'VERIFIED_DEMO',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    bio: 'Senior CS student at TAMU. Frequent grocery runs to H-E-B & Walmart on weekends. Safe driver with clean Texas record!',
    startingArea: 'Northgate / Traditions',
    interests: ['Technology', 'Outdoor activities', 'Music', 'Food'],
    ridesJoinedCount: 4,
    ridesOfferedCount: 18,
    passengerRating: 4.9,
    driverRating: 4.98,
    reviewsCount: 16,
    vehicle: {
      make: 'Honda',
      model: 'Civic',
      year: 2022,
      color: 'White',
      plate: 'TX • AR-2022',
      seats: 3,
      licenceExpiry: '2028-08',
      image: 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=400&auto=format&fit=crop&q=80',
      demoVerificationLabel: 'Demo Verified Driver'
    }
  },
  {
    userId: 'user-sarah',
    name: 'Sarah Chen',
    classYear: "'27 (Freshman)",
    major: 'General Engineering',
    email: 'sarah.chen@tamu.edu',
    isTamuVerified: false, // Fresh student unverified for testing verification flow
    isDriverVerified: false,
    driverStatus: 'NONE',
    avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
    bio: 'Freshman at Hullabaloo Hall! Exploring College Station and looking for friendly Aggie carpool buddies.',
    startingArea: 'Hullabaloo Hall (Campus)',
    interests: ['Cultural events', 'Gaming', 'Music'],
    ridesJoinedCount: 1,
    ridesOfferedCount: 0,
    passengerRating: 5.0,
    reviewsCount: 1,
    vehicle: null
  },
  {
    userId: 'user-david',
    name: 'David Miller',
    classYear: "'24 (Graduate)",
    major: 'Mays Business School',
    email: 'd.miller@tamu.edu',
    isTamuVerified: true,
    isDriverVerified: true, // REGISTERED DRIVER
    driverStatus: 'VERIFIED_DEMO',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    bio: 'MBA student living at The Barracks. Head to H-E-B Jones Crossing and Costco weekly. Ample trunk space!',
    startingArea: 'The Barracks Townhomes',
    interests: ['Sports', 'Technology', 'Food'],
    ridesJoinedCount: 2,
    ridesOfferedCount: 31,
    passengerRating: 5.0,
    driverRating: 4.96,
    reviewsCount: 28,
    vehicle: {
      make: 'Toyota',
      model: 'RAV4',
      year: 2021,
      color: 'Silver',
      plate: 'TX • DM-8492',
      seats: 4,
      licenceExpiry: '2027-11',
      image: 'https://images.unsplash.com/photo-1581540222194-0def2dda95b8?w=400&auto=format&fit=crop&q=80',
      demoVerificationLabel: 'Demo Verified Driver'
    }
  },
  {
    userId: 'user-priya',
    name: 'Priya Patel',
    classYear: "'25 (Junior)",
    major: 'Biomedical Sciences',
    email: 'priya.patel@tamu.edu',
    isTamuVerified: true,
    isDriverVerified: true, // REGISTERED DRIVER
    driverStatus: 'VERIFIED_DEMO',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    bio: 'Junior pre-med Aggie! Regular trips to Target, CVS Pharmacy, and Post Oak Mall. Happy to give rides.',
    startingArea: 'University Apartments',
    interests: ['Food', 'Outdoor activities', 'Cultural events'],
    ridesJoinedCount: 5,
    ridesOfferedCount: 14,
    passengerRating: 4.9,
    driverRating: 4.94,
    reviewsCount: 11,
    vehicle: {
      make: 'Hyundai',
      model: 'Elantra',
      year: 2023,
      color: 'Maroon',
      plate: 'TX • PP-1234',
      seats: 3,
      licenceExpiry: '2029-03',
      image: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&auto=format&fit=crop&q=80',
      demoVerificationLabel: 'Demo Verified Driver'
    }
  }
];

// 4. STUDENT INTERESTS
const INITIAL_INTERESTS = [
  { id: 'tech', label: 'Technology', icon: 'laptop_mac' },
  { id: 'sports', label: 'Sports', icon: 'sports_football' },
  { id: 'food', label: 'Food', icon: 'restaurant' },
  { id: 'gaming', label: 'Gaming', icon: 'sports_esports' },
  { id: 'music', label: 'Music', icon: 'headphones' },
  { id: 'outdoors', label: 'Outdoor activities', icon: 'forest' },
  { id: 'culture', label: 'Cultural events', icon: 'theater_comedy' },
  { id: 'student_orgs', label: 'Student organizations', icon: 'groups' }
];

// 5. DESTINATION-BASED GROUPS ("Where Aggies are heading today")
// Critical Product Rule: Distinguish explicitly between:
// 1. Number of students interested
// 2. Number of drivers offering rides
// 3. Confirmed available seats
// 4. Whether the group has an actual confirmed ride!
// Statuses: Gathering interest, Looking for a driver, Ride available, Ride filling up, Confirmed
const INITIAL_DESTINATION_GROUPS = [
  {
    groupId: 'group-walmart-sat',
    destination: 'Walmart Supercenter (Bryan / CS)',
    destinationCategory: 'Groceries & Essentials',
    dateLabel: 'Saturday, Nov 8',
    timeWindow: '11:00 AM – 1:00 PM',
    interestedCount: 6,
    driversCount: 2,
    confirmedSeatsAvailable: 3,
    status: 'Ride available', // 'Ride available', 'Ride filling up', 'Looking for a driver', 'Gathering interest', 'Confirmed'
    statusColor: 'success',
    popularPickupZones: ['Park West Apartments', 'White Creek Apartments', 'The Gardens'],
    description: 'Weekly grocery run to Walmart. Maya and David are driving with trunk space for shopping bags.',
    participants: [
      { userId: 'user-carlos', name: 'Carlos Hernandez', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&auto=format&fit=crop&q=80', startingArea: 'Park West' },
      { userId: 'user-maya', name: 'Maya Reed', role: 'Driver (2 seats left)', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&auto=format&fit=crop&q=80', startingArea: 'Northgate' },
      { userId: 'user-david', name: 'David Miller', role: 'Driver (1 seat left)', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&auto=format&fit=crop&q=80', startingArea: 'The Barracks' },
      { userId: 'user-alex', name: 'Alex Morales', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=80&auto=format&fit=crop&q=80', startingArea: 'Park West' },
      { userId: 'user-emma', name: 'Emma Wilson', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=80&auto=format&fit=crop&q=80', startingArea: 'White Creek' },
      { userId: 'user-jordan', name: 'Jordan Lee', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=80&auto=format&fit=crop&q=80', startingArea: 'Park West' }
    ],
    primaryRideId: 'ride-maya-walmart'
  },
  {
    groupId: 'group-heb-today',
    destination: 'H-E-B (Jones Crossing / Wellborn Rd)',
    destinationCategory: 'Groceries',
    dateLabel: 'Today (Friday)',
    timeWindow: '4:00 PM – 6:00 PM',
    interestedCount: 4,
    driversCount: 0,
    confirmedSeatsAvailable: 0,
    status: 'Looking for a driver',
    statusColor: 'warning',
    popularPickupZones: ['MSC / Rudder Plaza', 'Hullabaloo Hall', 'University Apartments'],
    description: 'Students heading to H-E-B for dinner groceries. No driver has offered seats yet — open for any Aggie driving there!',
    participants: [
      { userId: 'user-sarah', name: 'Sarah Chen', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&auto=format&fit=crop&q=80', startingArea: 'Hullabaloo Hall' },
      { userId: 'user-kevin', name: 'Kevin Tran', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=80&auto=format&fit=crop&q=80', startingArea: 'MSC Plaza' },
      { userId: 'user-lucas', name: 'Lucas Scott', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&auto=format&fit=crop&q=80', startingArea: 'University Apts' },
      { userId: 'user-chloe', name: 'Chloe Adams', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80&auto=format&fit=crop&q=80', startingArea: 'Northgate' }
    ],
    primaryRideId: null
  },
  {
    groupId: 'group-downtown-bryan',
    destination: 'Downtown Bryan (First Friday & Cafes)',
    destinationCategory: 'Entertainment & Culture',
    dateLabel: 'Saturday Evening',
    timeWindow: '6:30 PM – 9:30 PM',
    interestedCount: 8,
    driversCount: 1,
    confirmedSeatsAvailable: 1,
    status: 'Ride filling up',
    statusColor: 'accent',
    popularPickupZones: ['Century Square', 'Northgate', 'MSC'],
    description: 'Heading to Downtown Bryan for dinner, live music, and dessert. Priya is driving 1 car with 1 seat remaining.',
    participants: [
      { userId: 'user-priya', name: 'Priya Patel', role: 'Driver (1 seat left)', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&auto=format&fit=crop&q=80', startingArea: 'University Apts' },
      { userId: 'user-sam', name: 'Sam Taylor', role: 'Confirmed Passenger', avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=80&auto=format&fit=crop&q=80', startingArea: 'Century Square' },
      { userId: 'user-mia', name: 'Mia Martinez', role: 'Confirmed Passenger', avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=80&auto=format&fit=crop&q=80', startingArea: 'Northgate' },
      { userId: 'user-liam', name: 'Liam Davies', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=80&auto=format&fit=crop&q=80', startingArea: 'MSC' },
      { userId: 'user-hannah', name: 'Hannah Wright', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&auto=format&fit=crop&q=80', startingArea: 'Park West' }
    ],
    primaryRideId: 'ride-priya-bryan'
  },
  {
    groupId: 'group-target-tomorrow',
    destination: 'Target (University Dr & 29th St)',
    destinationCategory: 'Shopping',
    dateLabel: 'Tomorrow Afternoon',
    timeWindow: '2:00 PM – 4:00 PM',
    interestedCount: 3,
    driversCount: 0,
    confirmedSeatsAvailable: 0,
    status: 'Gathering interest',
    statusColor: 'neutral',
    popularPickupZones: ['Park West Apartments', 'White Creek'],
    description: 'Planning a Target run for room decor, school supplies, and groceries. Express your interest to join!',
    participants: [
      { userId: 'user-carlos', name: 'Carlos Hernandez', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&auto=format&fit=crop&q=80', startingArea: 'Park West' },
      { userId: 'user-sarah', name: 'Sarah Chen', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&auto=format&fit=crop&q=80', startingArea: 'Hullabaloo Hall' },
      { userId: 'user-alex', name: 'Alex Morales', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=80&auto=format&fit=crop&q=80', startingArea: 'Park West' }
    ],
    primaryRideId: null
  },
  {
    groupId: 'group-costco-sun',
    destination: 'Costco Wholesale (Bryan Midtown / Hwy 6)',
    destinationCategory: 'Bulk Groceries',
    dateLabel: 'Sunday Morning',
    timeWindow: '10:30 AM – 12:00 PM',
    interestedCount: 5,
    driversCount: 1,
    confirmedSeatsAvailable: 2,
    status: 'Ride available',
    statusColor: 'success',
    popularPickupZones: ['The Barracks', 'The Gardens', 'University Apts'],
    description: 'Big bulk shopping run. David has an Executive Membership so passengers can shop together without their own card!',
    participants: [
      { userId: 'user-david', name: 'David Miller', role: 'Driver (2 seats left)', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&auto=format&fit=crop&q=80', startingArea: 'The Barracks' },
      { userId: 'user-rachel', name: 'Rachel Green', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&auto=format&fit=crop&q=80', startingArea: 'The Gardens' },
      { userId: 'user-tim', name: 'Tim Robinson', role: 'Interested Passenger', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&auto=format&fit=crop&q=80', startingArea: 'The Barracks' }
    ],
    primaryRideId: 'ride-david-costco'
  }
];

// 6. POPULAR DESTINATION SHORTCUTS (Home Screen Quick Chips)
const POPULAR_DESTINATIONS = [
  { name: 'Walmart', icon: 'shopping_bag', fullAddress: 'Walmart Supercenter (Bryan / CS)', category: 'Groceries' },
  { name: 'H-E-B', icon: 'local_grocery_store', fullAddress: 'H-E-B (Jones Crossing / Wellborn Rd)', category: 'Groceries' },
  { name: 'Target', icon: 'storefront', fullAddress: 'Target (University Dr & 29th St)', category: 'Shopping' },
  { name: 'Costco', icon: 'inventory_2', fullAddress: 'Costco Wholesale (Bryan Midtown)', category: 'Bulk' },
  { name: 'Pharmacy', icon: 'medication', fullAddress: 'CVS Pharmacy (Texas Ave & Holleman)', category: 'Health' },
  { name: 'Campus', icon: 'school', fullAddress: 'Texas A&M Campus (MSC / Rudder Plaza)', category: 'Campus' },
  { name: 'Downtown Bryan', icon: 'nightlife', fullAddress: 'Downtown Bryan Historic District', category: 'Culture' },
  { name: 'Restaurants', icon: 'restaurant', fullAddress: 'Century Square Dining & Cafes', category: 'Food' }
];

// 7. UPCOMING TAMU EVENTS ("What's happening around Aggieland?")
const INITIAL_EVENTS = [
  {
    eventId: 'event-makeathon',
    title: 'TAMU Makeathon 2026',
    date: 'Saturday, Nov 8',
    time: '9:00 AM – 9:00 PM',
    venue: 'Zachry Engineering Complex (ZACH)',
    category: 'Student Life',
    interestTag: 'Technology',
    image: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=500&auto=format&fit=crop&q=80',
    description: 'Annual flagship engineering build marathon at Zachry. Gather fellow engineers to carpool to the venue!',
    interestedCount: 38,
    activeDriversCount: 3,
    interestedUsers: [
      { userId: 'user-carlos', name: 'Carlos Hernandez', avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&auto=format&fit=crop&q=80' },
      { userId: 'user-maya', name: 'Maya Reed', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&auto=format&fit=crop&q=80' }
    ]
  },
  {
    eventId: 'event-basketball',
    title: "Aggie Men's Basketball vs. Texas",
    date: 'Wednesday, Nov 12',
    time: '7:00 PM',
    venue: 'Reed Arena (West Campus)',
    category: 'Athletics',
    interestTag: 'Sports',
    image: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500&auto=format&fit=crop&q=80',
    description: 'Lone Star rivalry showdown at Reed Arena! Skip the parking headache by sharing a ride from your apartment complex.',
    interestedCount: 64,
    activeDriversCount: 5,
    interestedUsers: [
      { userId: 'user-david', name: 'David Miller', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&auto=format&fit=crop&q=80' }
    ]
  },
  {
    eventId: 'event-concert',
    title: 'MSC Town Hall Fall Concert',
    date: 'Friday, Nov 14',
    time: '8:00 PM',
    venue: 'Rudder Auditorium',
    category: 'Arts & Culture',
    interestTag: 'Music',
    image: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
    description: 'Student musical showcase and special guest headliners hosted by MSC Town Hall at Rudder Theatre Complex.',
    interestedCount: 22,
    activeDriversCount: 2,
    interestedUsers: [
      { userId: 'user-sarah', name: 'Sarah Chen', avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&auto=format&fit=crop&q=80' }
    ]
  },
  {
    eventId: 'event-silvertaps',
    title: 'Silver Taps Memorial Ceremony',
    date: 'Tuesday, Dec 2',
    time: '10:30 PM',
    venue: 'Academic Plaza (TAMU Campus)',
    category: 'Tradition',
    interestTag: 'Cultural events',
    image: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=500&auto=format&fit=crop&q=80',
    description: 'Solemn tradition honoring fallen Aggies. Main campus lights are turned off for the buglers. Quiet carpools forming.',
    interestedCount: 45,
    activeDriversCount: 4,
    interestedUsers: [
      { userId: 'user-carlos', name: 'Carlos Hernandez', avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&auto=format&fit=crop&q=80' },
      { userId: 'user-maya', name: 'Maya Reed', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&auto=format&fit=crop&q=80' }
    ]
  }
];

// 8. STUDENT TRAVEL INTENTIONS (Primary Core Feature)
// Demand-first expressions of travel intent: Where & When students want to go
const INITIAL_INTENTIONS = [
  {
    intentionId: 'intent-carlos-walmart',
    userId: 'user-carlos',
    destination: 'Walmart Supercenter (Bryan / CS)',
    startingArea: 'Park West Apartments',
    preferredPickupZone: 'Park West Apartments',
    preferredDate: 'Saturday, Nov 8',
    preferredTime: '11:00 AM',
    flexibility: '±1 hour',
    passengersCount: 1,
    note: 'Weekly grocery run, need room for 2 shopping bags. Can meet at Tower 1 circle!',
    status: 'Matched with Group', // 'Gathering interest', 'Matched with Group', 'Driver offered ride'
    matchedGroupId: 'group-walmart-sat',
    createdAt: '2026-11-06T12:00:00Z'
  },
  {
    intentionId: 'intent-sarah-heb',
    userId: 'user-sarah',
    destination: 'H-E-B (Jones Crossing / Wellborn Rd)',
    startingArea: 'Hullabaloo Hall (Campus)',
    preferredPickupZone: 'MSC / Rudder Plaza Vicinity',
    preferredDate: 'Today (Friday)',
    preferredTime: '4:30 PM',
    flexibility: '±30 mins',
    passengersCount: 1,
    note: 'Freshman looking for dorm snacks and milk. Free all afternoon!',
    status: 'Looking for a driver',
    matchedGroupId: 'group-heb-today',
    createdAt: '2026-11-06T15:00:00Z'
  }
];

// 9. ACTIVE DRIVER RIDES (Offered by verified drivers to destination groups)
const INITIAL_RIDES = [
  {
    rideId: 'ride-maya-walmart',
    driverId: 'user-maya',
    groupId: 'group-walmart-sat',
    origin: 'Northgate / College Main',
    destination: 'Walmart Supercenter (Bryan / CS)',
    departureDate: 'Saturday, Nov 8',
    departureTime: '11:00 AM',
    availableSeats: 2,
    totalSeats: 3,
    pickupZones: ['Park West Apartments', 'White Creek Apartments'],
    selectedPickupZone: 'Park West Apartments',
    contribution: 2, // $2 optional fuel split
    note: 'Leaving from Northgate, stopping at Park West Tower 1 to pick up riders. Large trunk for groceries!',
    status: 'ACTIVE',
    otpCode: 'AG-7193'
  },
  {
    rideId: 'ride-david-costco',
    driverId: 'user-david',
    groupId: 'group-costco-sun',
    origin: 'The Barracks Townhomes',
    destination: 'Costco Wholesale (Bryan Midtown / Hwy 6)',
    departureDate: 'Sunday, Nov 9',
    departureTime: '10:30 AM',
    availableSeats: 2,
    totalSeats: 3,
    pickupZones: ['The Barracks', 'The Gardens Apartments'],
    selectedPickupZone: 'The Gardens Apartments',
    contribution: 3,
    note: 'Costco shopping trip. Executive member so you can check out with me. RAV4 has lots of storage.',
    status: 'ACTIVE',
    otpCode: 'AG-3920'
  },
  {
    rideId: 'ride-priya-bryan',
    driverId: 'user-priya',
    groupId: 'group-downtown-bryan',
    origin: 'University Apartments',
    destination: 'Downtown Bryan (First Friday & Cafes)',
    departureDate: 'Saturday Evening',
    departureTime: '6:30 PM',
    availableSeats: 1,
    totalSeats: 3,
    pickupZones: ['Century Square', 'Northgate / College Main'],
    selectedPickupZone: 'Century Square',
    contribution: 0, // Free
    note: 'Fun trip to First Friday! Dropping off near Queen Theatre. 1 seat left.',
    status: 'ACTIVE',
    otpCode: 'AG-5431'
  }
];

// 10. RIDE SEAT REQUESTS (Passengers requesting seats from drivers)
const INITIAL_REQUESTS = [
  {
    requestId: 'req-carlos-maya',
    rideId: 'ride-maya-walmart',
    groupId: 'group-walmart-sat',
    passengerId: 'user-carlos',
    driverId: 'user-maya',
    seatsRequested: 1,
    pickupZone: 'Park West Apartments',
    status: 'PENDING', // PENDING, ACCEPTED, REJECTED, CANCELLED
    message: 'Howdy Maya! Would love to join your ride to Walmart. I can meet you right at Park West Tower 1!',
    requestedAt: '2026-11-06T14:20:00Z',
    otp: 'AG-7193'
  }
];

// 11. MESSAGES & CONVERSATIONS
// Privacy first: phone numbers are hidden. Contextual ride pill at top of conversation.
const INITIAL_CONVERSATIONS = [
  {
    conversationId: 'conv-carlos-maya',
    participants: ['user-carlos', 'user-maya'],
    contextRide: {
      destination: 'Walmart Supercenter',
      dateTime: 'Sat, Nov 8 • 11:00 AM',
      pickupZone: 'Park West Tower 1',
      status: 'Seat Request Pending'
    },
    messages: [
      {
        messageId: 'msg-1',
        senderId: 'user-carlos',
        text: 'Howdy Maya! I just requested a seat for your Walmart trip on Saturday. Does Park West Tower 1 work for pickup?',
        timestamp: 'Yesterday, 2:21 PM',
        read: true
      },
      {
        messageId: 'msg-2',
        senderId: 'user-maya',
        text: 'Howdy Carlos! Yes, Tower 1 porte-cochère is right on my route down George Bush Dr. I will pull up in my white Civic around 11:05 AM!',
        timestamp: 'Yesterday, 2:45 PM',
        read: true
      },
      {
        messageId: 'msg-3',
        senderId: 'user-carlos',
        text: 'Awesome, thanks so much! Looking forward to it.',
        timestamp: 'Yesterday, 2:48 PM',
        read: true
      }
    ]
  },
  {
    conversationId: 'conv-carlos-priya',
    participants: ['user-carlos', 'user-priya'],
    contextRide: {
      destination: 'Downtown Bryan',
      dateTime: 'Sat Evening • 6:30 PM',
      pickupZone: 'Century Square',
      status: 'Inquiry'
    },
    messages: [
      {
        messageId: 'msg-4',
        senderId: 'user-carlos',
        text: 'Hey Priya, do you still have room for 1 more to Downtown Bryan?',
        timestamp: 'Today, 9:15 AM',
        read: false
      }
    ]
  }
];

// Universal browser and global access
if (typeof window !== 'undefined') {
  window.INITIAL_TAMU_FACTS = INITIAL_TAMU_FACTS;
  window.INITIAL_PICKUP_ZONES = INITIAL_PICKUP_ZONES;
  window.INITIAL_USERS = INITIAL_USERS;
  window.INITIAL_INTERESTS = INITIAL_INTERESTS;
  window.INITIAL_DESTINATION_GROUPS = INITIAL_DESTINATION_GROUPS;
  window.POPULAR_DESTINATIONS = POPULAR_DESTINATIONS;
  window.INITIAL_EVENTS = INITIAL_EVENTS;
  window.INITIAL_INTENTIONS = INITIAL_INTENTIONS;
  window.INITIAL_RIDES = INITIAL_RIDES;
  window.INITIAL_REQUESTS = INITIAL_REQUESTS;
  window.INITIAL_CONVERSATIONS = INITIAL_CONVERSATIONS;
}
