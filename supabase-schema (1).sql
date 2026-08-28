-- À exécuter une seule fois dans Supabase : Dashboard > SQL Editor > New query
-- Remplace la logique de window.storage (progression élèves + codes d'activation).

create table if not exists kv_store (
  key text not null,
  shared boolean not null default false,
  value text not null,
  updated_at timestamptz not null default now(),
  primary key (key, shared)
);

-- Active la sécurité au niveau des lignes (obligatoire sur Supabase)
alter table kv_store enable row level security;

-- ⚠️ Politiques volontairement permissives : n'importe qui possédant la clé
-- "anon" (publique par design) peut lire/écrire toutes les lignes.
-- C'est le même niveau de confiance que l'ancien système (pas de vraie
-- authentification par mot de passe pour les élèves, juste un prénom).
-- Si tu veux renforcer plus tard, il faudra ajouter une vraie authentification
-- Supabase Auth et des politiques RLS basées sur auth.uid().
create policy "allow anon select" on kv_store
  for select using (true);

create policy "allow anon insert" on kv_store
  for insert with check (true);

create policy "allow anon update" on kv_store
  for update using (true);

create policy "allow anon delete" on kv_store
  for delete using (true);
