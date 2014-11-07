---
layout: post
category: life
---

# Abstractions over Implementations

> It is better to have 100 functions operate on one data structure than 10 functions on 10 data structures.

—Alan J. Perlis in the foreword to Structure and Interpretation of Computer Programs, http://mitpress.mit.edu/sicp/toc/toc.html

## Trello overwhelming implementations!

Trello is a collaboration tool that organizes your projects into boards.
In one glance, Trello tells you
what's being worked on,
who's working on what,
and where something is in a process.

We use team to organize boards, board to organize lists, list to organize cards, card to organize todos.
But it's the end.
We have no way to split a single todo.

There are so many implementations of task abstraction in Trello!

## Building Abstractions with Procedures


> The acts of the mind, wherein it exerts its power over simple ideas, are chiefly these three: 1. Combining several simple ideas into one compound one, and thus all complex ideas are made. 2. The second is bringing two ideas, whether simple or complex, together, and setting them by one another so as to take a view of them at once, without uniting them into one, by which it gets all its ideas of relations. 3. The third is separating them from all other ideas that accompany them in their real existence: this is called abstraction, and thus all its general ideas are made.

—John Locke, An Essay Concerning Human Understanding (1690)

The lack of ability to organize tasks urge people to build more powerful tools
so that they can be reasonably sure that a complex things are performing well.
Using these tools they can split a task into smaller tasks and visualize them in advance.
Fine grit tasks encourage people to get close to final task.

## Basic element

Every powerful task management tool has three mechanisms for accomplishing complex tasks:

* **Primitive task**, which represent the simplest task is concerned with,
* **Means of combination**, by which compound tasks are built for simpler ones and
* **Means of abstraction**, by which compound tasks can be named and manipulated as units.

In the designing of task management tool, we need to handle:

* Data, which is inside a task.
* Procedure, which is descriptions of the rules for manipulating the data.


## Let's try to re-abstract `Task Handler`!


In handling task, we just need to proceed data of task,
and then handle a list of sub-tasks which are split from task.
Each sub-task share same data structure as parent task.
We accomplish task on data proceeded and all sub-tasks handled:


    (defn handle-task [{:keys [data sub-tasks], :or {:sub-tasks []}]
     (proceed data)
     (when sub-tasks
      (map handle-task sub-tasks)))


> map is a high order function to applying a function to a list.
> `(map inc [1 2 3])` will return [2 3 4], due to each element increased 1.
> `(map handle-task [sub-task1 sub-task2])` will actually do handle-task on each sub-task.

Now, we don't actually need a bunch of implementations of task node (board, list, card, todo):

    Node(board)
    |
    ├ Node(Todo List)
    |
    ├ Node(Doing List)
    | |
    | ├ Node(Task A)
    | |
    | └ Node(Task B)
    |   |
    |   ├ Node(todo item 1)
    |   | |
    |   | |
    |   | ├ Node(do something first)
    |   | |
    |   | └ Node(do another then)
    |   |
    |   └ Node(todo item 2)
    |
    ├ Node(QA List)
    |
    └ Node(Done list)

Hoo, so elegent!
