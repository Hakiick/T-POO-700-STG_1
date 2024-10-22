const { default: axios } = require("axios");

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
  //console.log('Service Worker installing.');
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
  if (
    event.request.url.startsWith("chrome-extension") ||
    event.request.method !== "GET"
  ) {
    return;
  }

  event.respondWith(
    caches
      .match(event.request)
      .then((response) => {
        console.log(response);
        return (
          response ||
          axios(event.request).then((response) => {
            return caches.open("my-cache").then((cache) => {
              cache.put(event.request, response.clone());
              return response;
            });
          })
        );
      })
      .catch(() => {
        return caches.match("/index.html");
      }),
  );
  //console.log('Fetching:', event.request.url);
});
