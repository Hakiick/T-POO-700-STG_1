# TimeManager — Rebuild Mobile-First

## Project overview

Rebuild complet du frontend de TimeManager, une application de gestion des heures de travail (clock in/out, équipes, overtime, dashboard admin). Le backend Elixir/Phoenix reste inchangé — on ne rebuild que le frontend Vue 3.

**Objectif portfolio** : Démontrer la maîtrise du responsive design, des animations fluides, du PWA, et de l'UX mobile-first sur un vrai projet full-stack de 275+ commits.

## Stack technique

- **Backend** : Elixir/Phoenix 1.7 + PostgreSQL (EXISTANT — NE PAS MODIFIER)
- **Frontend** : Vue 3.5 + TypeScript + Vite (à REBUILD mobile-first)
- **UI Components** : Radix Vue 1.9 (existant — adapter responsive)
- **State** : Pinia 2.2 (existant — garder)
- **Charts** : Unovis (existant — adapter responsive)
- **Styling** : Tailwind CSS 3 (existant — enrichir mobile-first)
- **Icons** : Lucide Vue (existant)
- **HTTP** : Axios (existant)
- **Tests** : Playwright (à configurer pour tests responsive multi-viewport)
- **PWA** : Service Worker + Manifest (existant basique — améliorer)

## Architecture cible (frontend/src/)

```
frontend/src/
├── components/
│   ├── ui/                 # Composants Radix Vue existants (adapter responsive)
│   ├── layout/             # MobileLayout, DesktopLayout, BottomTabBar, StickyHeader
│   ├── clock/              # ClockWidget radial animé, ClockHistory, ClockButton
│   ├── dashboard/          # StatCards animés, WeeklyChart, OvertimeIndicator
│   ├── team/               # TeamGrid, MemberCard, StatusBadge
│   ├── admin/              # ResponsiveTable, ManageModals, MobileFilters
│   ├── auth/               # LoginForm, RegisterForm, ConfirmFlow
│   └── shared/             # LoadingSkeleton, EmptyState, ErrorBoundary, OfflineBanner
├── composables/
│   ├── useMediaQuery.ts    # Détection de breakpoints
│   ├── useBreakpoint.ts    # Helper breakpoints nommés
│   ├── useOnline.ts        # Détection online/offline
│   ├── useSwipe.ts         # Gestion des gestes swipe
│   └── useAnimation.ts     # Helpers d'animation
├── layouts/
│   ├── MobileLayout.vue    # Layout avec BottomTabBar
│   ├── DesktopLayout.vue   # Layout avec Sidebar
│   └── AuthLayout.vue      # Layout pages auth (centré, minimal)
├── pages/
│   ├── Clock.vue           # Page clock in/out (WOW feature)
│   ├── Dashboard.vue       # Dashboard avec stats et graphiques
│   ├── Team.vue            # Vue équipe
│   ├── Admin.vue           # Panel admin
│   ├── Settings.vue        # Paramètres utilisateur
│   ├── Login.vue           # Connexion
│   └── Register.vue        # Inscription
├── styles/
│   ├── design-tokens.css   # Variables CSS (couleurs, spacing, typography)
│   └── animations.css      # Keyframes et classes d'animation
├── api/                    # EXISTANT — NE PAS MODIFIER
├── stores/                 # Pinia stores EXISTANTS — adapter si besoin
├── router.ts               # Adapter les routes
├── App.vue                 # Adapter avec layout switching
└── main.ts                 # Adapter
```

## User Stories

### Phase 1 — Foundation (haute priorité)

