---
layout: post
title: Signature cookies
category: technology
tag: web
---


由于client的数据是可以伪造的, 因此将数据存储到存到client要面临的问题只有一个, 那就是怎么防止数据被篡改.
一个简单的办法是签名(signature).

RFC draft [JSON Web Signature (JWS)](http://tools.ietf.org/html/draft-jones-json-web-signature-04) 描述了一种给JSON签名的规范. Flask于 2012 年引入了itsdangerous 取代了原有的 `werkzeug.contrib.securecookie` 用于加强cookie的安全性. [3f82d1]
我们用itsdangerous写个例子:

```python
/tmp % cat app.py
# -*- coding: utf-8 -*-

from flask import Flask, Response, request
from itsdangerous import JSONWebSignatureSerializer
app = Flask(__name__)
SECRET = 'secret-key'

serializer = JSONWebSignatureSerializer(SECRET)

_token = '84e9fa054f0aee2405127a4647ca84c472b6e9ee3dfd96e9c1a751e1a6c62820'
@app.route("/")
def index():
    resp = Response("hello")
    token_ciphered = serializer.dumps(_token)
    resp.set_cookie('token', token_ciphered)
    # origin: 84e9fa054f0aee2405127a4647ca84c472b6e9ee3dfd96e9c1a751e1a6c62820
    # cipher: eyJhbGciOiJIUzI1NiJ9.Ijg0ZTlmYTA1NGYwYWVlMjQwNTEyN2E0NjQ3Y2E4NGM0NzJiNmU5ZWUzZGZkOTZlOWMxYTc1MWUxYTZjNjI4MjAi.Cwva2BJO8BzcZ7Y-TIgIIZ_w0D1PZdr5jJJ-nPW3WB0
    return resp

@app.route("/verify")
def verify():
    token = request.cookies.get('token')
    token = serializer.loads(token)
    return token == _token and 'success' or 'failed'

app.run(debug=True) 
```

### 基本原理

一行代码解释加密: `message = payload + "." + MD5(payload + secret_key)`
鉴于在社工库面前, MD5已经毫无安全可言, 这里的加密算法采用 [Hash-based message authentication code](http://en.wikipedia.org/wiki/HMAC), 使用最广的HMAC算法是[HMAC-MD5](http://tools.ietf.org/html/rfc6151) 

我们假设secret_key被不怀好意的坏人窃取了, 那只要在服务器上变更了secret_key, 则所有client存储的数据就都是过期了.

但是还有一种情况需要考虑: 如果不怀好意的坏人从被害人那里窃取了cookie, 拷到自己的机器来用呢?
此时, 服务器因为无法检验出数据的真假进而无法让数据过期.

怎么办呢, 也有一个可行的办法: 在payload中放入可变数据. 让cookie里的数据有生命周期自行过期.
比如在payload中增加一个创建时间, 如果服务器时间减去该时间若大于某个设定的过期时间则这个数据就过期.
比如在payload中增加一小段用户密码的哈希, 如果用户密码变了, 那么这个cookie也会自动失效.


[3f82d1]: https://github.com/mitsuhiko/flask/commit/3f82d1b68ea6f5bf2970c2df8ff5cf991439a9bf 
Refer: http://lucumr.pocoo.org/2013/11/17/my-favorite-database/
