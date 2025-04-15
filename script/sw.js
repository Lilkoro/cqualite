const CACHE_NAME = "cql-cache-v1";

// Installer le service worker et mettre en cache les fichiers
self.addEventListener("install", (event) => {
  event.waitUntil(
    fetch('./sw.php') // Généré dynamiquement
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
      })
      .then((files) => {
        console.log("Files received:", files); // Vérifie que c'est un tableau d'URLs
        if (!Array.isArray(files)) {
          throw new Error("The fetched file list is not an array.");
        }
        caches.open(CACHE_NAME).then((cache) => {
          return Promise.all(
            files.map((file) =>
              cache.add(file).catch((err) => {
                console.warn(`Failed to cache ${file}:`, err);
              })
            )
          );
        });
      })  
      .catch((error) => {
        console.error("Failed to fetch file list:", error);
      })
  );
});


// Intercepter les requêtes et répondre avec le cache
self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});

// Activer le service worker et nettoyer les anciens caches
self.addEventListener("activate", (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheWhitelist.includes(cacheName)) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
