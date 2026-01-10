Title: Flask contexts (And how to use them)
Date: 2018-11-24 13:14:00 -0600
Category: Web Development
Tags: flask, python, pytest
Slug: flask-contexts
Authors: Diego Quintana
Status: published
Summary: How to test Flask applications with `pytest`

# Motivation

There's this thing going on with the [flask context](http://flask.pocoo.org/docs/1.0/appcontext/#creating-an-application-context) and the [request context](http://flask.pocoo.org/docs/1.0/reqcontext/), that used to confuse me a lot. Before testing these two probably will never be used, but after reading [the documentation](http://flask.pocoo.org/docs/1.0/testing/) and writing your first tests, it's probable that you run into something like

```plain
Flask.url_for() error: Attempted to generate a URL without the application context being pushed
```

So, what is that went *wrong*?

Someone already wrote an [exhaustive revision](http://kronosapiens.github.io/blog/2014/08/14/understanding-contexts-in-flask.html) of what are the different approaches, but it actually never closes the issue of *how* to test an application properly.

Others mention it, but it just *doesn't stick*

- [Delightful testing with pytest and Flask-SQLAlchemy - Alex Michael](http://alexmic.net/flask-sqlalchemy-pytest/)
- [Flask url_for | Lua Software Code](https://code.luasoftware.com/tutorials/flask/flask-url-for/)
- [Testing a Flask Application using pytest – Patrick's Software Blog](https://www.patricksoftwareblog.com/testing-a-flask-application-using-pytest/)
- [flask/examples/tutorial/tests at 1.0.2 · pallets/flask · GitHub](https://github.com/pallets/flask/tree/1.0.2/examples/tutorial/tests)

For the sake of completeness and for my own understanding of the issue, here's my view on the topic.

## Flask Contexts

- In the lifecycle of a request, both an *Application context* and a *Request Context* are created at the beginning, and destroyed at the end (see [Advanced Flask Patterns - Speaker Deck, Slide 7](https://speakerdeck.com/mitsuhiko/advanced-flask-patterns-1?slide=7))
- The idea behind having two detached contexts is so an application can exist
  outside of a request, and it's more of a design pattern (That a lot of people seems to *hate*) and it was different in previous versions of Flask [as discussed in this SO question (Which is also a great discussion about the internals of Flask).](https://stackoverflow.com/questions/15083967/when-should-flask-g-be-used)

In short, *context locals* can be summarized as (as shown in [Flask for Fun and Profit, Slide 27](https://speakerdeck.com/mitsuhiko/flask-for-fun-and-profit?slide=27))

- A pushed app context points the current app in use to `current_app`, and it gives
  meaning to other proxies that only make sense for some parameters in a *live*
  app instance, like `url_for` and `g`
- A request context is more expensive and maps the `request` proxy to the current
  request in process
- [Every request pushes a new application context](https://github.com/pallets/flask/blob/1949c4a9abc174bf29620f6dd8ceab9ed3ace2eb/flask/ctx.py#L230)

## Flask contexts vernacular

For a given `app` object, there are some design aspects and specific objects
it's good to get familiar with when testing with Flask

### `flask.app.test_client()`

Provides a client that can perform requests to our application.

### `flask.app.app_context()`

The application context, it gives life to `current_app`. Starts and dies with
a request.

### `flask.app.test_request_context()`

The request context, it gives life to `request`. If there's no application context
at the moment, it pushes a new one. Starts and ends with a request.

### `g`

A proxy that lives within a pushed **application** context, used to store *non sensible*
information about the current application. Its life is bound to that of the request.

### `session`

A proxy that lives within a pushed **request** context, used to store *sensible*
information and encrypted with your `SECRET_KEY`.

## Practical differences (in code)

This [SO answer](https://stackoverflow.com/a/33382823/5819113) puts it simple, so I will be kinda adding my own comments to it.

```python
from flask import Flask, g
app = Flask(__name__)

with app.app_context():
    print('in app context, before first request context')
    print('setting g.foo to abc')
    g.foo = 'abc'
    print('g.foo should be abc, is: {0}'.format(g.foo))

    with app.test_request_context():
        # this reuses g from the current context
        print('in first request context')
        print('g.foo should be abc, is: {0}'.format(g.foo))
        print('setting g.foo to xyz')
        # this is the same g, so it will be replaced
        g.foo = 'xyz'
        print('g.foo should be xyz, is: {0}'.format(g.foo))

    print('in app context, after first request context')
    print('g.foo should be abc, is: {0}'.format(g.foo))

    with app.test_request_context():
        print('in second request context')
        print('g.foo should be abc, is: {0}'.format(g.foo))
        print('setting g.foo to pqr')
        g.foo = 'pqr'
        print('g.foo should be pqr, is: {0}'.format(g.foo))

    print('in app context, after second request context')
    print('g.foo should be abc, is: {0}'.format(g.foo))
```

And here's the output that it gives:

```plain
in app context, before first request context
setting g.foo to abc
g.foo should be abc, is: abc
in first request context
g.foo should be abc, is: abc
setting g.foo to xyz
g.foo should be xyz, is: xyz
in app context, after first request context
g.foo should be abc, is: xyz
in second request context
g.foo should be abc, is: xyz
setting g.foo to pqr
g.foo should be pqr, is: pqr
in app context, after second request context
g.foo should be abc, is: pqr
```

In this first example `g` is shared across contexts because it's the same
context in *nested contexts*, and it's a *caveat* mentioned in the answer (some emphasis is mine)

> "Every request pushes a new application context". And [as the Flask docs say](http://flask.pocoo.org/docs/0.10/appcontext/), the application context "will not be shared between requests". Now, what hasn't been explicitly stated (although I guess it's implied from these statements), and what my testing clearly shows, is that *you should **never** explicitly create multiple request contexts nested inside one application context, because `flask.g` (and co) doesn't have any magic whereby it functions in the two different "levels" of context*, with different states existing independently at the application and request levels.
>
> The reality is that "application context" is potentially quite a misleading name, because `app.app_context()` **is** a per-request context, exactly the same as the "request context". Think of it as a "request context lite", only required in the case where you need some of the variables that normally require a request context, but you don't need access to any request object (e.g. when running batch DB operations in a shell script). If you try and extend the application context to encompass more than one request context, you're asking for trouble. So, rather than my test above, you should instead write code like this with Flask's contexts:

```python
from flask import Flask, g
app = Flask(__name__)

with app.app_context():
    print('in app context, before first request context')
    print('setting g.foo to abc')
    g.foo = 'abc'
    print('g.foo should be abc, is: {0}'.format(g.foo))

with app.test_request_context():
    print('in first request context')
    print('g.foo should be None, is: {0}'.format(g.get('foo')))
    print('setting g.foo to xyz')
    g.foo = 'xyz'
    print('g.foo should be xyz, is: {0}'.format(g.foo))

with app.test_request_context():
    print('in second request context')
    print('g.foo should be None, is: {0}'.format(g.get('foo')))
    print('setting g.foo to pqr')
    g.foo = 'pqr'
    print('g.foo should be pqr, is: {0}'.format(g.foo))
```

Which will give the expected results:

```plain
in app context, before first request context
setting g.foo to abc
g.foo should be abc, is: abc
in first request context
g.foo should be None, is: None
setting g.foo to xyz
g.foo should be xyz, is: xyz
in second request context
g.foo should be None, is: None
setting g.foo to pqr
g.foo should be pqr, is: pqr
```

In this second example, all three `with` blocks are pushing independent contexts. The difference is that
last two are also pushing an application context *implicitly*, and the first one is not pushing a request context.

## So, how do I test my app?

I will be using [`pytest`](https://docs.pytest.org/en/latest/) because it's good. Just google "`unittest versus pytest`" to find out why.

This [SO answer](https://stackoverflow.com/a/17377101/5819113) summarizes the differences in the best way I've found so far.

> If you want to make a request to your application, use the [`test_client`](http://flask.pocoo.org/docs/latest/api/#flask.Flask.test_client).
>
>     c = app.test_client()
>     response = c.get('/test/url')
>     # test response
>
> If you want to test code which uses an application context (`current_app`, `g`, `url_for`), push an [`app_context`](http://flask.pocoo.org/docs/latest/api/#flask.Flask.app_context).
>
>     with app.app_context():
>         # test your app context code
>
> If you want test code which uses a request context (`request`, `session`), push a [`test_request_context`](http://flask.pocoo.org/docs/latest/api/#flask.Flask.test_request_context).
>
>     with current_app.test_request_context():
>         # test your request context code

It's also important to note that

> Both app and request contexts can also be pushed manually, which is useful when using the interpreter.
>
>     >>> ctx = app.app_context()
>     >>> ctx.push()

So far there are *two* approaches:

1. push an application context at the beginning inside a fixture, and pop it at the end
2. pass an application object from the fixture and produce contexts locally inside
   each test

Everything in the middle is prone to produce weird results and drive you crazy, so *try* to be consistent!

[Armin Ronacher](http://lucumr.pocoo.org/about/) suggests a pytest fixture pattern in [this presentation](https://youtu.be/1ByQhAM5c1I?t=2285) ([slides](https://speakerdeck.com/mitsuhiko/flask-for-fun-and-profit?slide=52)), which relies in the first approach. The code is as follows:

```python
import pytest

@pytest.fixture(scope="module")
def app(request):

    # import app factory pattern
    from yourapp import create_app
    app = create_app()

    # pushes an application context manually
    ctx = app.app_context()
    ctx.push()

    # bind the test life with the context through the
    request.addfinalizer(ctx.pop)
    return app

@pytest.fixture()
def test_client(request, app):

    client = app.test_client()
    client.__enter__()

    request.addfinalizer(
        lambda: client.__exit__(None, None, None))
    return client
```

Note that `request` here refers to the [`pytest` fixture](https://docs.pytest.org/en/latest/reference.html#request)

## But how do I test? really

After a lot of churning and with the help of `#pocoo` in IRC, I came up with this:

```python
import pytest


@pytest.fixture
def runner(app):
    """A test runner for the app's Click commands."""
    return app.test_cli_runner()


@pytest.fixture(scope='session')
def app(request):
    from yourapp import create_app
    return create_app('testing')


@pytest.fixture(autouse=True)
def app_context(app):
    """Creates a flask app context"""
    with app.app_context():
        yield app


@pytest.fixture
def request_context(app_context):
    """Creates a flask request context"""
    with app_context.test_request_context():
        yield


@pytest.fixture
def client(app_context):
    return app_context.test_client(use_cookies=True)


@pytest.fixture(scope="model")
def db(app_context):

    # extensions pattern explained in here https://stackoverflow.com/a/42910185/5819113
    from yourapp.extensions import db

    db.create_all()

    # seed the database
    seed_db()

    yield db

    # teardown database
    # https://stackoverflow.com/a/18365654/5819113
    db.session.remove()
    db.drop_all()
    db.get_engine(app_context).dispose()


def seed_db():
    # insert default users and roles
    print("Seeding the database or something")
```

This is working for me. In short

- If your test requires a living app, import the `app_context` fixture
- If your test requires a populated database, import `db`
- If your test requires examining a part of the request, import the `request_context` fixture
- If your test requires a logged in user, you can use the `client` fixture and `flask_login` as

```python
def login(client, email, password):
    """A helper method that logs in users"""
    return client.post(url_for('auth.login'),
                    data={
                        'email': email,
                        'password': password},
                    follow_redirects=True)


def test_with_logged_in_user(client):
    """Tests a view that requires authentication"""
    from flask_login import current_user

    # client is a pytest fixture
    with client as c:
        # login is a helper method that issues a POST request
        login(c, "user@test.com", "test")
        assert current_user.email == "user@test.com"
        assert current_user.is_authenticated

        response = c.get(
            '/restricted_view/',
            follow_redirects=True)

        assert response.status_code == 200
        assert b'Stuff that should appear in your view' in response.data
```

That's all I have to say about it.
