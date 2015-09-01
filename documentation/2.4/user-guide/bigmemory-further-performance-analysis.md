---
---
# BigMemory Further Performance Analysis

This page contains further performance results for off-heap store covering less common scenarios.


## 50% reads: 50% writes

In this scenario the `cache.put()` is called 50% of the time and `cache.get()` is called 50% of the time. 90% of
the time 70% of the keyset is selected - i.e. a very weak hot set. Other test settings are the same.
This scenario is therefore a very cache unfriendly which exacerbates GC problems. Therefore the on-heap store suffers badly
as seen in the charts. However the off-heap store retains it linear behaviour. Something else this test shows is that the
off-heap store does not suffer from fragmentation. On this last point, we did internal testing with a worst case scenario
for fragmentation where we constantly replace with randomly sized elements. The off-heap store also handles this situation
very well.


### Largest Full GC

![Ehcache Image](/images/documentation/offheap_fullgc_50.png)


### Latency

![Ehcache Image](/images/documentation/offheap_maxlatency_50.png)
![Ehcache Image](/images/documentation/offheap_latency_50.png)


### Throughput

![Ehcache Image](/images/documentation/offheap_tps_50.png)
