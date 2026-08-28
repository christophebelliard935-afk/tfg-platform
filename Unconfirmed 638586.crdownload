/**
 * Adaptateur de stockage — remplace window.storage (disponible uniquement
 * dans les artifacts Claude) par une vraie base de données Supabase.
 *
 * ⚠️ À CONFIGURER avant déploiement : remplace SUPABASE_URL par l'URL de ton
 * projet (voir DEPLOYMENT.md, étape 2). La clé "publishable" ci-dessous est
 * conçue pour être visible côté client — ce n'est PAS une clé secrète.
 */
const SUPABASE_URL = "https://cvcgkdcghnzwctimaeor.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_DtqfZ5x3A8HZftCdn2daUA_HNMEb-wp";

(function () {
  async function sbFetch(path, options = {}) {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
      ...options,
      headers: {
        // Le nouveau format de clé Supabase (sb_publishable_...) se transmet
        // uniquement via l'en-tête "apikey" — jamais via "Authorization: Bearer".
        apikey: SUPABASE_PUBLISHABLE_KEY,
        "Content-Type": "application/json",
        ...(options.headers || {}),
      },
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      throw new Error(`Supabase error ${res.status}: ${text}`);
    }
    return res;
  }

  window.storage = {
    async get(key, shared = false) {
      const res = await sbFetch(
        `kv_store?key=eq.${encodeURIComponent(key)}&shared=eq.${shared}&select=value`
      );
      const rows = await res.json();
      if (!rows.length) return null;
      return { key, value: rows[0].value, shared };
    },

    async set(key, value, shared = false) {
      await sbFetch(`kv_store`, {
        method: "POST",
        headers: { Prefer: "resolution=merge-duplicates" },
        body: JSON.stringify([{ key, value, shared }]),
      });
      return { key, value, shared };
    },

    async delete(key, shared = false) {
      await sbFetch(
        `kv_store?key=eq.${encodeURIComponent(key)}&shared=eq.${shared}`,
        { method: "DELETE" }
      );
      return { key, deleted: true, shared };
    },

    async list(prefix = "", shared = false) {
      const res = await sbFetch(
        `kv_store?key=like.${encodeURIComponent(prefix)}*&shared=eq.${shared}&select=key`
      );
      const rows = await res.json();
      return { keys: rows.map((r) => r.key), prefix, shared };
    },
  };
})();
