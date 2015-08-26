---
---
# Terracotta Cluster Events

 

## Introduction
Beginning with Ehcache 2.0, the Terracotta Distributed Ehcache cluster events API provides access to Terracotta cluster events and cluster topology. This event-notification mechanism reports events related to the nodes in the Terracotta cluster, not cache events.

## Cluster Topology
The interface `net.sf.ehcache.cluster.CacheCluster` provides methods for obtaining topology information for a Terracotta cluster.
The following methods are available:

* `String getScheme()`

    Returns a scheme name for the cluster information. Currently `TERRACOTTA` is the only scheme supported.
* `Collection<ClusterNode> getNodes()`

    Returns information on all the nodes in the cluster, including ID, hostname, and IP address.
* `boolean addTopologyListener(ClusterTopologyListener listener)`

    Adds a cluster-events listener. Returns true if the listener is already active.
* `boolean removeTopologyListener(ClusterTopologyListener)`

    Removes a cluster-events listener. Returns true if the listener is already inactive.

The interface `net.sf.ehcache.cluster.ClusterNode` provides methods for obtaining information on specific cluster nodes.

<pre><code>public interface ClusterNode {
/**
* Get a unique (per cluster) identifier for this node.
*
* @return Unique per cluster identifier
*/
String getId();
/**
* Get the host name of the node
*
* @return Host name of node
*/
String getHostname();
/**
* Get the IP address of the node
*
* @return IP address of node
*/
String getIp();
"/>
</code></pre>

## Listening For Cluster Events
The interface `net.sf.ehcache.cluster.ClusterTopologyListener` provides methods for detecting the following cluster events:

<pre><code>public interface ClusterTopologyListener {
/**
* A node has joined the cluster
*
* @param node The joining node
*/
void nodeJoined(ClusterNode node);
/**
* A node has left the cluster
*
* @param node The departing node
*/
void nodeLeft(ClusterNode node);
/**
* This node has established contact with the cluster and can execute clustered operations.
*
* @param node The current node
*/
void clusterOnline(ClusterNode node);
/**
* This node has lost contact (possibly temporarily) with the cluster and cannot execute
* clustered operations
*
* @param node The current node
*/
void clusterOffline(ClusterNode node);
"/>
/**
* This node lost contact and rejoined the cluster again.
* <p />
* This event is only fired in the node which rejoined and not to all the connected nodes
* @param oldNode The old node which got disconnected
* @param newNode The new node after rejoin
*/
void clusterRejoined(ClusterNode oldNode, ClusterNode newNode); 
</code></pre>

### Example Code
This example prints out the cluster nodes and then registers a `ClusterTopologyListener`
which prints out events as they happen.

<pre><code>CacheManager mgr = ...
CacheCluster cluster = mgr.getCluster("TERRACOTTA");
  // Get current nodes
Collection&lt;ClusterNode> nodes = cluster.getNodes();
for(ClusterNode node : nodes) {
  System.out.println(node.getId() + " " + node.getHostname() + " " + node.getIp());
"/>
  // Register listener
cluster.addTopologyListener(new ClusterTopologyListener() {
  public void nodeJoined(ClusterNode node) { System.out.println(node + " joined"); "/>
  public void nodeLeft(ClusterNode node) { System.out.println(node + " left"); "/>
  public void clusterOnline(ClusterNode node) { System.out.println(node + " enabled"); "/>
  public void clusterOffline(ClusterNode node) { System.out.println(node + " disabled"); "/>
  public void clusterRejoined(ClusterNode node, ClusterNode newNode) {
    System.out.println(node + " rejoined the cluster as " + newNode);
  "/>
});
</code></pre>

### Uses for Cluster Events
From Ehcache 2.4.1/Terracotta 3.5 these events are used for operation of NonStopCache

If Ehcache got disconnected from the Terracotta Server Array say due to a network issue,
then in Ehcache 2.0 each cache operation will block indefinitely. In other words it is
configured for fail-fast to protect the ACIDity of the cluster.
However this approach will also cause processing of requests to the cache to stop likely
causing the outage to cascade.

In some cases graceful degradation may be more appropriate.
When the `clusterOffline` events fire you could call `Cache.setDisabled()`,
which will cause puts and gets to bypass the cache. Your application would then degrade
to operating without a cache, but might be able to do useful work.
You could also take the whole application off-line.
When connectivity is restored you could then reverse the action, taking the cache back
online or the application back on line as the case may be.
