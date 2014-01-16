---
layout: post
category: technology
tag: test
---

今天上班时随手丢了[上篇日志](http://www.douban.com/note/325827766/)给毅总, 被给了差评, 今晚决定好好介绍下这个工具.

### 我们为什么用pytest

这是个很好解答的问题. 在组内强推这货的不是我, 是歪叔.
搜索了下历史, 我来稍微整理复盘下这段测试环境的演进.

Ark早期是跟随豆厂, 使用nose的. 在实践中遇到了一个问题:
nose-randomize 会导致生成的 xml report 一片空白, [pytest-random] 则没有这个问题.
而且 [pytest-random] 还可以跨 test case 随机 shuffle, 而 nose-randomize 只能在 test suite 范围内 shuffle.

更多理由:

* pytest backtrace 的输出更友好, 还支持 `-l` 显示各个 call frame 中的局部变量, 这在用例排查时非常非常省事, 所有过程列明, 不需要插桩, 也不需要pdb, 一遍测试, 认真看下输出就能找到大部分问题.
* py.test 对纯粹 `assert` 语句的测试支持更好(体现在 backtrace 输出更友好). 出于个人偏好, 我认为 assert a == b, 不管从少码字, 编代码舒服程度, 还是美观程度, 都要比 self.assertEqual(a, b) 来得好, 何况 assert 在 backtrace 时的输出也很友好.[1]
* 提供 conftest.py 钩子支持, 这点在推行时没有做什么定制, 近期得到了比较多的应用.
* `--pdb` 与 `--capture` 不冲突 - -
* 歪叔写了这个 vim 插件用于简化 vim 与 pytest 的整合: [pytest-vim-compiler]; nosetest 的等价物要额外装一个 pypi 上没有的插件.

在比较 pytest 与 nose 后, 得出了这么几个结论: 

暂时看不到 py.test 有什么劣势. nose 1.x 已经进入不活跃状态, nose2 还太年轻. 
以及, nose驱动的测试基本上pytest可以平滑的接管. 大部分使用nose的测试都能用pytest无缝切换. 一切不兼容的特性, 修改起来也很容易, 事实上Ark在一两个PR内就完成了测试载体的切换.

### pytest 是什么

它是运行测试的工具, 自动查找并运行测试用例.
他能基本兼容 nose, 有很多实用便捷的特性, 以及丰富的社区及强大的可定制化空间.

大概就是这样.

以上介绍有点水, 如果想要深入了解pytest, 还是去看看文档吧[2]

### 我们怎么用pytest

#### 如何调用

py.test . # 运行当前目录所有的 testcases
py.test tests # 运行 tests 目录下的所有 cases
py.test tests/test_model.py # 运行 当个测试文件
py.test tests/test_model.py -k save # 运行 测试函数名中带 save 的测试用例
py.test tests -s # 输出stdout, 另外, 如果case出错, 会自动把stdout/stderr都输出来. 

以上是我比较常用的方法.

我们没有从代码里面触发 pytest.main ([Calling pytest from Python code])

#### 调用参数

除了可以使用时附带参数, 这些参数可以放在 ./pytest.ini ./tests/pytest.ini 里面, 执行目录的用例时会自动带上这些参数.
具体是格式像这样:

[pytest]
addopts = -q --random 

关于ini的寻找路径/优先级/发现首个配置即停/ini文件名, 参见: [How test configuration is read from configuration INI-files]) 

插件也会提供一些参数.
自己也能定制一些参数.

#### assert

关于 assert , 能讲的不多. 前面讲过了 assert 写法舒心, 输出美观.
现在新写的case, 基本上会使用 assert 的写法.
至今还未有 [Defining own assertion comparison] 的需求.

#### fixture

这是 pytest 的当家特性. 它是 xUnit 风格测试中 setUp/tearDown 的强化版. 强化点在于:

* 不像 setUp/tearDown 一锅端, 每个 fixture 都有显式的名称, 便于管理
* fixture 粒度更细, 组合方便, 依赖注入.
* fixture scope 可选度更高, 可将作用域限定于整个会话/单个模块/单个类/单个函数
* fixture params 特性可以正交测试组合.

所以, 要想用好 pytest, [这页文档] 是必读的.
我就不翻译文档了, 介绍 Ark 里是怎么使用的.

