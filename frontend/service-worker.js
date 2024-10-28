self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open("my-cache").then((cache) => {
      return cache.addAll([
        "/",
        "/index.html",
        "/styles.css",
        "/script.js",
        "/icons/icon-192x192.png",
        "/icons/icon-512x512.png",
      ]);
    }),
  );
  // console.log("Service Worker installing.");
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== "my-cache") {
            return caches.delete(cacheName);
          }
        }),
      );
    }),
  );
  //console.log('Service Worker activating.');
});

self.addEventListener("fetch", (event) => {
  const requestUrl = new URL(event.request.url);
  // console.log("Fetching:", requestUrl.href, "Scheme:", requestUrl.protocol);
  if (event.request.method !== "GET") return; // Only cache GET requests

  if (requestUrl.protocol === "http:" || requestUrl.protocol === "https:") {
    event.respondWith(
      caches.open("my-cache").then(async (cache) => {
        try {
          // Attempt to fetch the latest version from the network
          const networkResponse = await fetch(event.request);

          // Clone the network response for caching
          const clonedResponse = networkResponse.clone();

          // Update the cache with the latest network response
          cache.put(event.request, clonedResponse);

          // Return the network response to the client
          return networkResponse;
        } catch (error) {
          // If network request fails (e.g., offline), return cached response
          const cachedResponse = await cache.match(event.request);

          // Fallback to cache if it exists, otherwise a default offline page can be served
          return cachedResponse || caches.match("/index.html");
        }
      }),
    );
  }
});
