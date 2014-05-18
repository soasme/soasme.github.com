---
layout: post
category: technology
tag: web
---

# A Day of Tech Guy

Our team tried hard to improve daily workflow in the past few years.
We made every effort to dispatch different tasks to the right person
in a proper time. When features were produced, we would enlist
several involvers into a micro group, usually included frontend,
backend, iOS dev, Android dev, QA, UE, PM, and etc, which we called
it `开队`, `打怪`, `打Boss`, `Sprint`.

Guys(老湿) who were not assigned even a task would set feet
on `Camp`(湿地), where to accomplish trivial work like bugs fixing,
business supports, and so on. Tech guy was one of them, but had
a bit more jobs than other guys in the camp.

Let's look at my life as a **TECH GUY** in daily work!

## Merge Pull Request

We were using github enterprise edition to manage source for
a long time, although migrated to a github-likable system
[code] developed by guys I work with last month. But the
workflow is still the same!

This is basic workflow:

* Make pull requests from feature branches to master
* Invite coding reviewers, usually via posting a review comment:
  `@bke_team @f2e_team @somebody code review please.`.
* If reviewers have latency to do the coding interviews, tech guy
  has responsibility to notify involvers.
* Waiting for every reviewers posted a short phrase `lgtm` as
  a review comment (emoji `:lgtm:` is as well).
* Waiting for CI suite passed.
* Tech guy click the green `Merge the pull request` button.

In general, tech guy's work is to click button.

This mechanism is designed to help keeping both the quality of
source code and the efficiency of process. Tech guy only
needs to judge whether the pull requests have met the requirements
of merging.

As we all know, coding interview is the shield to make code clean.
In some teams, merge will be executed by a high level developer
who has both authority to decide and to merge,  which makes me feel
he is more like a tyrant. In some teams, merge will be executed by
guys who makes pull request himself, which makes routine in chaos
and put codebase into a unmaintainable situation. It's necessary
to split coding review and merging into 2 routines.

I develop a dashboard to help tech guy watching the progress
for going pull requests, which make this work much more easily.
Here is a screenshot:

![electro-lgtms](/images/2014/electro-lgtms.png)

A tech guy can get all information needed to merge **at a glance**.
The basic information contains requester, issue id, title, TO-DOs,
reviewers, their conclusions, CI result, coverage report.

If one reviewer says `lgtm`, his avatar would rounded by green border,
otherwise a red border.
If there is no reviewer, then the item will be rendered over yellow
background, which means that it's time for tech guy to
notify involvers.
If all reviewers says `lgtm` and ci is passed, the item will be
rendered over green background.

Usually, tech guy need go to issue page and
click the merge button whenever he sees the green item at last.

It's really simple for him: **find green item, merge it**.

Although as a hub of this mechanism, he won't be the `SPOF` problem.
We can alternate tech guy easily by transfer authority to another guy in
the camp through one setting option in the `code` system.
Typically, we change tech guy every week.
And we use a `trello` card to manage weekly routine:

![trello-tech-guy-card-small](/images/2014/trello-tech-guy-card-small.png)
![trello-tech-guy-card](/images/2014/trello-tech-guy-card.png)

## Fireman

Usually it's QA to trigger deploy event through fabric command.
But tech guy is often do that so. Although every member have authority
to deploy :)

Tech guy have another job: watch [graphite] stats.
This is an example screenshot:

![graphite-in-cubism-mode](/images/2014/graphite-in-cubism-mode.png)

A tech guy can see several extremely important indicators:

* response time
* 40x occurrence
* 50x occurrence
* some service stats

It's built on to top of library [cubism], which is a
wrapper of d3.js.
If the system is getting worse,  tech guy who is
concerning about graphic will quickly notice the dark green
color and then make proper actions.

Usually, the errors will happen after a deployment. Tech guy need
to help decide how to handle it, rollback or hot fix.

## Assign Bugs

We use [sentry] as a realtime error logging and aggregation
platform, [trello] as a collaboration tool to organize our
projects.
I also integrate `trello` and `sentry` into one dashboard for tech guy.
In the dashboard, tech guy can easily report bugs to transform a sentry
web page into a trello card, marking it red flag! Now he knows
who is tracing the related bug.

![sentry-group-example](/images/2014/sentry-group-example.png)

Origin Sentry Group

![trello-card-of-sentry-errors](/images/2014/trello-card-of-sentry-errors.png)

Transform to Trello Card

![electro-dashboard-of-sentry-trello](/images/2014/electro-dashboard-of-sentry-trello.png)

Dashboard

## Trivial Work

Same as other guys in the camp.

## Conclusions

Tech guy is an important role to help other developers focus on
their projects and keeping collaboration more easily.
It's kinda hoping that you like this mechanism.


[code]: https://github.com/douban/code
[graphite]: http://graphite.wikidot.com/
[cubism]: https://github.com/square/cubism
[sentry]: https://github.com/getsentry/sentry
[trello]: http://trello.com/