---

    @pytest.fixture
    def domain(table, app):
        return Domain.create(rel='rel', foo='bar')

    def test_get_domain_model_by_id(domain):
        assert Domain.find(domain.id) == domain

这是代码库里一个比较简单的例子: 定义一个名叫 domain 的fixture, 并把 domain 作为 test_get_domain_model_by_id 的参数, pytest会自动注入 domain 这个fixture.

---

    @pytest.fixture(scope="session")
    def database(request):
        db_name = "{}.db".format(time())
        deferred_db.init(db_name)
        def finalizer():
            if os.path.exists(db_name):
                os.remove(db_name)
        request.addfinalizer(finalizer)
        return deferred_db

这个例子展现了scope和finalizer的基本用法, database 这个fixture会在整个session运行期间有效, 并在整个session结束时做一些销毁数据库tmp文件.

---

    UNSIGNED_COMMON_PAGES = [
        '/',
        '/reader/', 
    ] 
    @pytest.fixture(params=UNSIGNED_COMMON_PAGES)
    def unsigned_page(request):
        return request.param

    def test_fetch_common_pages_success_in_unsigend(request, app, session, unsigned_page):
        resp = fetch_page(session, unsigned_page)
        assert resp.status_code < 300

这个例子说明了 params 的用法, 只需要一个配置列表, 用fixture做个桥接, 使用一个测试函数, 就能驱动着Ark许多页面的访问性测试.

$ py.test checkpage/test_local.py -vv
checkpage/test_local.py:104: test_fetch_common_pages_success_in_unsigend[/] PASSED
checkpage/test_local.py:100: test_fetch_common_pages_success_in_signed[/reader/] PASSED   

---

    # Modular fixture manager

    class App(object):

        def __init__(self, request):
            self.request = request


    @pytest.fixture
    def app(request,
            monkeypatch,
            mc_logger,
            db_logger,
            shire_mc_logger,
            fs_logger,
            store_logger,
            ):
        return App(request) 

使用一个小技巧, 使分散的小fixture, 聚集成一个大规模的fixture.

----

   @pytest.mark.usefixtures('works')
    def test_This_is_an_unexposed_endpoint(self):
        """This endpoint should be always attached with token.

        Example:

        .. sourcecode:: http

            HTTP/1.1 404 NOT FOUND

            {"message": "Unexposed endpoint"}
        """
        self.set_anon()
        resp = self.post_purchase(self.works)
        self.assert_unexposed(resp)

这是 Ark API 的测试. 要说明的问题是, 继承自 unittest.TestCase 的 xUnit 风格, 也能使用fixture.
通过 `@pytest.mark.usefixtures('fixtureA', 'fixtureB')` 使用指定fixture.

需要注意的是, 这并不是一个好主意.
在 [Support for unittest.TestCase / Integration of fixtures] 文档中已经指明: 可以, 但不推荐.
一个很大的原因是, pytest 的依赖注入会破坏 unittest.TestCase 风格测试的执行.
文档中介绍了两种在 xUnit-style 测试用例中编写fixture的方法.
但是Ark使用了文档没有介绍的第三种:

    @pytest.fixture
    def purchase(request):
        self = request.instance
        self.author= UserFactory()
        self.works = WorksFactory(author_id=self.author.id)
        return self.works

我们可以使 fixture 中生成的对象实例挂到 `request.instance` 上, 而这个 instance, 就是上面 test_This_is_an_unexposed_endpoint 后面的 self, 通过这种方法, 我们不是从参数注入 fixture, 而是从 self 注入了 fixture, 这也是上面测试用例中 self.works 的来源.

### plugin

#### fixture 的位置

pytest 可以在测试文件中定义一个fixture, 但是更多时候, 我们想要共享fixture. 
准确的是, 这个小节该谈论的主题应该叫 plugin.

我们需要知道, 使用 `py.test --fixture` 可以列出当前可用的所有fixture.
首先, pytest 有内置了几个fixture, 比如`monkeypatch` 这种逆天的fixture, `tmpdir` 这种好用的fixture, `capsys` 这种强悍的fixture.

其次, 我们也是用 pytest 第三方插件, 比如上文已经提过的 pytest-random, 用于乱序执行case; 还使用了 pytest-cov, 用于输出测试覆盖率报告.

