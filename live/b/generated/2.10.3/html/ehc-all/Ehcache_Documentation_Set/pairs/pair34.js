var pairs =
{
"read-through":{"<<this":1,"pattern":1,"write-through":1}
,"<<this":{"topic":1}
,"topic":{"shared":1}
,"shared":{"ehc":1}
,"ehc":{"bmg":1}
,"bmg":{"bmm":1}
,"bmm":{"product":1}
,"product":{"docs.>>":1}
,"docs.>>":{"read-through":1}
,"pattern":{"mimics":1,"reading":1}
,"mimics":{"structure":1}
,"structure":{"cache-aside":1}
,"cache-aside":{"pattern":1}
,"reading":{"data":1}
,"data":{"difference":1}
,"difference":{"implement":1}
,"implement":{"cacheentryfactory":1}
,"cacheentryfactory":{"interface":1}
,"interface":{"instruct":1}
,"instruct":{"cache":1}
,"cache":{"read":1,"miss":1,"instance":1}
,"read":{"objects":1}
,"objects":{"cache":1}
,"miss":{"wrap":1}
,"wrap":{"cache":1}
,"instance":{"instance":1,"selfpopulatingcache":1}
,"selfpopulatingcache":{"<<ffc-the":1}
,"<<ffc-the":{"following":1}
,"following":{"paragraph":1}
,"paragraph":{"hidden":1,"refers":1}
,"hidden":{"clear":1}
,"clear":{"samples":1}
,"samples":{"paragraph":1}
,"refers":{"cannot":1}
,"cannot":{"find":1}
,"find":{"read-through":1}
,"write-through":{"sample":1}
,"sample":{"mentions":1}
,"mentions":{"reinstate":1}
,"reinstate":{"refresh":1}
,"refresh":{"next":1}
,"next":{"release":1}
}
;Search.control.loadWordPairs(pairs);
