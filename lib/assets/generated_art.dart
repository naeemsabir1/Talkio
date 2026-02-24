class GeneratedArt {
  // GOD TIER TAILORED GRAPHICS
  // Visuals specifically designed to match the text narrative.

  // 1. "Bare Minimum Required" -> The Lazy Learner
  // Concept: A relaxed figure floating/lounging, absorbing knowledge effortlessly.
  static const String guyReading = '''
<svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#EFF6FF"/>
      <stop offset="100%" stop-color="#DBEAFE"/>
    </linearGradient>
    <linearGradient id="beanbag" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#60A5FA"/>
      <stop offset="100%" stop-color="#2563EB"/>
    </linearGradient>
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
  </defs>
  
  <!-- The Beanbag / Lounging Spot -->
  <path d="M100 240 Q100 180 160 180 T260 200 Q300 240 280 280 H120 Q100 280 100 240" fill="url(#beanbag)"/>
  
  <!-- Stylized Figure (Relaxed) -->
  <circle cx="200" cy="160" r="25" fill="#1E293B"/> <!-- Head -->
  <path d="M180 190 Q200 240 240 220" stroke="#1E293B" stroke-width="18" stroke-linecap="round" fill="none"/> <!-- Body curve -->
  <path d="M210 210 L190 230" stroke="#1E293B" stroke-width="12" stroke-linecap="round"/> <!-- Arm holding phone -->
  
  <!-- The Phone -->
  <rect x="170" y="220" width="25" height="40" rx="4" fill="#3B82F6" transform="rotate(-30 180 230)"/>
  
  <!-- Magic Knowledge Flow (The "Osmosis" Effect) -->
  <path d="M180 220 Q150 150 200 130 T250 80" stroke="url(#beanbag)" stroke-width="3" fill="none" stroke-dasharray="4,6" filter="url(#glow)"/>
  <circle cx="250" cy="80" r="6" fill="#60A5FA" filter="url(#glow)"/>
  <circle cx="230" cy="100" r="4" fill="#93C5FD"/>
  <circle cx="210" cy="120" r="3" fill="#BFDBFE"/>
  
  <!-- Symbolic "Easy" Elements -->
  <text x="280" y="100" font-family="sans-serif" font-size="24" fill="#60A5FA" font-weight="bold">Zzz...</text>
</svg>
''';

  // 2. "Confusion to Clarity" -> The Lightbulb Moment
  // Concept: Dusty books on left dissolving into bright play button on right.
  static const String socialGirl = '''
<svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgSplit" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#F1F5F9"/> <!-- Grey side -->
      <stop offset="45%" stop-color="#F1F5F9"/>
      <stop offset="55%" stop-color="#EFF6FF"/> <!-- Bright side -->
      <stop offset="100%" stop-color="#EFF6FF"/>
    </linearGradient>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#FCD34D"/>
      <stop offset="100%" stop-color="#F59E0B"/>
    </linearGradient>
  </defs>
  
  <!-- LEFT: The Old Way (Confusing Textbooks) -->
  <g transform="translate(80, 100)">
    <rect x="0" y="40" width="60" height="80" fill="#94A3B8"/> <!-- Book 1 -->
    <rect x="5" y="40" width="5" height="80" fill="#CBD5E1"/> <!-- Spine -->
    <rect x="20" y="60" width="70" height="20" fill="#64748B" transform="rotate(-15 20 60)"/> <!-- Fallen Book -->
    <!-- Cobwebs / Confusion Lines -->
    <path d="M-10 20 L80 120" stroke="#CBD5E1" stroke-width="1"/>
    <path d="M80 20 L-10 120" stroke="#CBD5E1" stroke-width="1"/>
    <text x="10" y="20" font-family="sans-serif" font-size="20" fill="#94A3B8">???</text>
  </g>
  
  <!-- TRANSITION: Arrow -->
  <path d="M180 150 L220 150" stroke="#3B82F6" stroke-width="4" marker-end="url(#arrowhead)"/>
  
  <!-- RIGHT: The New Way (Clarity / Video) -->
  <g transform="translate(260, 100)">
    <circle cx="40" cy="50" r="50" fill="#DBEAFE"/>
    <circle cx="40" cy="50" r="40" fill="#3B82F6"/>
    <path d="M30 30 L60 50 L30 70 Z" fill="white"/> <!-- Play Icon -->
    
    <!-- Radiating Light / Sparkles -->
    <line x1="40" y1="-10" x2="40" y2="0" stroke="#F59E0B" stroke-width="3"/>
    <line x1="90" y1="50" x2="100" y2="50" stroke="#F59E0B" stroke-width="3"/>
    <line x1="-10" y1="50" x2="0" y2="50" stroke="#F59E0B" stroke-width="3"/>
    <line x1="40" y1="100" x2="40" y2="110" stroke="#F59E0B" stroke-width="3"/>
    
    <!-- Epiphany -->
    <text x="60" y="10" font-family="sans-serif" font-size="24" fill="#F59E0B" font-weight="bold">!</text>
  </g>
</svg>
''';

  // 3. "Ready to Start" -> The Gateway
  // Concept: An open door revealing a vibrant world.
  static const String wavingGirl = '''
<svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="portal" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3B82F6"/>
      <stop offset="50%" stop-color="#8B5CF6"/>
      <stop offset="100%" stop-color="#EC4899"/>
    </linearGradient>
  </defs>
  
  <!-- Floor Perspective -->
  <path d="M0 250 H400 L300 180 H100 L0 250" fill="#E2E8F0"/>
  
  <!-- Door Frame -->
  <rect x="140" y="60" width="120" height="220" fill="#1E293B"/> <!-- Outer -->
  <rect x="150" y="70" width="100" height="210" fill="url(#portal)"/> <!-- Inner Portal -->
  
  <!-- Elements inside Portal (The New World) -->
  <circle cx="200" cy="150" r="30" fill="white" fill-opacity="0.2"/>
  <path d="M170 200 Q200 180 230 200" stroke="white" stroke-width="2" fill="none"/>
  
  <!-- Person entering (Silhouette) -->
  <path d="M200 240 L210 280 H190 L200 240 Z" fill="#1E293B"/> <!-- Legs -->
  <circle cx="200" cy="200" r="15" fill="#1E293B"/> <!-- Body -->
  <circle cx="200" cy="175" r="8" fill="#1E293B"/> <!-- Head -->
  
  <!-- "Welcome" sparkles -->
  <circle cx="120" cy="100" r="5" fill="#3B82F6"/>
  <circle cx="280" cy="120" r="8" fill="#EC4899"/>
</svg>
''';

  // 4. "Can't find words" -> The Missing Piece
  // Concept: A speech bubble with a puzzle piece gap specifically.
  static const String thinkingGirl = '''
<svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bubbleGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#60A5FA"/>
      <stop offset="100%" stop-color="#3B82F6"/>
    </linearGradient>
  </defs>
  
  <!-- The Speech Bubble -->
  <path d="M100 80 H300 A20 20 0 0 1 320 100 V180 A20 20 0 0 1 300 200 H160 L120 240 V200 H100 A20 20 0 0 1 80 180 V100 A20 20 0 0 1 100 80 Z" 
        fill="url(#bubbleGrad)"/>
  
  <!-- Text Lines -->
  <rect x="120" y="110" width="160" height="15" rx="7.5" fill="white" fill-opacity="0.8"/>
  <rect x="120" y="140" width="100" height="15" rx="7.5" fill="white" fill-opacity="0.8"/>
  
  <!-- The Missing Piece Gap -->
  <rect x="230" y="140" width="50" height="15" rx="2" fill="#1E293B" fill-opacity="0.3"/> 
  <!-- Spinning/Waiting Loader metaphor -->
  <circle cx="255" cy="147.5" r="4" stroke="white" stroke-width="2" fill="none" stroke-dasharray="8 4"/>
  
  <!-- Frustration Symbol -->
  <text x="310" y="70" font-family="sans-serif" font-size="40" fill="#EF4444" font-weight="bold">?</text>
</svg>
''';

  static const String chartIllustration = '''
<svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <rect x="80" y="230" width="50" height="20" fill="#CBD5E1" rx="4"/>
  <rect x="160" y="180" width="50" height="70" fill="#94A3B8" rx="4"/>
  <rect x="240" y="60" width="60" height="190" fill="#2563EB" rx="6"/>
  <path d="M50 250 L100 230 L180 180 L270 60" stroke="#3B82F6" stroke-width="4" fill="none" stroke-linecap="round"/>
  <circle cx="270" cy="60" r="8" fill="#FFFFFF" stroke="#2563EB" stroke-width="3"/>
</svg>
''';

  static const String bellIcon = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#EFF6FF"/>
  <path d="M50 25 Q70 25 70 50 L80 75 H20 L30 50 Q30 25 50 25 Z" fill="#3B82F6" stroke="#1E40AF" stroke-width="2" stroke-linejoin="round"/>
  <circle cx="50" cy="82" r="6" fill="#1E40AF"/>
  <circle cx="75" cy="30" r="10" fill="#EF4444"/>
</svg>
''';

  static const String singingBird = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#E0F2FE"/>
  <path d="M35 65 Q35 40 55 40 Q75 40 75 60 L65 80 L45 80 Z" fill="#0EA5E9"/>
  <polygon points="75,50 85,45 80,55" fill="#F59E0B"/>
  <circle cx="60" cy="48" r="3" fill="white"/>
</svg>
''';

  static const String emptyMemo = '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="50" width="80" height="100" rx="8" fill="#F1F5F9" stroke="#E2E8F0" stroke-width="2"/>
  <path d="M80 80 H120 M80 100 H120 M80 120 H100" stroke="#CBD5E1" stroke-width="3" stroke-linecap="round"/>
</svg>
''';
}