再次, 我们也编写自定义插件. 将一堆 fixture 聚集到一个文件中, 之后再具体类型的测试中具体说明该类型测试要使用哪些插件.

    ark [master] % cat tests/conftest.py
    # -*- coding: utf-8 -*-

    pytest_plugins = "suites.isolated_cases"
    ark [master] % cat teleport/tests/conftest.py
    # -*- coding: utf-8 -*-

    pytest_plugins = "suites.isolated_cases", "suites.xunit_fixtures",

### 自定义参数

以 suites.isolated_cases 为例:

    def pytest_addoption(parser):
        group = parser.getgroup("isolated_cases", "Every case is data-isolation.")
        group._addoption(
            '--with-data-service',
            action="store_true",
            default=False,
            dest='with_data_service',
            help=(
                "with MySQL/beansdb/memcached up at the beginning of session"
                "and down at the end of session."
            )
        )

    def pytest_configure(config):
        if config.option.with_data_service:
            build_tables()
            stop_kvstore()
            sleep(1)
            start_kvstore()

    def pytest_sessionfinish(session, exitstatus):
        if session.config.option.with_data_service:
            stop_kvstore()

    def pytest_runtest_teardown(item, nextitem):
        if KEY_CACHED['mc']:
            destroy_cached_key(mc, 'mc')
        if KEY_CACHED['shire_mc']:
            destroy_cached_key(shire_mc, 'shire_mc')
        if KEY_CACHED['db']:
            destroy_cached_key(db, 'db')
        if KEY_CACHED['fs']:
            destroy_cached_key(fs, 'fs')
        if KEY_CACHED['store']:
            truncate_cached_tables()

* pytest_addoption 添加 `--with-data-service`
* pytest_configure 使添加此标识的session在最开始可以建表/起mc/db服务
* pytest_sessionfinish 使添加此标识的session在最后可以杀掉db/mc服务(是否要摧毁所有的表?)
* pytest_runtest_teardown 每个case结束时判断是否有修改过数据服务, 如果有, 刷掉.  
 
但你需要知道, pytest 的 hook 非常多, 你可以在 [plugin] 中查阅这些hook.
你还需要知道, pytest 的 hook 至多, 文档甚至列不全, 像 `pytest_sessionfinish` 是我在源代码里挖到的 hook.
我想, 这么多hook, 应该可以满足你那变态的需求吧(在[这位少年对PM的吐槽]面前你竟然敢称自己的需求很变态?

### trivial

小知识: 
pytest 也提供了 setup/teardown, 不过 setup_method 与 setUp 是可以同时存在的哟. 具体顺序有兴趣的看官自己可以动手试试看. [classic xunit-style setup]. Anyway, 作者还是会不厌其烦的跟你说: 请你使用 fixture.

关于skip: 一个 pitfall 是 skip 必须传入一个字符串作为参数. 不能用作 @unittest.skip. 而必须是 @pytest.skip("... reason").
有个xfail也挺好用: 用于用例在某种场景下一定要挂掉.
138:    @pytest.mark.xfail(reason="response 500") 


### 总结

以上只是把仓库里的代码随手抽些拿出来讲了讲pytest的一些特性, 希望你会对pytest风格的测试感兴趣.



[1]: https://gist.github.com/soasme/8453802/raw/317bbce771302b1f5f17f12973449ce1787f0920/gistfile1.txt 
[2]: http://pytest.org/latest/ 
[How test configuration is read from configuration INI-files]: http://pytest.org/latest/customize.html#how-test-configuration-is-read-from-configuration-ini-files   
[Calling pytest from Python code]: http://pytest.org/latest/usage.html#calling-pytest-from-python-code 
[Defining own assertion comparison]: http://pytest.org/latest/assert.html#defining-your-own-assertion-comparison
[pytest-random]: https://github.com/klrmn/pytest-random
[pytest-vim-compiler]: https://github.com/5long/pytest-vim-compiler
[这页文档]: http://pytest.org/latest/fixture.html 
[Support for unittest.TestCase / Integration of fixtures]: http://pytest.org/latest/unittest.html
[plugin]: http://pytest.org/latest/plugins.html
[这位少年对PM的吐槽]: http://www.douban.com/people/iwinux/status/1314107154/ 
[classic xunit-style setup]: http://pytest.org/latest/xunit_setup.html
