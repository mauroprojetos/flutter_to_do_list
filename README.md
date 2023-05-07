<h1 align="center">To-Do List 2.0</h1>

## Sobre o Projeto
Um aplicativo simples de lista de tarefas criado em aula orientada pelo professor Edson M. de Souza.
Modificad o projeto antigo para suporta as ultimas verções do sdk Android

## Construído com
Flutter
API PHP criada por Edson M. de Souza

## Como Usar
Altere a baseUrl na linha 1 em lib/constants/app_constants.dart com o caminho da sua API. 
Você pode usar a string main como baseUrl padrão.

EX: 
``` dart 
class URI {
  // SERVER
  final String main = 'http://php-api.duckdns.org';

  // LOCALHOST USING Android Virtual Device
  final String devAVD = 'http://php-api.duckdns.org';

  // LOCALHOST USING Browser
  final String devBrowser = 'http://php-api.duckdns.org';
}
```

## Problemas Conhecidos
O host pode retornar erro 406.
Ao baixar o código original, é necessário deletar a versão antiga do Android do repositório e copiar de outro projeto.
É necessário gerar um novo projeto e copiar a pasta Android para dentro do projeto.
Dentro da pasta do projeto, rode o comando flutter pub get para atualizar as dependências.

``` shell
flutter get pub
```

## Demo do projeto
* [API](http://php-api.duckdns.org/)

Na pasta de build foi gerado o APK e Executavel Windows 

## Tarefas a Realizar
Usar o pacote flutter_secure_storage para armazenar o token

## Agradecimentos
Edson M. de Souza
* [Edson M. de Souza](https://github.com/EdsonMSouza)



