---
layout: post
category: technology
title: Rio, a server-side event-driven system
---

In computer programming, event-driven programming is a programming paradigm
in which the flow the the program is determined by events. Event-driven
programming is widely used in GUI development. Since microservices architecture
is thriving these year, a demand to send messages from one system to many other
systems is rising. Rio is a system trying to solve this problem.

[Rio] is standing on the shoulders of giants: Flask + Celery. In Rio, there are a
job queue playing the role of main loop, and once message sent to job queue,
a bunch of HTTP webhooks will be triggered simultaneously. Logging and
monitoring are important task as well in Rio. You can easily find out
latest bad behaviour webhook calling and retrigger it if possible.

Rio assumes you have a sender service with SDK integrated, and some
receiver services which implement HTTP callback tasks.

In Rio, you need to create a project first to receive message and traffic
payload. Before sending message, you have to create handlers for an event in
project. These operation can be done via CLI tools or Dashboard.

In sender side, you need to send message::

    from rio_client import Client
    client = Client(DSN='http://sender:*********@rio.intra.example.org/1/project')
    client.emit('comment-published', {'ip': 127.0.0.1, 'content': 'I am a spammer'})

In receiver side, you need to define a simple webhook. For instance, this is a
Flask view function::

    @app.route('/webhook/comment/antispam', methods=['POST])
    def antispam_comment():
        if is_spam_content(request.form['content']):
            ban_ip(request.form['ip])
        return jsonify(status='success', retval=0)

Or in Ruby on Rails::

    def antispam_comment
        ban_ip(params[:ip]) if is_spam_content(params[:content])
        render :json => {:status => 'success', :retval => 0}

It is recommended to put webhook under firewall protection so that villainous
cracker have no opportunity to attack.

Communication between services is a tough problem for developers. There are two
popular paradigm to complete asynchronous lightweight messaging tasks:
Choreography and Orchestration. And Rio has a flavour of Choreography. As
producer of the message doesn’t have to know what other service supposed to do,
it just provides an event, to which consumers may respond or no. On the other
hand, as consumer of the message does not have to keep listening on message
queue, it just provides an handler, to which consumer may be called or no.
As a result, both two kinds of system need only behave theirselves.

[Rio]: https://github.com/soasme/rio
