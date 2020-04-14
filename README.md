# RV Hub

Esse é um projeto de demonstração para seguir de guia (blueprints) aos desenvolvedores da Aplic

#### Quick start

Para rodar rapidamente o projeto siga os seguintes passos:

**1. Instale o RVM**

```
curl -sSL https://get.rvm.io | bash -s stable --ruby
```

**2. Instale o ruby a partir do RVM**

`rvm install <version>`

Por exemplo

`rvm install 2.6.4`

**3. Use a versão do ruby que você instalou**

`rvm use 2.6.4`

**4. Instale o MySQL** 

espero que vc saiba efetuar a instalação sem a minha ajuda :)

**5. Instale o memcached**

No mac

`brew install memcached`

No Linux

`apt-get install memcached`

No Windows

Good luck :)

**6. Instale o AWS CLI**

use o link: https://docs.aws.amazon.com/cli/latest/index.html

**7. Configure suas credentials da AWS**

`vi ~/aws/credentials`

e edite as variáveis **aws_access_key_id** e **aws_secret_access_key** com os valores sua conta AWS

**8. Deixe o MySQL rodando em sua máquina**

No mac

`mysql.server start`

**9. Deixe o Memcached rodando em sua máquina**

No mac

`memcached &`

**10. Copie o arquivo env.development.sample para .env.development e para o .env.test**

`cp env.development.sample .env.development`

`cp env.development.sample .env.test`

**11. Instale o jets**

`gem install jets`

**12. Edite os arquivos os arquivo .env.development e .env.test de acordo com a sua configuração local**

**13. Crie o ambiente de test**

JETS_ENV=test jets db:create db:migrate

**14. Crie o ambiente de desenvolvimento**

jets db:create db:migrate

**15. Rode os testes**

`bundle exec rspec`

#### Outros comandos do jets

O jets possui diversos outros comandos como:

**Abrir o console**

`jets c`

**Executar o servidor de aplicação**

`jets s`

**Verificar as rotas das APIs**

`jets routes`

Enjoy!