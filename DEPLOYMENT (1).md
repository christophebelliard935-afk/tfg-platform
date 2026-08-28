# Déployer TFG — Préparation TCF en ligne

Ce dossier contient tout le nécessaire pour sortir le site de Claude.ai et le
mettre en ligne sur un vrai nom de domaine, avec stockage réel et IA fonctionnelle.

## Fichiers

- `index.html` — le site (déjà modifié pour pointer vers le proxy et l'adaptateur)
- `storage-adapter.js` — remplace `window.storage` par une vraie base Supabase
- `api/anthropic.js` — fonction serverless qui protège ta clé API Anthropic
- `supabase-schema.sql` — script pour créer la base de données
- `DEPLOYMENT.md` — ce guide

## Ce qui va coûter de l'argent

- **Supabase** : gratuit jusqu'à 500 Mo de base de données — largement suffisant ici
- **Vercel** : gratuit pour ce volume de trafic
- **API Anthropic** : facturé à l'usage (~2 000 FCFA/mois pour 250 corrections/générations, voir estimation précédente)
- **Nom de domaine** (optionnel) : ~5 000-15 000 FCFA/an selon le registrar

---

## Étape 1 — Créer le projet Supabase (base de données)

1. Va sur [supabase.com](https://supabase.com), crée un compte gratuit, puis "New project"
2. Une fois le projet créé, va dans **SQL Editor** (menu de gauche) → **New query**
3. Colle le contenu du fichier `supabase-schema.sql` et clique sur **Run**
4. Va dans **Project Settings > API** — note ces deux valeurs :
   - **Project URL** (ex: `https://abcdefgh.supabase.co`)
   - **Publishable key** (commence par `sb_publishable_...` — c'est la nouvelle appellation Supabase de l'ancienne « anon key »)
5. Ouvre `storage-adapter.js` et remplace :
   ```javascript
   const SUPABASE_URL = "https://TON-PROJET.supabase.co";
   const SUPABASE_ANON_KEY = "TA-CLE-ANON-ICI";
   ```
   par tes vraies valeurs.

## Étape 2 — Obtenir une clé API Anthropic

1. Va sur [platform.claude.com](https://platform.claude.com), crée un compte
2. Dans **Settings > API Keys**, crée une nouvelle clé (garde-la secrète, ne la mets JAMAIS dans `index.html` ou `storage-adapter.js`)
3. Ajoute un moyen de paiement pour activer la facturation à l'usage (nécessaire même avec les crédits gratuits de démarrage)

## Étape 3 — Déployer sur Vercel

1. Va sur [vercel.com](https://vercel.com), crée un compte gratuit (connexion possible avec GitHub)
2. Deux options :
   - **Sans GitHub (plus rapide)** : installe l'outil en ligne de commande Vercel (`npm i -g vercel`), puis dans ce dossier lance `vercel` et suis les instructions
   - **Avec GitHub (recommandé pour la suite)** : crée un dépôt GitHub, mets-y ces fichiers, puis sur Vercel clique "Add New Project" et importe ce dépôt
3. Une fois le projet créé sur Vercel, va dans **Settings > Environment Variables** et ajoute :
   - Nom : `ANTHROPIC_API_KEY`
   - Valeur : ta clé API Anthropic de l'étape 2
4. Redéploie le projet (Vercel le fait automatiquement après l'ajout de la variable, sinon clique "Redeploy")

## Étape 4 — Relier ton nom de domaine (optionnel)

Dans Vercel : **Settings > Domains** → ajoute ton nom de domaine et suis les instructions pour configurer les DNS chez ton registrar (souvent juste ajouter un enregistrement CNAME ou A).

## Étape 5 — Tester avant de partager le lien

Vérifie un par un, sur le site déployé (pas dans Claude.ai) :

- [ ] Connexion avec un prénom, puis rafraîchir la page → la session reste active tant que l'onglet est ouvert
- [ ] Faire un quiz, revenir plus tard avec le même prénom → le score est bien sauvegardé (teste la base Supabase)
- [ ] Lancer le simulateur d'expression écrite jusqu'au bout → la correction IA doit s'afficher (teste le proxy Anthropic)
- [ ] Générer un exercice IA sur un module → doit fonctionner (même proxy)
- [ ] Espace formateur → générer un code, l'utiliser sur un autre navigateur/appareil → doit débloquer la formule (teste le stockage partagé)

## Limites à connaître (héritées de la version Claude.ai)

- **Pas de vraie authentification** : la "connexion" par prénom seul reste identique — n'importe qui tapant le même prénom voit la même progression. Pour une vraie sécurité par compte, il faudrait ajouter Supabase Auth (email/mot de passe).
- **Politiques de base de données permissives** : `supabase-schema.sql` autorise n'importe qui possédant la clé publique (visible dans le code) à lire/écrire toutes les données. Acceptable pour un lancement modeste, à durcir si le site grossit.
- **Mot de passe de l'espace formateur** : toujours une simple chaîne dans le code source, pas une vraie sécurité.
- **Codes d'activation** : maintenant bien vérifiés contre la base Supabase (un seul usage par code), c'est une vraie amélioration par rapport à avant.
- **Paiement** : toujours manuel (Mobile Money + code fourni à la main), pas de paiement automatisé par carte. Une intégration future avec CinetPay ou Stripe permettrait d'automatiser complètement ce flux.
