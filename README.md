<img src="https://user-images.githubusercontent.com/38993485/204864300-bd8ed9ab-0a8d-4c1d-a1b4-9bcc7998bcb8.png" height="100">

# Catalog

Organizando a facilidade.

## Sobre

O Catalog está sendo desenvolvido para apresentação no Inova CPS.

O intuito do aplicativo é ser desenvolvido utilizando as ferramentas do Google. Como linguagem estou utilizando Flutter e no banco de dados Firebase Database e Storage. O aplicativo também conta com o sistema de autenticação Firestore Authentication.

A necessidade que queremos sanar é a de catalogação de itens contidos em embalagens e organização dos mesmos sem a necessidade de abertura da embalagem em questão, ou seja, poderá ser descoberto o conteúdo sem a necessidade de manejos. Isso será feito com um QR Code ou Barcode fixado no exterior da embalagem, assim podendo ser escaneado na aplicação que exibirá seu conteúdo. Os QR Codes e Barcodes gerados poderão somente ser escaneados em um aplicativo Catalog e conta também com criptografia protegida por senha caso o conteúdo seja confidencial.

Caso haja a necessidade de alteração do conteúdo ou remoção de itens, isso poderá ser feito no aplicativo sem a necessidade de criação de um novo QR Code, pois eles contam com ID único global.

## Estrutura de dados

O sistema de autenticação atual conta com duas formas de registro e entrada, sendo e-mail e senha e também Google. A estrutura abaixo é de um usuário com as duas formas ativas que se mesclam automaticamente no Firebase Authentication assim reduzindo a chance de usuários duplicados. 

```JSON
{"users": [
{
  "localId": "ID_LOCAL",
  "email": "email@gmail.com",
  "emailVerified": true,
  "displayName": "Fabricio Amorim",
  "photoUrl": "URL_FOTO_DE_PERFIL",
  "lastSignedInAt": "1669754622129",
  "createdAt": "1667929188871",
  "providerUserInfo": [
    {
      "providerId": "google.com",
      "rawId": "ID_LOCAL",
      "email": "email@gmail.com",
      "displayName": "Fabricio Amorim",
      "photoUrl": "URL_FOTO_DE_PERFIL"
    }
  ]
}
]}
```

O cadastro de usuários por e-mail conta com verificação de endereço de e-mail no arquivo `/lib/access/verify_auth.dart` que envia um e-mail com o código de verificação através da utulização da função `sendEmailVerification()` do próprio `FirebaseAuth`.


A estrutura abaixo é gerada assim que criado um novo QR Code ou Barcode na aplicação. Ela é responsável por armazenar as informações e caminhos para arquivos e imagens anexados.

```JSON
{
    "ID_UNICO_DO_QR_CODE": {
      "cripto": "SENHA_QR_CODE_CRIPTOGRAFADA",
      "description": "Contem:\n\n1 teclado\n1 PC",
      "id": "ID",
      "storageRefFiles": [
        {
          "date": "2022-11-25 19:20:00.068436",
          "name": "IMG-20221125-WA0023.pdf",
          "ref": "URL_DO_ARQUIVO_NO_BUCKET"
        },
        {
          "date": "2022-11-25 19:20:08.100944",
          "name": "IMG-20221125-WA0024.pdf",
          "ref": "URL_DO_ARQUIVO_NO_BUCKET"
        }
      ],
      "storageRefImages": [
        {
          "date": "2022-11-25 19:18:28.890317",
          "name": "a38097ee-fef5-4aab-83ab-162ee60082463212782715081280763.jpg",
          "ref": "URL_DA_IMAGEM_NO_BUCKET",
          "uploadName": "file-2022-11-25 19:18:18.393960.jpg"
        }
      ],
      "title": "Teste 1",
      "user": "ID_DO_USUARIO_QUE_CRIOU",
      "user-mail": "EMAIL_DO_USUARIO_QUE_CRIOU"
    }
}
```
## Dependências:

Os packages abaxo são necessários para determinadas funções na aplicação, poderá saber mais de cada um através do site `pub.dev`

