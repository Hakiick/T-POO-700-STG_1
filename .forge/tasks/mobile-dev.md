# Tâche : Clock WOW effect — Animation, feedback, timer temps réel

## Contexte
- Projet : /home/claude/workspace/T-POO-700-STG_1
- Branche : feat/clock/wow-effect
- US : #7 US-03: Clock WOW effect
- Stack : Vue.js 3 + Tailwind CSS + shadcn-vue

## Ce que tu dois faire

Transformer le bouton Clock In/Out en une expérience WOW avec animations, feedback visuel, et timer temps réel.

### 1. Animation WOW sur le bouton Clock In/Out

Le bouton actuel est un simple Card vert/rouge. Il faut le transformer en :

**A) Effet de pulse/ripple au clic :**
- Au clic, un cercle ripple qui s'étend depuis le point de clic (comme Material Design)
- Utilise CSS `@keyframes` + `transform: scale()` + `opacity` (GPU-accelerated)
- Le ripple doit s'adapter au thème (vert pour clock-in, rouge pour clock-out)

**B) Transition de couleur fluide :**
- Transition douce entre vert ↔ rouge (pas de changement brutal)
- Utilise `transition: background-color 0.5s ease-in-out`

**C) Animation de l'icône :**
- L'icône (☀️/🌙) doit faire une rotation + scale lors du changement d'état
- Remplacer les emojis par des SVG inline ou des icônes Lucide pour un look plus pro
- Animation : `transform: rotate(360deg) scale(1.2)` puis retour à normal

**D) Effet de succès après le clic :**
- Après la réponse API réussie : afficher un bref checkmark ✓ animé
- L'animation disparaît après 1.5s
- Si erreur API : petit shake animation

### 2. Feedback visuel pendant l'API call

**Loading state :**
- Pendant l'appel API (`clock_disable = true`) : afficher un spinner/pulse overlay sur le bouton
- Le bouton doit être visuellement désactivé (opacity réduite, cursor-not-allowed)
- Texte "Clocking in..." / "Clocking out..." pendant le chargement

**Success feedback :**
- Flash de confirmation (vert brillant ou checkmark)
- Haptic feedback si supporté (navigator.vibrate)

**Error feedback :**
- Shake animation sur le bouton
- Re-enable le bouton

### 3. Timer temps réel

**Le timer "Time worked" doit se mettre à jour chaque seconde quand l'utilisateur est clocked-in :**
- Ajouter un `setInterval` qui met à jour `workTime` toutes les secondes
- Format : `Xh Ym Zs` quand clocked-in (avec les secondes)
- Quand clocked-out : afficher le total statique en `Xh Ym`
- Nettoyer l'intervalle dans `onUnmounted`
- Aussi mettre à jour `workedHoursToday` toutes les minutes

### 4. Animations CSS dans Tailwind config

Ajouter les keyframes et animations nécessaires dans `tailwind.config.js` :
- `clock-pulse` : pulsation douce en boucle quand clocked-in
- `clock-ripple` : effet ripple au clic
- `clock-success` : flash de succès
- `clock-shake` : shake d'erreur
- `clock-spin` : rotation de l'icône

## Fichiers à modifier
- `frontend/src/components/Template.vue` — Composant principal à modifier
- `frontend/tailwind.config.js` — Ajouter les keyframes/animations
- `frontend/src/index.css` — Ajouter les styles CSS si nécessaire

## Critères d'acceptance
- [ ] Animation ripple visible au clic sur le bouton
- [ ] Transition fluide de couleur vert ↔ rouge
- [ ] Icône animée lors du changement d'état (rotation + scale)
- [ ] Feedback de succès (checkmark) après API success
- [ ] Feedback d'erreur (shake) après API error
- [ ] Loading state pendant l'appel API (spinner + texte)
- [ ] Timer temps réel qui met à jour chaque seconde quand clocked-in
- [ ] Animations GPU-accelerated (transform, opacity uniquement)
- [ ] Touch-friendly (min 44x44px maintenu)
- [ ] Pas de console.log en production
- [ ] Fonctionne sur mobile et desktop
- [ ] onUnmounted cleanup pour le timer

## Règles
- Respecte .claude/rules/
- Commite avec format feat(clock): description
- Ne touche PAS aux fichiers hors scope (pas d'API, pas de store, pas de router)
- Mobile-first CSS (styles de base = mobile, enrichis avec min-width)
- Animations GPU-accelerated uniquement (transform, opacity)
- Pas de librairie d'animation externe — utilise CSS natif + Tailwind
