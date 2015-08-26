---
---
# Bulk Loading in Ehcache <a name="Bulk-Loading}


Ehcache has a bulk loading-mode that dramatically speeds up bulk loading into caches using the Terracotta Server Array (TSA). Bulk loading is designed to be used for:

*   cache warming - where caches need to be filled before bringing an application online
*   periodic batch loading - say an overnight batch process that uploads data

The bulk-loading API is available with [BigMemory Max](http://terracotta.org/products/bigmemorymax).
