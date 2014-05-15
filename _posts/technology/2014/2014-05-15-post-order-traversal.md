---
layout: post
category: technology
tag: algorithm
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

It's funny to traverse tree without using recursive.
First we should know that recursive solution can be
refactor to a stack-based solution. We use stack to
temporary save the nodes we will use a minute later.
When traversal in post order, we need not only a
stack, but also a pointer to parent.

Here is an solution posted in wikipedia:

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

And solution using 2 stack (It's a little tricky, but I
really like it for its simply):

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

the sequence of pop if a reversed result for post-order traversal.
It's very similar to pre-order traversal solution without
using recursive:

       a
      /  \
     b   c

     push a
     pop # a
     push b
     push c
     pop # c
     pop # b

Here is another way to gotcha!

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

This is the stack sequence for simple example, a with 2 children(b, c):


    push a
    push b
    pop // b
    push c
    pop // c
    pop // a

And finally, I reduce a solution by myself.
It's a little tricky too. Typically, we need to visit left
child, then parent, then right child, then parent.
So why not push parent twice into stack? Just like:

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