- [US-01] Design system mobile-first + setup | Configurer les design tokens responsive dans des variables CSS (couleurs, typographie fluid, espacements, ombres, border-radius). Enrichir tailwind.config.js avec les breakpoints mobile-first (sm:640, md:768, lg:1024, xl:1280, 2xl:1536). Créer les composants UI de base responsive : Button (3 tailles, touch-friendly), Card (avec variantes), Badge, Input (label flottant, 100% width mobile), Modal (fullscreen mobile, centered desktop). Créer les composables : useMediaQuery, useBreakpoint. Le design doit être moderne et professionnel — palette cohérente avec accent color vibrant pour l'effet WOW. | haute
  - Team: mobile-dev, stabilizer
  - Files: frontend/tailwind.config.js, frontend/src/styles/*, frontend/src/components/ui/*, frontend/src/composables/useMediaQuery.ts, frontend/src/composables/useBreakpoint.ts

- [US-02] Layout responsive + navigation mobile | Créer le système de layout dual : MobileLayout.vue avec BottomTabBar (5 onglets : Clock, Dashboard, Team, Admin, Settings — icônes Lucide, badge notification), DesktopLayout.vue avec Sidebar rétractable. StickyHeader avec avatar utilisateur et indicateur de statut. App.vue utilise useBreakpoint pour switcher dynamiquement entre les layouts. Transitions animées entre les pages (slide horizontal mobile, fade desktop). Le router.ts doit être adapté avec les nouvelles pages. | haute | après:US-01
  - Team: mobile-dev, responsive-tester, stabilizer
  - Files: frontend/src/layouts/*, frontend/src/components/layout/*, frontend/src/router.ts, frontend/src/App.vue

### Phase 2 — Core Features (haute priorité)

- [US-03] Clock In/Out mobile-first — WOW feature | C'est LA feature vitrine du portfolio. Créer ClockWidget.vue : cercle SVG radial animé montrant la progression de la journée en temps réel, gros bouton central one-tap clock in/out (min 64x64px) avec animation ripple + changement de couleur au tap, indicateur de statut coloré (vert = dans les heures normales, orange = proche overtime, rouge = overtime dépassé), compteur animé des heures travaillées aujourd'hui (count-up animation), historique scrollable des 5 derniers pointages avec timestamps. Tout doit être fluid et satisfying à utiliser sur mobile. | haute | après:US-02
  - Team: mobile-dev, stabilizer
  - Files: frontend/src/components/clock/*, frontend/src/pages/Clock.vue

- [US-04] Dashboard employé responsive | Stat cards animées en haut (heures aujourd'hui, cette semaine, ce mois, overtime cumulé) avec count-up animation à l'apparition. Graphique hebdomadaire responsive (Unovis bar chart, adapté mobile). Vue switchable semaine/mois avec swipe gesture ou tabs. Indicateur de progression vers objectif horaire. Skeleton loading states pendant le chargement. Tout lisible et fonctionnel sur un écran 375px. | haute | après:US-02
  - Team: mobile-dev, stabilizer
  - Files: frontend/src/components/dashboard/*, frontend/src/pages/Dashboard.vue

- [US-05] Gestion d'équipe mobile | Grille d'avatars responsive (2 colonnes mobile, 3 tablet, 4+ desktop) avec badge de statut temps réel (vert=clocké in, gris=clocké out, orange=en pause). Vue liste alternative pour mobile (toggle grid/list). Card membre avec : nom, rôle, heures aujourd'hui, dernier pointage. Pour les managers : section stats équipe en haut (membres actifs, heures totales, overtime). Filtre par statut (tous, actifs, absents). | haute | après:US-02
  - Team: mobile-dev, stabilizer
  - Files: frontend/src/components/team/*, frontend/src/pages/Team.vue

### Phase 3 — Admin + Auth (moyenne priorité)

- [US-06] Admin panel responsive | Tables admin adaptatives : sur mobile → cards empilées avec les infos clés visibles + expand pour détails. Sur desktop → table classique avec tri et pagination. Modals responsive : fullscreen avec slide-up sur mobile, centered avec backdrop sur desktop. Filtres en bottom sheet glissant sur mobile, sidebar sur desktop. Actions bulk adaptées au touch (checkboxes larges, swipe-to-action). | moyenne | après:US-05
  - Team: mobile-dev, stabilizer
  - Files: frontend/src/components/admin/*, frontend/src/pages/Admin.vue

- [US-07] Auth flow mobile-first | Pages login/register/confirm redesignées : layout centré avec illustration ou gradient en background. Inputs larges 100% width avec labels flottants. Validation inline en temps réel (feedback visuel immédiat). Gestion du clavier virtuel mobile (le formulaire remonte quand le clavier apparaît, pas de contenu caché). Bouton submit sticky en bas sur mobile. Animation de transition entre login et register. Message d'erreur toast en haut. | moyenne | après:US-01
  - Team: mobile-dev, stabilizer
  - Files: frontend/src/components/auth/*, frontend/src/pages/Login.vue, frontend/src/pages/Register.vue

### Phase 4 — PWA + Polish (moyenne priorité)

- [US-08] PWA complète | Améliorer le service worker existant : Cache First pour assets statiques (CSS, JS, images, fonts), Network First pour les appels API, Stale While Revalidate pour les avatars. Mode offline : queue les actions clock in/out en IndexedDB, sync automatique quand la connexion revient. Composant OfflineBanner.vue qui s'affiche en haut quand offline. Install prompt natif avec bouton custom élégant. manifest.json complet avec icônes 192px et 512px, splash screen, theme_color, background_color. Composable useOnline.ts pour détecter le statut réseau. | moyenne | après:US-03
  - Team: pwa-dev, stabilizer
  - Files: frontend/public/manifest.json, frontend/public/sw.js, frontend/src/composables/useOnline.ts, frontend/src/components/shared/OfflineBanner.vue

- [US-09] Animations et micro-interactions WOW | Ajouter partout des animations qui rendent l'app satisfying : transitions de page (slide-left/right sur mobile, crossfade sur desktop via Vue Router transitions), animation stagger sur les listes de cards (chaque card apparaît 50ms après la précédente), boutons avec feedback ripple au tap, compteurs animés (count-up de 0 à la valeur réelle), loading skeletons pulsants pendant le chargement, pull-to-refresh animation sur mobile (rotation spinner). TOUTES les animations doivent être GPU-accelerated : uniquement transform et opacity, JAMAIS width/height/top/left. 60fps obligatoire. | moyenne | après:US-04
  - Team: mobile-dev, stabilizer
  - Files: frontend/src/styles/animations.css, frontend/src/composables/useAnimation.ts, tous les composants

- [US-10] Polish responsive + accessibilité + Lighthouse | Audit complet de chaque composant : vérifier WCAG AA (contraste 4.5:1 texte, 3:1 grands textes), ajouter aria-label sur tous les boutons/icônes sans texte, ajouter role et aria-* sur les composants dynamiques, vérifier que le focus est visible et logique (tab order), touch targets >= 44x44px avec espacement suffisant. Tester chaque page sur 7 viewports : 375px, 390px, 430px, 768px, 1024px, 1280px, 1920px. Lighthouse > 90 sur les 4 métriques mobile. Dark mode si le temps le permet (bonus). Optimiser le bundle : lazy-load les routes, tree-shake les icônes, compression images. | moyenne | après:US-09
  - Team: responsive-tester, reviewer, stabilizer
  - Files: tous les composants frontend

## SEO & Performance cibles

- Viewport meta : `width=device-width, initial-scale=1, viewport-fit=cover`
- `100dvh` pour les layouts full-height
- `env(safe-area-inset-*)` pour les notchs iPhone
- Lighthouse mobile > 90 sur Performance, Accessibility, Best Practices, SEO
- Bundle < 200KB gzipped (initial load)
- LCP < 2.5s, FID < 100ms, CLS < 0.1
- Images lazy-loaded avec dimensions explicites
- Fonts preloaded
