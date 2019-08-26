<p align="center">
  <p align="center">Nestfans 爱好者社区论坛，基于 <a href="https://ruby-china.org">Ruby China</a> 发展而来。</p>
  <p align="center">
    <a href="https://travis-ci.org/ruby-china/homeland">
      <img src="https://travis-ci.org/ruby-china/homeland.svg?branch=master" />
    </a>
    <a href="https://codecov.io/github/ruby-china/homeland?branch=master">
      <img src="https://codecov.io/github/ruby-china/homeland/coverage.svg?branch=master" />
    </a>
  </p>
</p>

## Deployment

Please visit https://gethomeland.com get more documents.

## 开发

基于 Docker 开发环境，开发环境配置文件

```
Dockerfile.dev
Gemfile.dev
Gemfile.lock.dev
```

具体查看 Dockerfile.dev

```shell
# 1. 安装 Docker，启动 Docker
# 2. 本项目根目录执行构建 dev image 命令
make docker:build:dev

# 3. 获取 nestfans.com-docker
git clone https://github.com/nestfanscore/nestfans.com-docker.git
cd nestfans.com-docker/

# 4. 启动
make start

# 5. 调试和重启 重复第 2 步
make docker:build:dev
make restart
```

### 插件调试

将插件放在 plugins 目录，修改 `Gemfile.dev`，例如

```
gem 'nestfans-press', path: './plugins/nestfans-press'
```

修改 `Gemfile.lock.dev`，移除原有 Gem 下面的包

```
PATH
  remote: ./plugins/nestfans-press
  specs:
    homeland-press (0.4.1)
      rails

DEPENDENCIES
  homeland-press!
```

`Dockerfile.dev` 会自动把 plugins 目录下的插件打到 image 里

然后按照上方开发调试流程

## 部署

参考上方开发流程，第二步的 `make Docker:build:dev` 改为 `make Docker:build` 即可

其他配置参考 https://gethomeland.com/docs/

## Contribute Guide

Please read this document: [CONTRIBUTE GUIDE](https://github.com/ruby-china/homeland/blob/master/CONTRIBUTE.md)

## Thanks

* [Contributors](https://github.com/ruby-china/homeland/contributors)
* [Twitter Bootstrap](https://twitter.github.com/bootstrap)
* [Font Awesome](http://fortawesome.github.io/Font-Awesome/icons/)
* Forked from [Homeland Project](https://github.com/huacnlee/homeland)
* Theme from [Mediom](https://github.com/huacnlee/mediom)

## Sites used Homeland

https://gethomeland.com/expo

## License

Copyright (c) 2011-2017 Ruby China

Released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)

Emojis under the CC-BY 4.0 license from [Twitter/Twemoji][twemoji]:

* https://github.com/twitter/twemoji#license

[twemoji]: https://github.com/twitter/twemoji
