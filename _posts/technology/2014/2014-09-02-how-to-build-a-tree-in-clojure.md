---
layout: post
category: technology
tag:
- clojure
- algorithm
---

# How to build a tree in clojure

Clojure code is composed of literal representations of its own data structures and atomic values; this characteristic is formally called homoiconicity, or more casually, code-as-data. [1]
It means that we can use clojure code to represent tree data structure!
No more `class Tree` and `class TreeNode`.


### Binary Tree

In computer science, a binary tree is a tree data structure in which each node has at most two children, which are referred to as the left child and the right child. A recursive definition using just set theory notions is that a (non-empty) binary tree is a triple (L, S, R), where L and R are binary trees or the empty set and S is a singleton set. Some authors allow the binary tree to be the empty set as well. [2]

Example:

    ;;
    ;;     A
    ;;    / \
    ;;   B   C
    ;;  / \  |
    ;; D   E F
    ;;

We can easily use clojure list to represent it:

{% highlight clojure %}
'(:A (:B (:D) (:E)) (:C (:F)))
{% endhighlight %}

### Traverse

In clojure, we use `tree-seq` to get nodes a tree in DFS.

    clojure.core/tree-seq
    ([branch? children root])
      Returns a lazy sequence of the nodes in a tree, via a depth-first walk.
       branch? must be a fn of one arg that returns true if passed a node
       that can have children (but may not).  children must be a fn of one
       arg that returns a sequence of the children. Will only be called on
       nodes for which branch? returns true. Root is the root node of the
      tree.

Imaging Each node is a `'(root left right)`.
It's easy to reduce that:

* If `(next node)` return `nil`, that means this node has no nore branches, elase means that this node has sibling.
* If `(rest node)` return `'()`, that means this node is root; else means that this node is not root.

Traverse it:

{% highlight clojure %}
user=> (tree-seq next rest '(:A (:B (:D) (:E)) (:C (:F))))
((:A (:B (:D) (:E)) (:C (:F))) (:B (:D) (:E)) (:D) (:E) (:C (:F)) (:F))
user=> (map first (tree-seq next rest '(:A (:B (:D) (:E)) (:C (:F)))))
(:A :B :D :E :C :F)
{% endhighlight %}

### Clojure source

{% highlight clojure %}
(defn tree-seq
  "Returns a lazy sequence of the nodes in a tree, via a depth-first walk.
   branch? must be a fn of one arg that returns true if passed a node
   that can have children (but may not).  children must be a fn of one
   arg that returns a sequence of the children. Will only be called on
   nodes for which branch? returns true. Root is the root node of the
  tree."
  {:added "1.0"
   :static true}
   [branch? children root]
   (let [walk (fn walk [node]
                (lazy-seq
                 (cons node
                  (when (branch? node)
                    (mapcat walk (children node))))))]
     (walk root)))
{% endhighlight %}

[1]: Clojure Programming book.
[2]: http://en.wikipedia.org/wiki/Binary_tree
