---
---
# Strategies For Setting Up WAN Replication

 

## Introduction
This page provides three strategies for configuring WAN replication.

## Problem

You have two sites for high availability and/or disaster recovery that remain in sync with one another. The two sites are located in geographically separate areas connected by a WAN link.

## Solutions

There are three mechanisms offered by Terracotta to replicate your Ehcache. This recipe highlights the general approach taken by each of these three solutions. It begins with the simplest but least reliable, and concludes with the most robust and comprehensive mechanism.

### Solution 1: Terracotta Active/Mirror Replication

This is the simplest configuration of the three solutions. In this solution, the approach is to simply use the built-in replication capabilities of the Terracotta Server Array.
In this solution, one Terracotta Server Array Instance is positioned in each data center. At any one moment only one Terracotta Server Instance is active.
This solution is ideal for data centers that are connected by a high-speed WAN link and maximum simplicity is required.

**Diagram of solution:**

![Built-in Terracotta Active/Passive WAN Replication](/images/documentation/Terracotta%20WAN%20Replication%201.png)

#### Characteristics

This solution has the following characteristics.

##### Reads

All reads are done from just the one active Terracotta Server Array Instance. This means that clients in data-center will read from the Terracotta Server Array using a LAN connection, and clients in the other data-center will read from the Terracotta Server Array using a WAN connection.

##### Writes

All writes are performed against just the one active Terracotta Server Array Instance. This means that one clients in one data-center will write to the Terracotta Server Array using a LAN connection, and clients in the other data-center will write to the Terracotta Server Array using a WAN connection.

#### Summary

**Pros:**

* Simple
* Easy to manage

**Cons:**

* Completely dependent on an ideal network connection.
* Even with a fast WAN connection (both high throughput and low-latency), latency issues are not unlikely as unexpected slowdowns in the network or within the cluster occur.
* Split-brain scenarios may occur due to interruptions in the network between the two servers.
* Slowdowns lead to stale data or long pauses for clients in Datacenter B.

### Solution 2: Transactional CacheManager Replication

This solution relies on Ehcache Transaction (JTA) support. In this configuration, two separate caches are created, each one is 'homed' to a specific data-center.

When a write is generated, it is written under a JTA transaction to ensure data integrity. The write is written to both caches, so that when the write completes, each data-center specific cache will have a copy of the write.

This solution trades off some write performance for high read performance. Executing a client level JTA transaction can result in slower performance than Terracotta's built-in replication scheme. The trade-off however results in the ability for both data-centers to read from a local cache for all reads.

This solution is ideal for applications where writes are infrequent and high read throughput and or low read-latency is required.

**Diagram of solution:**

![](/images/documentation/Terracotta%20WAN%20Replication%202.png)

#### Characteristics

This solution has the following characteristics.

##### Reads

All reads are done against a local cache / Terracotta Server Array

##### Writes

All writes are performed against both caches (one in the local LAN and one across the remote WAN) simultaneously transactionally using JTA.

#### Summary

**Pros:**

* High read throughput (all reads are executed against local cache)
* Low read latency (all reads are executed against local cache)

**Cons:**

* An XA transaction manager is required
* Write cost may be higher
* Some of the same latency and throughput issues that occur in Solution 1 can occur here if writes are delayed.

### Solution 3: Messaging-Based (AMQ) Replication

This solution relies on a message bus to send replication events.
The advantage of this solution over the previous two solutions is the ability to configure - and fine-tune - the characteristics and behavior of the replication.
Using a custom replicator that reads updates from a local cache combined with the ability to schedule and/or batch replication can make replication across the WAN significantly more efficient.

See [Terracotta Distributed Ehcache WAN Replication](/documentation/2.6/wan-replication) to learn more about the Terracotta version of this solution.

**Diagram of solution:**
![](/images/documentation/Terracotta%20WAN%20Replication%203.png)

#### Characteristics

This solution has the following characteristics.

##### Reads

All reads are done against a local cache / Terracotta Server Array

##### Writes

All writes are done against a local cache for reliable updates. Write updates are collected and sent at a configurable frequency across the message bus.

This approach allows for batch scheduling and tuning of batch size so that updates can utilize the WAN link efficiently.

#### Summary

**Pros:**

* High read throughput (all reads are executed against local cache)
* Low read latency (all reads are executed against local cache)
* Write replication is highly efficient and tunable
* Available as a fully featured solution, [Terracotta Distributed Ehcache WAN Replication](/documentation/2.6/wan-replication), which includes persistence, delivery guaranty, conflict resolution, and more.

**Cons:**

* A message bus is required
