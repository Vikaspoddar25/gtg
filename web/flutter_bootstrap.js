{{flutter_js}}
{{flutter_build_config}}

// Load Flutter WITHOUT its self-destructing service worker.
// Our custom sw.js (registered in index.html) handles PWA caching.
_flutter.loader.load();
