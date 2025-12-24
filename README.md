# FiveM Speedometer Ultra-Optimisé

Speedometer standalone ultra-optimisé pour serveurs FiveM haute performance (200+ joueurs).

## 🚀 Optimisations Clés

### Client-side (client.lua)
- **Thread dynamique** : Wait(1000ms) à pied, Wait(500ms) véhicule arrêté, Wait(100ms) en mouvement
- **Diff-based updates** : SendNUIMessage uniquement si valeurs modifiées (seuil 0.1 km/h pour vitesse, 10 RPM)
- **Aucun thread actif hors véhicule** : Thread vérifie d'abord si le joueur est dans un véhicule
- **Calculs simples** : GetEntitySpeed uniquement, pas de calculs complexes
- **Cache des dernières valeurs** : Évite les updates NUI inutiles

### NUI (app.js)
- **Références DOM cachées** : Pas de querySelector répétés
- **requestAnimationFrame** : Mise à jour fluide de la jauge
- **Comparaisons avant update** : Vérifie si valeur a changé avant modification DOM
- **CSS will-change** : Optimisation GPU pour animations

### Design (style.css)
- **100% CSS** : Aucune image, tout en CSS pur
- **Glassmorphism** : backdrop-filter pour effet moderne
- **Transitions optimisées** : transform/opacity uniquement (GPU accelerated)

## 📦 Installation

1. Placer le dossier dans `/resources/`
2. Ajouter `ensure speedometer` dans `server.cfg`
3. Configurer `config.lua` selon vos besoins

## ⚙️ Configuration

Toutes les options sont dans `config.lua` :
- Unités (km/h ou mph)
- Affichage des éléments (RPM, Gear, Engine, Seatbelt)
- Position (bottom-left, bottom-right, bottom-center)
- Thème (dark, light)
- Taux de mise à jour

## 🎯 Performance

- **0.00 ms** en resmon client (idle, hors véhicule)
- **~0.01-0.02 ms** en resmon client (dans véhicule)
- Compatible OneSync
- Standalone (aucune dépendance)

