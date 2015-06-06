---
layout: post
category: technology
tag: algorithm
title: Tree traversal
---

### PostOrder Traversal For Tree (Not Using Recersive)


We know that using recursive is trivial:


    def post_order_traversal(tree):
        if not tree:
            return
        post_order_traversal(tree.left)
        post_order_traversal(tree.right)
        print tree.val

![Post-Order Traversal](http://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Sorted_binary_tree_postorder.svg/440px-Sorted_binary_tree_postorder.svg.png)

It's interesting to traverse a tree using stack-based solution
which is an alternative of recursive-based solution.
This post offers a solution that only one stack is needed
instead of two stacks or both one stack and helper variables
as usual when doing post order traversal.

Here are three usual solutions:

### 1 stack and a visited tag variable solution

    iterativePostorder(node)
      parentStack = empty stack  
      lastnodevisited = null
      while (not parentStack.isEmpty() or node ≠ null)
        if (node ≠ null)
          parentStack.push(node)
          node = node.left
        else
          peeknode = parentStack.peek()
          if (peeknode.right ≠ null and lastnodevisited ≠ peeknode.right)
            /* if right child exists AND traversing node from left child, move right */
            node = peeknode.right
          else
            parentStack.pop()
            visit(peeknode)
            lastnodevisited = peeknode

It's posted at wikipedia[1].

### 1 stack and a previous helper variable solution

    void postOrderTraversalIterative(BinaryTree *root) {
      if (!root) return;
      stack<BinaryTree*> s;
      s.push(root);
      BinaryTree *prev = NULL;
      while (!s.empty()) {
        BinaryTree *curr = s.top();
        // we are traversing down the tree
        if (!prev || prev->left == curr || prev->right == curr) {
          if (curr->left) {
            s.push(curr->left);
          } else if (curr->right) {
            s.push(curr->right);
          } else {
            cout << curr->data << " ";
            s.pop();
          }
        }
        // we are traversing up the tree from the left
        else if (curr->left == prev) {
          if (curr->right) {
            s.push(curr->right);
          } else {
            cout << curr->data << " ";
            s.pop();
          }
        }
        // we are traversing up the tree from the right
        else if (curr->right == prev) {
          cout << curr->data << " ";
          s.pop();
        }
        prev = curr;  // record previously traversed node
      }
    }

Let's see the stack sequence for an example: a with 2 children(b, c):

    push a
    push b
    pop // b
    push c
    pop // c
    pop // a

### 2 stacks solution

    public ArrayList<Integer> postorderTraversal(TreeNode root) {
        ArrayList<Integer> array = new ArrayList<Integer>();
        if (root == null) {
            return array;
        }
        Stack<TreeNode> stack = new Stack<TreeNode>();
        stack.push(root);
        while (!stack.empty()) {
            TreeNode cur = stack.pop();
            array.add(0, cur.val);
            if (cur.left != null) {
                stack.push(cur.left);
            }
            if (cur.right != null) {
                stack.push(cur.right);
            }
        }
        return array;
    }

It's simple and I really like it. The sequence of stack
operation is very similar to what is produced by a pre-order
traversal:

       a
      /  \
     b   c

     push a
     pop # a
     push b
     push c
     pop # c
     pop # b


### A new way to hit the target!

Finally, I reduce a solution.
Typically, we need to visit left child, then parent,
then right child, and last parent. So why not push
each parent into stack twice? Just like:

    push a
    push a
    push b
    # want to push b but b has no right child
    pop # b
    pop # a, but we only need its right child pointer
    push c
    pop # c
    pop # a

Here is the code:

    /**
     * Definition for binary tree
     * public class TreeNode {
     *     int val;
     *     TreeNode left;
     *     TreeNode right;
     *     TreeNode(int x) { val = x; }
     * }
     */
    public class Solution {
        public ArrayList<Integer> postorderTraversal(TreeNode root) {
            ArrayList<Integer> array = new ArrayList<Integer>();
            TreeNode current = root;
            if (current == null) {
                return array;
            }
            Stack<TreeNode> stack = new Stack<TreeNode>();
            while (!stack.empty() || current != null) {
                // find left.
                while (current != null) {
                    stack.push(current);
                    if (current.right != null) {
                        stack.push(current);
                    }
                    current = current.left;
                }
                current = stack.pop();
                if (!stack.empty() && current == stack.peek()) {
                    current = current.right;
                } else {
                    array.add(current.val);
                    current = null;
                }
            }
            return array;
        }
    }


Wow, It's awesome.

[1]: http://en.wikipedia.org/wiki/Tree_traversal#Post-order_2
