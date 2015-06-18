---
layout: post
category: technology
title: Contract in Microservice Architecture
---

`Microservice Architecture` has been a hot buzz word for a while,
but good concrete examples are still so lack.

I thought it might helps to give a brief review for my several days' work.

### Problem I Met

Three systems involve into a game of data passing.

My silent spiders, controlled by System `Spiderman`, will crawl
 information through the great internet.
System `Manhattan` will gather working achievement produced by spiders and
my lovely workmates.
These results of work will reflect to System `Cambridge`.

The picture below, with a boundary around `Manhattan`, describes a general view of these systems:

![](/images/2015/manhattan-architecture.png)

Aha, you got it, I need to design and implement system `Manhattan` from scratch.

### Design Flow, *Make RESTful Contract*

It's hard to guess the behavior other components will act if we chose not to
constraint them, since they're self-independence.

A well designed and implemented contract determines how these systems interact
with each other, and in which way we will program.

Microservices are often integrated using REST over HTTP.

Representational State Transfer, aka RESTful, is a software architecture style
consisting of guidelines and best practices for creating good contract.

So I design data flow as below:

![](/images/2015/manhattan-dataflow.png)

Calls crossover boundaries are via RESTful HTTP requsts.

I need `Cambridge` offering an API `POST /intra/items/sale/:type/:id`.

It has some predictable behaviors:

* Response 204 if set success;
* Response 403 if auth fail;
* Response 404 if set fail;
* Other unknown error.

### Follow contract


```python
try:
    url = make_url(type, id)
    data = make_data(price, inventory)
    resp = requests.post(url, data=data)
    status = resp.status_code
    if status == 204:
        upload.set_upload_success()
    elif status == 403:
        raise NoAccess(url)
    elif status == 404:
        upload.set_not_upload_anymore()
        db.session.delete(binding)
    else:
        raise UnknownError(url, resp)
except requests.ConnectionError:
    sentry.captureException()
```

### Test based on contract

Contract tests : verify interactions at the boundary of an external service
asserting that it meets the contract expected by a consuming service.

> Connections out to external services require special attention since they cross network boundaries.
> The system should be resilient to outages of remote components.
> Gateways contain logic to handle such error cases.
>
> Typically, communications with external services are more coarse grained than the equivalent in process communications to prevent API chattiness and latency.[2]

Note: Mock library make contract test easier. Here I simply stub requests call.

```python
@pytest.fixture
def requests(monkeypatch):
    req = Mock()
    monkeypatch.setattr(upload_sale, 'requests', req)
    return req

def failure_case_on_meeting_error(requests):
    requests.post = Mock(side_effect=Exception)

def failure_case_on_response_403(requests):
    requests.post.return_value.status_code = 403

@pytest.mark.parametrize('case', [
    failure_case_on_response_403,
    failure_case_on_meeting_error,
])
def test_product_upload_failed(product, binding, requests, case):
    case(requests)
    upload_sale.handle_product(product)
    service = ProductService.get(product.id)
    assert service.product.upload_status == UploadStatus.FAILURE
    assert service.product.upload_count == 1
    assert service.product.uploaded_at

def test_product_upload_success(product, binding, requests):
    requests.post.return_value.status_code = 204
    upload_sale.handle_product(product)
    service = ProductService.get(product.id)
    assert service.product.upload_status == UploadStatus.SUCCESS

def test_product_upload_no_longer(product, binding, requests):
    requests.post.return_value.status_code = 404
    upload_sale.handle_product(product)
    service = ProductService.get(product.id)
    assert service.product.upload_status == UploadStatus.DEPRECATE # set deprecate
    assert service.product.upload_count == 1
    assert service.product.uploaded_at
    assert not AppBindingService.get_bindings(product.id) # no bindings now.
```

### Summary

* Contract is probably one of the most important thing in microservice architecture.
* Design a good contract, just follow widely-used RESTful API-style.
* Tightly follow the contract you've just made in programming.
* Contract Driven Test

[1]: http://martinfowler.com/articles/microservices.html
[2]: http://martinfowler.com/articles/microservice-testing/