- flutter_lints: ^2.0.0
- share_plus: ^6.2.0
- image_picker: ^0.8.6
- url_launcher: ^6.1.6
- mobile_scanner: ^2.0.0
- loading_animation_widget: ^1.2.0+3
- syncfusion_flutter_barcodes: ^20.3.52
- share_files_and_screenshot_widgets: ^1.0.6
- cupertino_icons: ^1.0.2
- cloud_firestore: ^4.0.3
- firebase_auth: ^4.1.1
- firebase_core: ^2.1.1
- firebase_storage: ^11.0.5
- google_sign_in: any
- email_validator: ^2.1.17
- font_awesome_flutter: any
- provider: any
- path_provider: ^2.0.11
- crypto: ^3.0.2
- file_picker: ^5.2.2
- flutter_file_downloader: ^1.1.0+1
- firebase_crashlytics: ^3.0.6

## Configuração de ambiente:

A configuração deste aplicativo em outro ambiente é bem simples basta ter o `Flutter` e o `Firebase` com o `FlutterFire` instalados na máquina que executou o download deste repositório.

Após é necessário que configure seu ambiente Firebase que pode ser encontrado na documentação do mesmo https://firebase.google.com/docs/flutter/setup?platform=android
Depois de configurado é necessário que crie no Firebase o Authentication com as Keys da sua máquina e o Firestore Storage e Database com a regra `allow read, write: if true;` que dará permissão de inserção no banco de dados.

Após configurado e realizado o login com sua conta através do comando `Firebase login` é necessário que rode o comando `Flutter pub get` no diretório que está a aplicação, este comando fará com que todas as dependências sejam instaladas.

Com isso ele estará apto a ser executado em emuladores androids fisicos ou virtuais que poderão ser escolhidos através do comando `flutter devices` e logo após executado em `flutter run`.

Nota: <br>
Atente-se se as permissões abaixo estão concedidas em seu arquivo `/android/src/main/AndroidManifest.xml`.

`<uses-permission android:name="android.permission.INTERNET"/>`<br>
`<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />`<br>
`<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>`

## Atualizações:

Estou trabalhando no momento com a adição da tela de edição do conteúdo gerado no primeiro QR Code.

Abaixo as funcionalidades já implementadas:

- Firebase Crashalytics
- Firebase Performance
- Firebase Analitics
- Firebase Authentication
- Criação de QR Codes
- Anexo de multiplos arquivos e Documentos
- Criação de criptografia nos QR Codes
- Login Google
- Login e-mail e senha
- Criação de usuário com Google
- Criação de usuário com e-mail e senha e validação de e-mail
- Share de QR Code pós emissão
- Download de arquivos anexados
- Forgot password
- Scan de arquivos com avisos para QR Codes não oficiais
- Validação de campos e verificação de informações válidas com mensagem de erro instantânea
- Logout multiplo, destroi sessão independente do método de login
- Scan com a possibilidade de progurar arquivos da galeria
- Design Material 3

Abaixo as funcionalidades a serem implementadas:

- Firebase App Distribution
- Firebase Remote Config
- Firebase A/B Testing
- Firebase App Check
- Google Functions para criação de tumbmail automatizada com gatilho de inserção de imagem no Bucket
- Quota de QR Codes por usúario
- Quota de anexos por usuário
- Versão Web
- Versão IOS

## PrintScreens do app

Tela de login:

<img src="https://user-images.githubusercontent.com/38993485/204807982-e5eea307-a051-4d92-bd7b-08b0b676effe.jpeg" height="500">

Tela de início:

<img src="https://user-images.githubusercontent.com/38993485/204808041-283c7f0b-d010-4c21-87fb-20ab2f066e42.jpeg" height="500">

Tela para gerar QR Code:

<img src="https://user-images.githubusercontent.com/38993485/204808062-9406a4a8-0459-4df5-ae11-2f58efa7e8ad.jpeg" height="500">

Tela para escanear QR Code:

<img src="https://user-images.githubusercontent.com/38993485/204808067-bceb2476-c52b-4232-a4e8-441d4337d255.jpeg" height="500">


![Optimized-translucent_3d_logo_mockup](https://user-images.githubusercontent.com/38993485/204806819-891e3ac6-e4ce-4a96-bc07-84af436ec0f4.png)




